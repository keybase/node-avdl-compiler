path_lib   = require 'path'
pkg        = require '../package.json'

exports.TypescriptEmitter = class TypescriptEmitter
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

  output_doc : (d) ->
    if d?
      @output "/**"
      for line in d.split /\n/
        @output " * " + line.replace /^\s$/, ''
      @output " */"

  emit_preface : ({infile}) ->
    @output "/*"
    @output " * Auto-generated to TypeScript by #{pkg.name} v#{pkg.version} (#{pkg.homepage})"
    @output " *   Input file: #{path_lib.relative(process.cwd(), infile)}"
    @output " */"
    @output ""

  emit_imports : ({imports}) ->
    for {import_as, path} in imports
      console.log import_as, path
      # line = ""
      # line = import_as + " " if import_as?
      # line += '"' + path + '"'
      # @output line
      #
      #

  emit_types : ({types, go_field_suffix}) ->
    for type in types
      @emit_type { type, go_field_suffix }

  emit_type : ({type, go_field_suffix}) ->
    @output_doc type.doc
    switch type.type
      when "record"
        if type.typedef
          @emit_typedef type
        else
          @emit_record type
    #   when "fixed"
    #     @emit_fixed type
      when "enum"
        nostring = (type.go is "nostring")
        @emit_enum { t : type, nostring }
    #   when "variant"
    #     @emit_variant { obj : type, go_field_suffix }
    #
    #
    #
    #
    #
  emit_enum : ({t, nostring}) ->
    console.log t
    # Type and constants
    name = t.name
    @output "enum #{name} {"
    @tab()
    for s, _ in t.symbols
      [e_name..., e_num] = s.split("_")
      e_name = e_name.join("_")
      @output "#{e_name} = #{e_num}"
    @untab()
    @output "}"

  convert_primitive_type : (m) ->
    map =
      bool : "boolean"
      bytes : "Buffer"
      long : "number"
      float : "number"
      double : "number"
      uint : "number"
      int : "number"
    map[m] or m

  emit_field_type : (t) ->
    optional = false
    type = if typeof(t) is 'string' then @convert_primitive_type(t)
    { type, optional }

  emit_typedef : (t) ->
    @output "type #{t.name} = #{@emit_field_type(t.typedef).type}"
    true

  emit_field : ({name, type, go_field_suffix, exported, pointed, jsonkey, mpackkey}) ->
    {type, optional} = @emit_field_type(type)
    # cols.push(@codec({name, optional, jsonkey, mpackkey})) if exported
    @output "#{name}: #{type}"

  emit_record : (obj) ->
    @output "type #{obj.name} = {"
    @tab()
    for f in obj.fields
      @emit_field
        name : f.name
        type : f.type
        exported : not(f.internal?)
        jsonkey : f.jsonkey
        mpackkey : f.mpackkey
    @untab()
    @output "}"


  run : ({infile, json, types_only}) ->
    @emit_preface {infile}
    @emit_imports json
    @emit_types json
    # TODO: add support for interfaces
    @_code
