minimist = require 'minimist'
avdl2json = require 'avdl2json'
{GoEmitter} = require './go_emit'
{TypescriptEmitter} = require './ts_emit'
{PythonEmitter} = require './py_emit'
{make_esc} = require 'iced-error'
fs = require 'fs'
pathmod = require 'path'

#================================================

usage = () ->
  console.error """AVDL Compiler

#{'  '}single file: avdlc -l <lang> [-t] -i <infile> -o <outfile>
#{'  '}batch:       avdlc -l <lang> [-t] -b -o <outdir> <infiles...>

avdlc can run in either batch or single-file mode. Specify which language
to output code in. Currently, only "go" is fully supported. TypeScript and Python are partially supported.

Use -t to only print types and ignore function definitions.
"""

#================================================

emit = ( { infiles, outfile, json, lang, types_only }, cb) ->
  emitter = switch lang
    when "go" then new GoEmitter()
    when "typescript" then new TypescriptEmitter()
    when "python" then new PythonEmitter()

  code = emitter.run infiles, outfile, json, {types_only}
  cb null, code

#================================================

output = ({outfile, code}, cb) ->
  await fs.writeFile outfile, code.join("\n"), defer err
  cb err

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
      @outdir = argv.o
      @infiles = argv._
      unless @outdir? and @infiles.length
        err = new Error "need an [-o <outdir>] and input files in batch mode"
    else
      @types_only = argv.t
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
    pathmod.join @outdir, ((pathmod.basename f, '.avdl') + extension)

  #---------------

  skip_infile : ({infile, outfile}, cb) ->
    esc = make_esc cb, "skip_infile"
    await
      fs.stat infile,  esc defer s0
      fs.stat outfile, defer err, s1
    cb null, (not(err?) and (s0.mtime <= s1.mtime))

  #---------------

  do_file : ({infile, outfile}, cb) ->
    esc = make_esc cb, "do_file"
    if @clean
      await fs.unlink outfile, defer err
      console.log "Deleting #{outfile}" unless err?
    else
      await avdl2json.parse { infile, version : 2 }, esc defer ast
      await emit { infiles: [infile], outfile, json : ast.to_json(), @types_only, @lang }, esc defer code
      await output { code, outfile }, esc defer()
      console.log "Compiling #{infile} -> #{outfile}"
    cb null

  #---------------

  do_files_as_one : ({outfile}, cb) ->
    esc = make_esc cb, "do_files_as_one"
    json = {imports: [], types: []}
    for infile in @infiles
      await avdl2json.parse { infile, version: 2 }, esc defer ast
      json.types = json.types.concat(ast.to_json().types)
      json.imports = json.imports.concat(ast.to_json().imports)

    await emit { @infiles, json, types_only: true, @lang }, esc defer code
    await output { code, outfile }, esc defer()
    console.log "Compiling #{infile} -> #{outfile}"

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
    cb null

  #---------------

  main : ({argv}, cb) ->
    esc = make_esc cb, "main"
    await @parse_argv {argv}, esc defer()
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
