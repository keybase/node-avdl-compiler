path_lib      = require 'path'
{BaseEmitter} = require './base_emitter'
pkg           = require '../package.json'
{uniqWith, isEqual, camelCase} = require 'lodash'

exports.PythonEmitter = class PythonEmitter extends BaseEmitter
  constructor : () ->
    super
    @_tab_char = " ".repeat(4)
    @_keywords = new Set ['False', 'None', 'True', 'and', 'as', 'assert', 'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except', 'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is', 'lambda', 'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'try', 'while', 'with', 'yield']

  # format_name : (name, jsonkey) ->


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
      boolean : "bool"
      double : "float"
      long : "int"
      int64 : "int"
      uint : "int"
      uint64 : "int"
    map[m] or m

  emit_field_type : (t, {pointed, optionalkey} = {}) ->
    optional = optionalkey
    type = if typeof(t) is 'string' then @emit_primitive_type(t)
    else if typeof(t) is 'object'
      if Array.isArray(t)
        if not t[0]?
          optional = true
          @emit_field_type(t[1]).type
        else
          throw new Error "Unrecognized type"
      else if t.type is "array"
        "List[#{@emit_field_type(t.items).type}]"
      else if t.type is "map"
        @make_map_type t
      else
        throw new Error "Unrecognized type"
    else
      throw new Error "Unrecognized type"
    { type , optional }

  make_map_type : (type) ->
    "Dict[str, #{@emit_field_type(type.values).type}]"

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
    @output "from dataclasses import dataclass"
    @output "from enum import Enum"
    @output "from typing import Dict, List, Optional, Union"
    @output ""
    @output "from mashumaro import DataClassJSONMixin"
    @output ""

    imports = uniqWith imports, isEqual
    for {import_as, path} in imports when path.indexOf('/') >= 0
      if not import_as
        continue
      # path = path.replace /\//g, '.'
      # # remove the first `.`, since it's extra
      # path = path.slice(1) if path[0] is '.'
      # @output "import #{path} as #{import_as}"
      @output "import #{import_as}"
    @output ""

  emit_typedef : (type) ->
    @output "#{type.name} = #{@emit_field_type(type.typedef).type}"

  emit_fixed : (type) ->
    @output "#{type.name} = Optional[str]"

  emit_field : ({name, type, jsonkey, optionalkey}) ->
    {type, optional} = @emit_field_type(type, {optionalkey})
    fieldName = camelCase(jsonkey or name)
    type = if optional then "Optional[#{type}]" else type
    @output "#{fieldName}: #{type}"

  emit_record : (record) ->
    @output "@dataclass"
    @output "class #{record.name}(DataClassJSONMixin):"
    @tab()
    fields = uniqWith record.fields, (a, b) ->
      camelCase(a.jsonkey or a.name) == camelCase(b.jsonkey or b.name)
    for f in fields
      @emit_field
        name : f.name
        type : f.type
        jsonkey : f.jsonkey
        optionalkey : f.optional
    if fields.length is 0
      @output "pass"
    @untab()
    @output "\n"

  emit_enum : (type) ->
    @output "class #{type.name}(Enum):"
    @tab()
    @output_doc type.doc
    for s, _ in type.symbols
      [e_name..., e_num] = s.split("_")
      e_name = e_name.join("_")
      @output "#{e_name} = '#{e_name.toLowerCase()}'"
    @untab()
    @output "\n"

  emit_variant : (type) ->
    cases = type.cases
      .map((type_case) =>
        if type_case.label.def then return null
        bodyType = switch
          when type_case.body == null then 'null'
          when typeof type_case.body == 'string' then @emit_primitive_type type_case.body
          when type_case.body.type == 'array' then "List[#{@emit_primitive_type(type_case.body.items)}]"
          else
            throw new Error "Unrecognized type"
        @output "@dataclass"
        @output "class #{type.name}#{type_case.label.name}:"
        @tab()
        @output "#{type.switch.name}: #{type.switch.type}.#{type_case.label.name}"
        @output "#{type_case.label.name}: Optional[#{bodyType}]"
        @untab()
        "#{type.name}#{type_case.label.name}"
      ).filter(Boolean)
    @output "#{type.name} = Union[#{cases.join(", ")}]"
    @output ""
