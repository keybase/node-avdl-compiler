
minimist = require 'minimist'
avdl2json = require 'avdl2json'
{GoEmitter} = require './emit'
{make_esc} = require 'iced-error'
fs = require 'fs'
pathmod = require 'path'

#================================================

usage = () ->
  console.error """AVDL Compiler

#{'  '}single file: avdlc -l <lang> -i <infile> -o <outfile>
#{'  '}batch:       avdlc -l <lang> -b -o <outdir> <infiles...>

avdlc can run in either batch or single-file mode. Specify which language
to output code in. Currently, only "go" is supported.
"""

#================================================

emit = ( { json }, cb) ->
  e = new GoEmitter()
  code = e.run { json }
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
      @outdir = argv.o
      @infiles = argv._
      unless @outdir? and @infiles.length
        err = new Error "need an [-o <outdir>] and input files in batch mode"
    else
      @outfile = argv.o
      @infile = argv.i
      unless @outfile? and @infile?
        err = new Error "need an [-i <infile>] and a [-o <outfile>]"
    if not argv.l? or argv.l isnt "go"
      err = new Error "must specify a language; candidates are: {'go'}"
    else
      @lang = "go"
    @clean = argv.c
    cb err

  #---------------

  make_outfile : (f) -> pathmod.join @outdir, ((pathmod.basename f, '.avdl') + ".go")

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
      await emit { json : ast.to_json() }, esc defer code
      await output { code, outfile }, esc defer()
      console.log "Compiling #{infile} -> #{outfile}"
    cb null

  #---------------

  do_batch_mode : (opts, cb) ->
    esc = make_esc cb, "do_batch_mode"
    for infile in @infiles
      outfile = @make_outfile infile
      skip = false
      unless @clean
        await @skip_infile { infile, outfile }, esc defer skip
      unless skip
        await @do_file { infile, outfile }, esc defer()
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
