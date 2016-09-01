#!/usr/bin/env iced

minimist = require 'minimist'
fs = require 'fs'
{make_esc} = require 'iced-error'
pkg = require '../package.json'

#====================================================================

is_one_way = (d) -> (d.notify? or d.oneway)

#====================================================================

exports.GoEmitter = class GoEmitter

  constructor : () ->
    @_code = []
    @_tabs = 0
    @_pkg = null

  go_translate_identifier : ({name, go_field_suffix, exported}) ->
    if exported then @go_export_case name, { go_field_suffix }
    else if go_field_suffix? then name + go_field_suffix
    else name

  go_export_case : (n, { go_field_suffix } = {} ) ->
    ret = n[0].toUpperCase() + n[1...]
    ret = @go_lint_capitalize ret
    if go_field_suffix? then ret += go_field_suffix
    return ret

  go_lint_capitalize : (n) ->
    n = n.replace /pgp/g, "PGP"
    n = n.replace /Pgp/g, "PGP"
    n

  go_package : (n) -> n.replace(/[.-]/g, "")

  go_primitive_type : (m) ->
    map =
      boolean : "bool"
      bytes : "[]byte"
      long : "int64"
      float : "float32"
      double : "float64"
    map[m] or m

  is_primitive_switch_type : (m) -> m in [ "boolean", "long", "int" ]

  tabs : () -> ("\t" for i in [0...@_tabs]).join("")
  output : (l) ->
    @_code.push (@tabs() + l)
    @_code.push("") if (l is "}" or l is ")") and @_tabs is 0

  output_doc : (d) ->
    if d?
      for line in d.split /\n/
        @output "// " + line.replace /^\s*/, ''

  tab : () -> @_tabs++
  untab : () -> @_tabs--

  emit_field_type : (t, {pointed} = {}) ->
    optional = !!pointed
    type = if typeof(t) is 'string' then @go_primitive_type(t)
    else if typeof(t) is 'object'
      if Array.isArray(t) and not t[0]?
        optional = true
        "*" + @go_primitive_type(t[1])
      else if t.type is "array" then "[]" + @go_primitive_type(t.items)
      else if t.type is "map" then "map[string]" + @go_primitive_type(t.values)
      else "ERROR"
    else "ERROR"
    type = "*" + type if pointed
    { type , optional }

  #
  # An example of an AVDL "typedef":
  #
  # @typedef("string")
  # record Obj {}
  #
  emit_typedef : (t) ->
    @output "type #{t.name} #{@emit_field_type(t.typedef).type}"
    true

  codec : (name, optional) ->
    omitempty = if optional then ",omitempty" else ""
    "`codec:\"#{name}#{omitempty}\" json:\"#{name}#{omitempty}\"`"

  emit_field : ({name, type, go_field_suffix, exported, pointed}) ->
    {type, optional} = @emit_field_type(type, {pointed})
    @output [
      @go_translate_identifier({ name, go_field_suffix, exported }),
      @go_lint_capitalize(type),
      @codec(name, optional)
    ].join "\t"

  emit_record : ({obj, go_field_suffix}) ->
    @output "type #{@go_export_case(obj.name)} struct {"
    @tab()
    for f in obj.fields
      @emit_field { name : f.name, type : f.type, go_field_suffix, exported : true }
    @untab()
    @output "}"

  go_unsnake : ({n, is_private}) ->
    parts = n.split /_+/
    recase = (n,i) -> if (is_private and i is 0) then n.toLowerCase() else (n[0].toUpperCase() + n[1...].toLowerCase())
    (recase(part,i) for part,i in parts).join("")

  case_label_to_go : ({label, prefixed, is_private}) ->
    if not label? then "Default"
    else if typeof label is 'number'
      if prefixed then "Int" + label
      else label.toString()
    else @go_unsnake { n : label.toString(), is_private }

  emit_variant_tag_getter : ({obj, go_field_suffix}) ->
    {type, optional} = @emit_field_type(obj.switch.type, {pointed : false})
    ret_type = type
    fname = @go_translate_identifier { name : obj.switch.name, exported : true }
    @output "func (o *#{@go_export_case(obj.name)}) #{fname}() #{ret_type} {"
    @tab()
    @output "return o.#{@variant_field(obj.switch.name)}"
    @untab()
    @output "}"

  emit_variant_case_getters : ({obj, go_field_suffix}) ->
    cases = []
    def = null
    for c in obj.cases
      if not c.label.def
        cases.push @emit_variant_case_getter { obj, c : c, go_field_suffix }
      else
        def = c
    if def and def.body?
      cases.push @emit_variant_case_getter { obj, c : def, go_field_suffix, cases, def : true }

  variant_suffix : () -> "__"
  variant_field : (name) ->
    @go_translate_identifier {name, go_field_suffix : @variant_suffix(), exported : true }

  emit_variant_case_getter : ({obj, c, go_field_suffix, cases, def}) ->
    {type, optional} = @emit_field_type(c.body, {pointed : false})
    ret_type = type
    go_label = @case_label_to_go { label : c.label.name, prefixed : true }
    tag_val = c.label.name
    unless @is_primitive_switch_type obj.switch.type
      tag_val = @go_lint_capitalize(obj.switch.type) + "_" + tag_val
    @output "func (o #{@go_export_case(obj.name)}) #{go_label}() #{ret_type} {"
    @tab()
    if def
      cases = ("o.#{@variant_field(obj.switch.name)} == #{v}" for v in cases)
      @output "if #{cases.join(" || ")} {"
    else
      @output "if o.#{@variant_field(obj.switch.name)} != #{tag_val} {"
    @tab()
    @output """panic("wrong case accessed")"""
    @untab()
    @output "}"
    @output "return *o.#{@variant_field(go_label)}"
    @untab()
    @output "}"
    return tag_val

  emit_variant_getters : ({obj, go_field_suffix}) ->
    @emit_variant_tag_getter { obj, go_field_suffix }
    @emit_variant_case_getters { obj, go_field_suffix }

  emit_variant_constructors : ({obj, go_field_suffix}) ->
    for c in obj.cases
      @emit_variant_case_constructor { obj, c : c, go_field_suffix }

  emit_variant_case_constructor : ({obj, c, go_field_suffix}) ->
    if c.body?
      {type} = @emit_field_type(c.body, {pointed : false})
      case_type = type

    klass = @go_export_case(obj.name)

    go_label_prefixed   = @case_label_to_go { label : c.label.name, prefixed : true }
    go_label_unprefixed = @case_label_to_go { label : c.label.name, prefixed : false }

    if not c.label.def
      tag_val = c.label.name
      unless @is_primitive_switch_type obj.switch.type
        tag_val = @go_lint_capitalize(obj.switch.type) + "_" + tag_val
      @output "func New#{klass}With#{go_label_unprefixed}(v #{case_type}) #{klass} {"
    else if c.body?
      @output "func New#{klass}Default(#{obj.switch.name} #{obj.switch.type}, v #{case_type}) #{klass} {"
      tag_val = obj.switch.name
    else
      @output "func New#{klass}Default(#{obj.switch.name} #{obj.switch.type}) #{klass} {"
      tag_val = obj.switch.name
    @tab()
    @output "return #{klass}{"
    @tab()
    @output "#{@variant_field(obj.switch.name)} : #{tag_val},"
    if c.body?
      @output "#{@variant_field(go_label_prefixed)} : &v,"
    @untab()
    @output "}"
    @untab()
    @output "}"

  emit_variant : ({obj, go_field_suffix}) ->
    @emit_variant_object { obj, go_field_suffix }
    @emit_variant_getters { obj, go_field_suffix }
    @emit_variant_constructors { obj, go_field_suffix }

  emit_variant_object : ({obj, go_field_suffix}) ->
    @output "type #{@go_export_case(obj.name)} struct {"
    @tab()
    go_field_suffix = @variant_suffix()
    @emit_field { name : obj.switch.name, type : obj.switch.type, go_field_suffix, exported : true }
    for {label,body} in obj.cases when body?
      name = @case_label_to_go { label : label.name, prefixed : true, is_private : true }
      @emit_field { name : name, type : body, exported : true , pointed : true, go_field_suffix }
    @untab()
    @output "}"

  emit_fixed : (t) ->
    @output "type #{t.name} [#{t.size}]byte"

  emit_types : ({types, go_field_suffix}) ->
    for type in types
      @emit_type { type, go_field_suffix }

  count_variants : ({types}) ->
    ret = 0
    for type in types when type.type is "variant"
      ret++
    return ret

  emit_type : ({type, go_field_suffix}) ->
    @output_doc type.doc
    switch type.type
      when "record"
        if type.typedef
          @emit_typedef type
        else
          @emit_record { obj : type, go_field_suffix }
      when "fixed"
        @emit_fixed type
      when "enum"
        @emit_enum type
      when "variant"
        @emit_variant { obj : type, go_field_suffix }

  emit_enum : (t) ->
    name = t.name
    @output "type #{name} int"
    @output "const ("
    @tab()
    for s, i in t.symbols
      i = s.split("_").pop(-1);
      s = s.replace("_" + i, "");
      @output "#{name}_#{s} #{name} = #{i}"
    @untab()
    @output ")"

    @output "var #{name}Map = map[string]#{name}{"
    @tab()
    for s, i in t.symbols
      i = s.split("_").pop(-1);
      s = s.replace("_" + i, "");
      @output "\"#{s}\" : #{i},"
    @untab()
    @output "}"

  emit_wrapper_objects : ({messages}) ->
    for k,v of messages
      @emit_wrapper_object { name : k, details : v }

  emit_wrapper_object : ({name, details}) ->
    args = details.request
    klass_name = @go_export_case(name) + "Arg"
    obj =
      name : klass_name
      fields : args
    @emit_record { obj }
    details.request = {
      type : klass_name
      name : "__arg"
      wrapper : true
      nargs : args.length
      single : if args.length is 1 then args[0] else null
    }

  emit_interface : ({protocol, messages, doc}) ->
    @emit_wrapper_objects { messages }
    @emit_interface_server { protocol, messages, doc }
    @emit_interface_client { protocol, messages }

  emit_interface_client : ({protocol, messages}) ->
    p = @go_export_case protocol
    @output "type #{p}Client struct {"
    @tab()
    @output "Cli rpc.GenericClient"
    @untab()
    @output "}"
    for k,v of messages
      @emit_message_client { protocol, name : k, details : v, async : false }

  emit_package : ({namespace}) ->
    @output "package #{@go_package namespace}"
    @output ""
    @_pkg = namespace

  emit_imports : ({imports, messages, types}) ->
    @output "import ("
    @tab()
    @output 'rpc "github.com/keybase/go-framed-msgpack-rpc"'
    @output 'context "golang.org/x/net/context"' if Object.keys(messages).length > 0
    for {import_as, path} in imports when path.indexOf('/') >= 0
      line = ""
      line = import_as + " " if import_as?
      line += '"' + path + '"'
      @output line
    @untab()
    @output ")"
    @output ""

  emit_interface_server : ({protocol, messages, doc}) ->
    p = @go_export_case protocol
    @output_doc doc
    @output "type #{p}Interface interface {"
    @tab()
    for k,v of messages
      @emit_message_server { name : k, details : v }
    @untab()
    @output "}"
    @emit_protocol_server { protocol, messages }

  emit_server_hook : ({name, details}) ->
    arg = details.request
    res = details.response
    resvar = if res? then "ret, " else ""
    @output """"#{name}": {"""
    @tab()
    @emit_server_hook_make_arg { name, details }
    @emit_server_hook_make_handler { name, details }
    @emit_server_hook_method_type { name, details }
    @untab()
    @output "},"

  emit_server_hook_make_arg : ({name, details}) ->
    arg = details.request
    @output "MakeArg: func() interface{} {"
    @tab()

    # Over the wire, we're expecting either an empty argument array,
    # or an array with one T in it. So we have to pass the decoder
    # a pointer to a slice of T's. This is a little bit convoluted
    # but we're obeying the msgpack spec (which says RPCs take arrays
    # of arguments) and also the library's attempts to avoid unnecessary
    # copies of objects as they are passed from MakeArg, through the
    # decoder, and back into the Handler specified below.
    @output "ret := make([]#{@go_primitive_type(arg.type)}, 1)"
    @output "return &ret"
    @untab()
    @output "},"

  emit_server_hook_method_type : ({name, details}) ->
    @output "MethodType: rpc.Method#{if is_one_way(details) then 'Notify' else 'Call'},"

  emit_server_hook_make_handler : ({name, details}) ->
    arg = details.request
    res = details.response
    resvar = if res? then "ret, " else ""
    pt = @go_primitive_type arg.type
    @output "Handler: func(ctx context.Context, args interface{}) (ret interface{}, err error) {"
    @tab()
    if arg.nargs > 0
      @output "typedArgs, ok := args.(*[]#{pt})"
      @output "if !ok {"
      @tab()
      @output "err = rpc.NewTypeError((*[]#{pt})(nil), args)"
      @output "return"
      @untab()
      @output "}"
    farg = if arg.nargs is 0 then ''
    else
      access = if arg.nargs is 1 then ".#{@go_export_case arg.single.name}" else ''
      "(*typedArgs)[0]#{access}"
    @output "#{resvar}err = i.#{@go_export_case(name)}(ctx, #{farg})"
    @output "return"
    @untab()
    @output "},"

  emit_protocol_server : ({protocol, messages}) ->
    p = @go_export_case protocol
    @output "func #{p}Protocol(i #{p}Interface) rpc.Protocol {"
    @tab()
    @output "return rpc.Protocol {"
    @tab()
    @output """Name: "#{@_pkg}.#{protocol}","""
    @output "Methods: map[string]rpc.ServeHandlerDescription{"
    @tab()
    for k,v of messages
      @emit_server_hook { name : k, details : v }
    @untab()
    @output "},"
    @untab()
    @output "}"
    @untab()
    @output "}"

  emit_message_server : ({name, details}) ->
    arg = details.request
    res = details.response
    args = if arg.nargs then "#{(@emit_field_type (arg.single or arg).type ).type}" else ""
    res_types = []
    if res? then res_types.push @go_lint_capitalize(@emit_field_type(res).type)
    res_types.push "error"
    @output_doc details.doc
    @output "#{@go_export_case(name)}(context.Context, #{args}) (#{res_types.join ","})"


  emit_message_client: ({protocol, name, details, async}) ->
    p = @go_export_case protocol
    arg = details.request
    res = details.response
    out_list = []
    if res?
      out_list.push "res #{@go_lint_capitalize(@emit_field_type(res).type)}"
      res_in = "&res"
    else
      res_in = "nil"
    out_list.push "err error"
    outs = out_list.join ","
    params = if arg.nargs is 0 then ""
    else
      parg = arg.single or arg
      "#{parg.name} #{(@emit_field_type parg.type).type}"
    @output_doc details.doc
    @output "func (c #{p}Client) #{@go_export_case(name)}(ctx context.Context, #{params}) (#{outs}) {"
    @tab()
    if arg.nargs is 1
      n = arg.single.name
      @output "#{arg.name} := #{arg.type}{ #{@go_export_case n} : #{n} }"
    oarg = "[]interface{}{"
    oarg += if arg.nargs is 0 then "#{arg.type}{}"
    else arg.name
    oarg += "}"
    ow = is_one_way(details)
    res = if ow then "" else ", #{res_in}"
    @output """err = c.Cli.#{if ow then "Notify" else "Call"}(ctx, "#{@_pkg}.#{protocol}.#{name}", #{oarg}#{res})"""
    @output "return"
    @untab()
    @output "}"

  emit_preface : ({infile}) ->
    @output "// Auto-generated by #{pkg.name} v#{pkg.version} (#{pkg.homepage})"
    @output "//   Input file: #{infile}"
    @output ""

  run : ({infile, json}) ->
    @emit_preface {infile}
    @emit_package json
    @emit_imports json
    @emit_types json
    @emit_interface json
    @_code

#====================================================================
