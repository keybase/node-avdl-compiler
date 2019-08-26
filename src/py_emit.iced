path_lib      = require 'path'
{BaseEmitter} = require './base_emitter'
pkg           = require '../package.json'

exports.PythonEmitter = class PythonEmitter extends BaseEmitter
  tabs : () -> ("    " for i in [0...@_tabs]).join("")

  emit_preface : (infiles, {namespace}) ->
    @output '"""' + namespace
    @output ""
    @output "Auto-generated to Python types by #{pkg.name} v#{pkg.version} (#{pkg.homepage})"
    @output "Input files:"
    for infile in infiles
      @output " - #{path_lib.relative(process.cwd(), infile)}"
    @output '"""'
    @output ""
