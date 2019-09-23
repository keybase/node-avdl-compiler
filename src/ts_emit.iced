path_lib   = require 'path'
{BaseEmitter} = require './base_emitter'
pkg        = require '../package.json'
{camelCase, uniqBy, uniqWith, isEqual} = require('lodash')
{is_primitive} = require './utils'

exports.TypescriptEmitter = class TypescriptEmitter extends BaseEmitter
  constructor : () ->
    super
    @_tab_char = " ".repeat(2)

  emit_preface : (infiles, {namespace, doc}) ->
    @output "/*"
    @output " * #{namespace}"
    if doc?
      for line in doc.split /\n/
        @output " * " + line.replace /^\s$/, ''
    @output " *"
    @output " * Auto-generated to TypeScript types by #{pkg.name} v#{pkg.version} (#{pkg.homepage})"
    @output " * Input files:"
    for infile in infiles
      @output " * - #{path_lib.relative(process.cwd(), infile)}"
    @output " */"
    @output ""

  output_doc : (doc) ->
    if doc?
      @output "/**"
      for line in doc.split /\n/
        @output " * " + line.replace /^\s$/, ''
      @output " */"

  convert_primitive_type : (type) ->
    map =
      bool : "boolean"
      bytes : "Buffer"
      long : "number"
      float : "number"
      double : "number"
      uint : "number"
      int : "number"
      uint64 : "number"
      int64 : "number"
    map[type] or type

  make_map_type : (type) ->
    "{[key: string]: #{@emit_field_type(type.values).type}}"

  emit_field_type : (t, {optionalkey} = {}) ->
    optional = optionalkey?
    type = if typeof(t) is 'string' then @convert_primitive_type(t)
    else if typeof(t) is 'object'
      if Array.isArray(t)
        if not t[0]?
          optional = true
          @emit_field_type(t[1]).type
        else
          throw new Error "Unrecognized type"
      else if t.type is "array"
        @emit_field_type(t.items).type + "[] | null"
      else if t.type is "map"
        @make_map_type t
      else
        throw new Error "Unrecognized type"
    else
      throw new Error "Unrecognized type"
    { type, optional }

  emit_typedef : (type) ->
    @output "export type #{type.name} = #{@emit_field_type(type.typedef).type}"
    @output ""

  emit_imports : ({imports}) ->
    imports = uniqWith imports, isEqual
    imports_to_emit = imports.filter((imp) -> imp.path.indexOf('/') >= 0)

    for {import_as, path} in imports_to_emit
      @output "import * as #{import_as} from '#{path}'" if import_as
    @output "" if imports_to_emit.length > 0


  emit_fixed : (type) ->
    @output "export type #{type.name} = string | null"

  emit_field : ({name, type, jsonkey, optionalkey}) ->
    {type, optional} = @emit_field_type(type, {optionalkey})
    fieldName = camelCase(jsonkey or name)
    @output "#{fieldName}#{if optional then '?' else ''}: #{type}"

  emit_record : (record) ->
    @output "export type #{record.name} = {"
    @tab()
    fields = uniqWith record.fields, (a, b) ->
      camelCase(a.jsonkey or a.name) == camelCase(b.jsonkey or b.name)

    for f in fields
      @emit_field
        name : f.name
        type : f.type
        jsonkey : f.jsonkey
        optionalkey : f.optional
    @untab()
    @output "}"

  emit_enum : (type) ->
    @output "export enum #{type.name} {"
    @tab()
    for s, _ in type.symbols
      [e_name..., e_num] = s.split("_")
      e_name = e_name.join("_")
      @output "#{e_name} = '#{e_name.toLowerCase()}',"
    @untab()
    @output "}"

  emit_variant : (type) ->
    is_switch_primitive = is_primitive type.switch.type
    handled_cases = []
    case_strings = type.cases
      .map((type_case) =>
        if type_case.label.def then return null
        bodyType = switch
          when type_case.body == null then 'null'
          when typeof type_case.body == 'string' then @convert_primitive_type type_case.body
          when type_case.body.type == 'array' then @convert_primitive_type(type_case.body.items) + '[]'
          else
            throw new Error "Unrecognized type"

        handled_cases.push "#{type.switch.type}.#{type_case.label.name}"
        bodyStr = if type_case.body then ", '#{type_case.label.name}': #{bodyType}" else ''
        "{ #{type.switch.name}: #{if is_switch_primitive then '' else type.switch.type + '.'}#{type_case.label.name}#{bodyStr} }")
      .filter(Boolean)

    case_strings.push "{ #{type.switch.name}: Exclude<#{type.switch.type}, #{handled_cases.join ' | '}> }"

    @output "export type #{type.name} = #{case_strings.join(" | ")}"
    @output ""
