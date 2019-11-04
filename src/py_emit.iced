path_lib      = require 'path'
{BaseEmitter} = require './base_emitter'
pkg           = require '../package.json'
{uniqWith, isEqual, snakeCase} = require 'lodash'
{is_primitive} = require './utils'

exports.PythonEmitter = class PythonEmitter extends BaseEmitter
  constructor : () ->
    super
    @_tab_char = " ".repeat(4)
    # 'self' isn't technically a keyword, but causes issues in classes
    # 'config' causes issues with dataclasses-json
    @_keywords = new Set ['False', 'None', 'True', 'and', 'as', 'assert', 'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except', 'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is', 'lambda', 'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'try', 'while', 'with', 'yield', 'self', 'config']

  format_name : (name) ->
    formatted_name = snakeCase(name)
    if @_keywords.has formatted_name
      formatted_name += '_'
    formatted_name

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
      bytes : "str"
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
        optional = true
        "List[#{@emit_field_type(t.items).type}]"
      else if t.type is "map"
        @make_map_type t
      else
        throw new Error "Unrecognized type"
    else
      throw new Error "Unrecognized type"
    { type , optional }

  make_map_type : (t) ->
    {optional, type} = @emit_field_type(t.values)
    type = "Optional[#{type}]" if optional
    "Dict[str, #{type}]"

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
    @output "from dataclasses import dataclass, field"
    @output "from enum import Enum"
    @output "from typing import Dict, List, Optional, Union"
    @output "from typing_extensions import Literal"
    @output ""
    @output "from dataclasses_json import config, DataClassJsonMixin"
    @output ""

    imports = uniqWith imports, isEqual
    relative_dir = path_lib.dirname(outfile)
    for {import_as, path} in imports
      if not import_as?
        continue
      if path.match /(\.\/|\.\.\/)/
        path = path_lib.normalize(relative_dir + "/" + path)
      path = path.replace /\//g, '.'
      # remove the first `.`, since it's extra
      path = path.slice(1) if path[0] is '.'
      @output "import #{path} as #{import_as}"
    @output ""

  emit_typedef : (type) ->
    @output "#{type.name} = #{@emit_field_type(type.typedef).type}"

  emit_fixed : (type) ->
    @output "#{type.name} = Optional[str]"

  emit_field : ({name, type, jsonkey, optionalkey}) ->
    {type, optional} = @emit_field_type(type, {optionalkey})
    field_name = @format_name(name)
    type = if optional then "Optional[#{type}]" else type
    @output "#{field_name}: #{type} = field(#{if optional then 'default=None, ' else ''}metadata=config(field_name='#{jsonkey or name}'))"

  is_optional : (field) ->
    if Array.isArray(field.type) and not field.type[0]?
      return true
    if typeof(field.type) is 'object' and field.type.type is 'array'
      return true
    Boolean(field.optional)

  emit_record : (record) ->
    @output "@dataclass"
    @output "class #{record.name}(DataClassJsonMixin):"
    @tab()

    # Python needs all non-optional types to come before optional types so we sort
    fields = record.fields.sort (a, b) =>
      if @is_optional(a) and not @is_optional(b)
        return 1
      if not @is_optional(a) and @is_optional(b)
        return -1
      return 0

    for f in fields
      @emit_field
        name : f.name
        type : f.type
        jsonkey : f.jsonkey
        optionalkey : f.optional

    if fields.length is 0
      @output "pass"
    @untab()
    @output ""

  emit_enum : (type) ->
    @output "class #{type.name}(Enum):"
    @tab()
    @output_doc type.doc
    for s, _ in type.symbols
      [e_name..., e_num] = s.split("_")
      e_name = e_name.join("_")
      @output "#{e_name} = #{e_num}"
    @untab()
    @output ""
    @output "class #{type.name}Strings(Enum):"
    @tab()
    for s, _ in type.symbols
      [e_name..., e_num] = s.split("_")
      e_name = e_name.join("_")
      @output "#{e_name} = '#{e_name.toLowerCase()}'"
    @untab()
    @output "\n"

  emit_variant : (type) ->
    is_switch_primitive = is_primitive type.switch.type
    cases = type.cases
      .map((type_case) =>
        if type_case.label.def then return null
        bodyType = switch
          when type_case.body == null then 'None'
          when typeof type_case.body == 'string' then "Optional[#{@emit_primitive_type type_case.body}]"
          when type_case.body.type == 'array' then "Optional[List[#{@emit_primitive_type(type_case.body.items)}]]"
          else
            throw new Error "Unrecognized type"
        @output "@dataclass"
        @output "class #{type.name}__#{type_case.label.name}(DataClassJsonMixin):"
        @tab()
        @output "#{type.switch.name}: Literal[#{if is_switch_primitive then '' else type.switch.type + 'Strings.'}#{type_case.label.name}]"
        @output "#{type_case.label.name}: #{bodyType}"
        @untab()
        @output ""
        "#{type.name}__#{type_case.label.name}"
      ).filter(Boolean)
    @output "#{type.name} = Union[#{cases.join(", ")}]"
    @output ""
