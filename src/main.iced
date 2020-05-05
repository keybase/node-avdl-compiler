minimist = require 'minimist'
avdl2json = require 'avdl2json'
{GoEmitter} = require './go_emit'
{TypescriptEmitter} = require './ts_emit'
{PythonEmitter} = require './py_emit'
{make_esc} = require 'iced-error'
fs = require 'fs'
pathmod = require 'path'
{mergeWith} = require 'lodash'
{exec} = require 'child_process'

#================================================

usage = () ->
  console.error """AVDL Compiler

#{'  '}single file: avdlc -l <lang> [-t] [-m] -i <infile> -o <outfile>
#{'  '}batch:       avdlc -l <lang> [-t] [-m] -b -o <outdir> <infiles...>

avdlc can run in either batch or single-file mode. Specify which language
to output code in. Currently, only "go" is fully supported. TypeScript and Python are partially supported.

Use -t to only print types and ignore function definitions.
Use -m to set gomodules support
"""

#================================================

emit = ( { infiles, outfile, json, lang, types_only, gomod_path, gomod_dir }, cb) ->
  emitter = switch lang
    when "go" then new GoEmitter(gomod_path, gomod_dir)
    when "typescript" then new TypescriptEmitter()
    when "python" then new PythonEmitter()
    else throw new Error "Unrecognized language: #{@lang}"

  code = emitter.run {infiles, outfile, json, options: {types_only}}
  cb null, code

#================================================

output = ({outfile, code}, cb) ->
  await fs.writeFile outfile, code.join("\n"), defer err
  cb err

#================================================

merge_asts = (ast1, ast2) ->
  mergeWith ast1, ast2, (value1, value2) ->
    if Array.isArray(value1)
      return value1.concat value2
    else
      return undefined

#================================================

exports.Main = class Main

  #---------------

  constructor : () ->

  #---------------

  parse_argv : ({argv}, cb) ->
    argv = minimist argv
    if argv.h
      usage()
      err = new Error "usage: shown!"
    else if (@batch = argv.b)
      @types_only = argv.t
      @gomod_enabled = argv.m
      @outdir = argv.o
      @infiles = argv._
      unless @outdir? and @infiles.length
        err = new Error "need an [-o <outdir>] and input files in batch mode"
    else
      @types_only = argv.t
      @gomod_enabled = argv.m
      @outfile = argv.o
      @infile = argv.i
      unless @outfile? and @infile?
        err = new Error "need an [-i <infile>] and a [-o <outfile>]"
    if not argv.l? or not argv.l.match /^(go|typescript|python)$/
      err = new Error "must specify a language; candidates are: {'go', 'typescript', 'python'}"
    else
      @lang = argv.l
    @clean = argv.c
    cb err

  #---------------

  make_outfile : (f) ->
    extension = switch @lang
      when "typescript" then ".ts"
      when "go" then ".go"
      when "py" then ".py"
      else throw new Error "Unrecognized language: #{@lang}"
    pathmod.join @outdir, ((pathmod.basename f, '.avdl') + extension)

  #---------------

  skip_infile : ({infile, outfile}, cb) ->
    esc = make_esc cb, "skip_infile"
    await
      fs.stat infile,  esc defer s0
      fs.stat outfile, defer err, s1
    cb null, (not(err?) and (s0.mtime <= s1.mtime))

  #---------------

  get_gomod : (opts, cb) ->
    esc = make_esc cb, "get_gomod"
    cwd = if @outdir? then @outdir else pathmod.dirname(@outfile)
    await exec 'go list -m -json', {cwd}, esc defer stdout
    @gomod_path = JSON.parse(stdout).Path
    @gomod_dir = JSON.parse(stdout).Dir
    cb null

  #---------------

  do_file : ({infile, outfile}, cb) ->
    esc = make_esc cb, "do_file"
    if @clean
      await fs.unlink outfile, defer err
      console.log "Deleting #{outfile}" unless err?
    else
      await avdl2json.parse { infile, version : 2 }, esc defer ast
      await emit { infiles: [infile], outfile, json : ast.to_json(), @types_only, @lang, @gomod_path, @gomod_dir }, esc defer code
      await output { code, outfile }, esc defer()
      console.log "Compiling #{infile} -> #{outfile}"
    cb null

  #---------------

  # Unlike Go, where a package can be spread around multiple files, Python and TypeScript
  # treat each file as it's own package/module. Since we want each avdl package to map to a package in the
  # destintation language, we'll just put all the types in one file.
  do_files_as_one : ({outfile}, cb) ->
    esc = make_esc cb, "do_files_as_one"
    json = {}
    for infile in @infiles
      await avdl2json.parse { infile, version: 2 }, esc defer ast
      merge_asts json, ast.to_json()
    await emit { @infiles, json, outfile, types_only: true, @lang, @gomod_path, @gomod_dir }, esc defer code
    await output { code, outfile }, esc defer()
    console.log "Compiling #{@infiles} -> #{outfile}"

    cb null

  #---------------

  do_batch_mode : (opts, cb) ->
    esc = make_esc cb, "do_batch_mode"
    switch @lang
      when "go"
        for infile in @infiles
          outfile = @make_outfile infile
          skip = false
          unless @clean
            await @skip_infile { infile, outfile }, esc defer skip
          unless skip
            await @do_file { infile, outfile }, esc defer()
      when "typescript"
        outfile = pathmod.join @outdir, 'index.ts'
        await @do_files_as_one { outfile }, esc defer()
      when "python"
        outfile = pathmod.join @outdir, '__init__.py'
        await @do_files_as_one { outfile }, esc defer()
      else
        throw new Error "Unrecognized language: #{@lang}"
    cb null

  #---------------

  main : ({argv}, cb) ->
    esc = make_esc cb, "main"
    await @parse_argv {argv}, esc defer()
    if @gomod_enabled
      await @get_gomod {}, esc defer()
    if @batch
      await @do_batch_mode {}, esc defer()
    else
      await @do_file { @infile, @outfile }, esc defer()
    cb null

#================================================

exports.main = () ->
  main = new Main
  await main.main { argv :process.argv[2...] }, defer err
  rc = 0
  if err?
    rc = -2
    console.error err.toString().red

  process.exit rc
