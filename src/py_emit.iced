path_lib      = require 'path'
{BaseEmitter} = require './base_emitter'
pkg           = require '../package.json'

exports.PythonEmitter = class PythonEmitter extends BaseEmitter
  constructor : () ->
    super
    @_tab_char = " ".repeat(4)

  emit_preface : (infiles, {namespace}) ->
    @output '"""' + namespace
    @output ""
    @output "Auto-generated to Python types by #{pkg.name} v#{pkg.version} (#{pkg.homepage})"
    @output "Input files:"
    for infile in infiles
      @output " - #{path_lib.relative(process.cwd(), infile)}"
    @output '"""'
    @output ""


  # TODO: This should be removed in favor of the complete definition in base_emitter once more methods are defined
  run : ({infiles, outfile, json, options}) ->
    @emit_preface infiles, json, options
    @_code
