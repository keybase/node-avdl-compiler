path_lib      = require 'path'
{BaseEmitter} = require './base_emitter'
pkg           = require '../package.json'
_ = require 'lodash'

exports.PythonEmitter = class PythonEmitter extends BaseEmitter
  constructor : () ->
    super
    @_tab_char = " ".repeat(4)

  output_doc : (d) ->
    if d?
      @output '"""'
      for line in d.split /\n/
        @output line.replace /^\s*/, ''
      @output '"""'

  emit_type : (type) ->
    switch type.type
      when "record"
        if type.typedef
          @emit_typedef type
        else
          @emit_record type
      when "fixed"
        @emit_fixed type
      when "enum"
        @emit_enum type
      when "variant"
        @emit_variant type

  emit_primitive_type : (m) ->
    map =
      string : "str"
    map[m] or m

  emit_field_type : (t, {pointed, optionalkey} = {}) ->
    optional = !!pointed or optionalkey
    type = if typeof(t) is 'string' then @emit_primitive_type(t)
    else if typeof(t) is 'object'
      if Array.isArray(t)
        if not t[0]?
          optional = true
          "*" + @emit_field_type(t[1]).type
        else
          "ERROR"
      else if t.type is "array"
        "[]" + @emit_field_type(t.items).type
      else if t.type is "map"
        @make_map_type { t }
      else "ERROR"
    else "ERROR"
    type = "*" + type if pointed
    { type , optional }

  emit_preface : (infiles, {namespace}) ->
    @output '"""' + namespace
    @output ""
    @output "Auto-generated to Python types by #{pkg.name} v#{pkg.version} (#{pkg.homepage})"
    @output "Input files:"
    for infile in infiles
      @output " - #{path_lib.relative(process.cwd(), infile)}"
    @output '"""'
    @output ""

  emit_imports : ({imports}, outfile) ->
    imports = _.uniqWith imports, _.isEqual
    for {import_as, path} in imports when path.indexOf('/') >= 0
      if not import_as
        continue
      path = path.replace '/', '.'
      # remove the first `.`, since it's extra
      path = path.slice(1)
      @output "from #{path} import * as #{import_as}"
    @output ""

  emit_typedef : (t) ->
    @output "#{t.name} = #{@emit_field_type(t.typedef).type}"

  emit_fixed : (t) ->
    @output "#{t.name} = Optional[str]"

  emit_enum : (t) ->
    @output "class #{t.name}(Enum):"
    @tab()
    @output_doc t.doc
    for s, _ in t.symbols
      [e_name..., e_num] = s.split("_")
      e_name = e_name.join("_")
      @output "#{e_name} = #{e_num}"
    @untab()
    @output ""
