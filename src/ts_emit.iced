path_lib   = require 'path'
{BaseEmitter} = require './base_emitter'
pkg        = require '../package.json'
_ = require('lodash')

exports.TypescriptEmitter = class TypescriptEmitter extends BaseEmitter
  constructor : () ->
    super
    @_tab_char = " ".repeat(2)

  emit_preface : (infiles, {namespace, doc}) ->
    @output "/*"
    @output " * #{namespace}"
    @output " * #{doc}" if doc
    @output " *"
    @output " * Auto-generated to TypeScript types by #{pkg.name} v#{pkg.version} (#{pkg.homepage})"
    @output " * Input files:"
    for infile in infiles
      @output " * - #{path_lib.relative(process.cwd(), infile)}"
    @output " */"
    @output ""

  output_doc : (d) ->
    if d?
      @output "/**"
      for line in d.split /\n/
        @output " * " + line.replace /^\s$/, ''
      @output " */"

  convert_primitive_type : (m) ->
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
    map[m] or m

  make_map_type : ({t}) ->
    "{[key: string]: #{@emit_field_type(t.values).type}}"

  emit_field_type : (t) ->
    optional = false
    type = if typeof(t) is 'string' then @convert_primitive_type(t)
    else if typeof(t) is 'object'
      if Array.isArray(t)
        if not t[0]?
          optional = true
          @emit_field_type(t[1]).type
        else
          "ERROR"
      else if t.type is "array"
        @emit_field_type(t.items).type + "[]"
      else if t.type is "map"
        @make_map_type { t }
      else "ERROR"
    else "ERROR"
    { type, optional }

  emit_typedef : (t) ->
    @output "export type #{t.name} = #{@emit_field_type(t.typedef).type}"
    @output ""

  emit_imports : ({imports}) ->
    imports = _.uniqWith imports, _.isEqual
    imports_to_emit = imports.filter((imp) -> imp.path.indexOf('/') >= 0)

    for {import_as, path} in imports_to_emit
      if not import_as
        continue
      @output "import * as #{import_as} from '#{path}'"
    @output "" if imports_to_emit.length > 0

  emit_fixed : (t) ->
    @output "export type #{t.name} = string | null"

  emit_field : ({name, type}) ->
    {type, optional} = @emit_field_type(type)
    @output "#{name}#{if optional then '?' else ''}: #{type}"

  emit_record : (obj) ->
    @output "export type #{obj.name} = {"
    @tab()
    for f in obj.fields
      @emit_field
        name : f.name
        type : f.type
        exported : not(f.internal?)
    @untab()
    @output "}"

  emit_enum : (t) ->
    @output "export enum #{t.name} {"
    @tab()
    for s, _ in t.symbols
      [e_name..., e_num] = s.split("_")
      e_name = e_name.join("_")
      @output "#{e_name} = #{e_num},"
    @untab()
    @output "}"

  emit_variant : (type) ->
    cases = type.cases
      .map((type_case) =>
        if type_case.label.def then return null
        bodyType = switch
          when type_case.body == null then 'null'
          when typeof type_case.body == 'string' then @convert_primitive_type type_case.body
          when type_case.body.type == 'array' then @convert_primitive_type(type_case.body.items) + '[]'
          else ''
        bodyStr = if type_case.body then ", #{type_case.label.name}: #{bodyType} | null" else ''
        "{ #{type.switch.name}: #{type.switch.type}.#{type_case.label.name}#{bodyStr} }")
      .filter(Boolean)
    @output "export type #{type.name} = #{cases.join(" | ")}"
    @output ""
