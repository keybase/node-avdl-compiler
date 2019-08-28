path_lib   = require 'path'
{BaseEmitter} = require './base_emitter'
pkg        = require '../package.json'

exports.TypescriptEmitter = class TypescriptEmitter extends BaseEmitter
  constructor : () ->
    super
    @_tab_char = " ".repeat(2)

  emit_preface : (infiles, {namespace}) ->
    @output "/*"
    @output " * #{namespace}"
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
    map[m] or m

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

  emit_imports : ({imports}) ->
    imports = _.uniqWith imports, _.isEqual

    for {import_as, path} in imports when path.indexOf('/') >= 0
      if not import_as
        continue
      @output "import * as #{import_as} from '#{path}'"
    @output ""

  emit_fixed : (t) ->
    @output "export type #{t.name} = string | null"

  emit_enum : (t) ->
    @output "export enum #{t.name} {"
    @tab()
    for s, _ in t.symbols
      [e_name..., e_num] = s.split("_")
      e_name = e_name.join("_")
      @output "#{e_name} = #{e_num},"
    @untab()
    @output "}"
