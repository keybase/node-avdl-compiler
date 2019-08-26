_          = require 'lodash'
path_lib   = require 'path'
pkg        = require '../package.json'

exports.BaseEmitter = class BaseEmitter
  constructor : () ->
    @_code = []
    @_tabs = 0
    # @_pkg = null


  tab : () -> @_tabs++
  untab : () -> @_tabs--
  tabs : () -> ("  " for i in [0...@_tabs]).join("")

  output : (l, {frag} = {}) ->
    if @_last_frag
      @_code[@_code.length-1] += l
      @_last_frag = false
    else
      @_code.push (@tabs() + l)
    if frag
      @_last_frag = true
    else
      @_code.push("") if (l is "}" or l is ")") and @_tabs is 0
