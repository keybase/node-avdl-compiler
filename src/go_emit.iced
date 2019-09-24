#!/usr/bin/env iced

minimist   = require 'minimist'
path_lib   = require 'path'
fs         = require 'fs'
{make_esc} = require 'iced-error'
{BaseEmitter} = require './base_emitter'
pkg        = require '../package.json'

#====================================================================

is_one_way = (d) -> (d.notify? or d.oneway)

#====================================================================

exports.GoEmitter = class GoEmitter extends BaseEmitter
  constructor : () ->
    super
    @_tab_char = '\t'
    @_pkg = null
    @_default_compression_type = "none"

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

  go_compression_type : (m) ->
    map =
      none : "rpc.CompressionNone"
      gzip : "rpc.CompressionGzip"
      msgpackzip : "rpc.CompressionMsgpackzip"
    map[m] or m

  is_primitive_switch_type : (m) -> m in [ "boolean", "long", "int" ]

  append_to_last : (s) ->
    @_code[@_code.length-1] += s

  output_doc : (d) ->
    if d?
      for line in d.split /\n/
        @output "// " + line.replace /^\s*/, ''

  make_map_type : ({t}) ->
    key = if t.keys? then @emit_field_type(t.keys).type else "string"
    "map[#{key}]" + @emit_field_type(t.values).type

  emit_field_type : (t, {pointed, optionalkey} = {}) ->
    optional = !!pointed or optionalkey
    type = if typeof(t) is 'string' then @go_primitive_type(t)
    else if typeof(t) is 'object'
      if Array.isArray(t)
        if not t[0]?
          optional = true
          "*" + @emit_field_type(t[1]).type
        else
          throw new Error "Unrecognized type"
      else if t.type is "array"
        "[]" + @emit_field_type(t.items).type
      else if t.type is "map"
        @make_map_type { t }
      else
        throw new Error "Unrecognized type"
    else
      throw new Error "Unrecognized type"
    type = "*" + type if pointed
    { type , optional }

  emit_typedef_deep_copy : ({t}) ->
    type = t.name
    receiver = "o"
    @output "func (#{receiver} #{type}) DeepCopy() #{type} {"
    @tab()
    @output "return ", {frag : true }
    @deep_copy { t : t.typedef, val : receiver, exported : true }
    @untab()
    @output "}"

  #
  # An example of an AVDL "typedef":
  #
  # @typedef("string")
  # record Obj {}
  #
  emit_typedef : (t) ->
    @output "type #{t.name} #{@emit_field_type(t.typedef).type}"
    @emit_typedef_deep_copy { t }
    true

  codec : ({name, optional, jsonkey, mpackkey}) ->
    omitempty = if optional then ",omitempty" else ""
    unless jsonkey?
      jsonkey = name
    unless mpackkey?
      mpackkey = name
    "`codec:\"#{mpackkey}#{omitempty}\" json:\"#{jsonkey}#{omitempty}\"`"

  emit_field : ({name, type, go_field_suffix, exported, optionalkey, pointed, jsonkey, mpackkey}) ->
    {type, optional} = @emit_field_type(type, {pointed, optionalkey})
    cols = [
      @go_translate_identifier({ name, go_field_suffix, exported }),
      @go_lint_capitalize(type)
    ]
    cols.push(@codec({name, optional, jsonkey, mpackkey})) if exported
    @output cols.join("\t")

  emit_record : (obj, {go_field_suffix, no_deep_copy} = {}) ->
    @emit_record_struct { obj, go_field_suffix }
    @emit_record_deep_copy { obj, go_field_suffix } unless no_deep_copy

  emit_record_struct : ({obj, go_field_suffix}) ->
    @output "type #{@go_export_case(obj.name)} struct {"
    @tab()
    if obj.layout is 'array'
      @output ["_struct", "bool", "`codec:\",toarray\"`" ].join("\t")

    for f in obj.fields
      @emit_field
        name : f.name
        type : f.type
        go_field_suffix: go_field_suffix
        exported : not(f.internal?)
        optionalkey : f.optional
        jsonkey : f.jsonkey
        mpackkey : f.mpackkey
    @untab()
    @output "}"

  deep_copy : ( {t, val, exported}) ->
    if not(exported) then @output val
    else if typeof(t) is 'string'
      if t is 'bytes'
        @deep_copy_bytes { t, val }
      else
        @deep_copy_simple { t, val }
    else if typeof(t) isnt 'object'
      @output "ERROR"
    else if Array.isArray(t)
      if t[0]? then @output "ERROR"
      else @deep_copy_pointer { t , val }
    else if t.type is 'array'
      @deep_copy_array { t, val }
    else if t.type is 'map'
      @deep_copy_map { t, val }
    else
      @output "ERROR"


  # We're not really supposed to have 'bool' or 'int64' AVDL types but
  # they do show up from time to time. So handle them properly.
  is_primitive_type_lax : (t) ->
    t in [
      'int64', 'long', 'int',
      'float', 'double',
      'string',
      'boolean', 'bool', 'uint', 'unsigned', 'uint64'
    ]

  deep_copy_bytes : ({t,val}) ->
    type = @emit_field_type(t).type
    @deep_copy_preamble {type}
    @output "if x == nil {"
    @tab()
    @output "return nil"
    @untab()
    @output "}"
    @output "return append([]byte{}, x...)"
    @deep_copy_postamble { val }

  deep_copy_simple : ({t, val}) ->
    if not @is_primitive_type_lax(t) then val += ".DeepCopy()"
    @output val

  deep_copy_preamble : ({type}) ->
    @output "(func (x #{type}) #{type} {"
    @tab()

  deep_copy_postamble : ({val}) ->
    @untab()
    @output "})(#{val})"

  deep_copy_pointer : ({t, val}) ->
    type = @emit_field_type(t).type
    @deep_copy_preamble {type}
    @output "if x == nil {"
    @tab()
    @output "return nil"
    @untab()
    @output "}"
    @output "tmp := ", {frag : true }
    @deep_copy { t : t[1], val : "(*x)", exported : true }
    @output "return &tmp"
    @deep_copy_postamble { val }

  deep_copy_array : ({t, val}) ->
    type = @emit_field_type(t).type
    @deep_copy_preamble {type}
    @output "if x == nil {"
    @tab()
    @output "return nil"
    @untab()
    @output "}"
    @output "ret := make(#{type}, len(x))"
    @output "for i, v := range x {"
    @tab()
    @output "vCopy := ", { frag : true }
    @deep_copy { t : t.items, val : "v", exported : true  }
    @output "ret[i] = vCopy"
    @untab()
    @output "}"
    @output "return ret"
    @deep_copy_postamble { val }

  deep_copy_map : ({t, val}) ->
    type = @emit_field_type(t).type
    @deep_copy_preamble { type }
    @output "if x == nil {"
    @tab()
    @output "return nil"
    @untab()
    @output "}"
    @output "ret := make(#{type}, len(x))"
    @output "for k, v := range x {"
    @tab()
    if t.keys?
      @output "kCopy := ", {frag : true}
      @deep_copy { t : t.keys, val : "k", exported : true }
    else
      @output "kCopy := k"
    @output "vCopy := ", {frag : true}
    @deep_copy { t : t.values, val : "v", exported : true }
    @output "ret[kCopy] = vCopy"
    @untab()
    @output "}"
    @output "return ret"
    @deep_copy_postamble { val }

  emit_deep_copy_field : ({t, name, go_field_suffix, receiver, exported}) ->
    field = @go_translate_identifier { name : name, go_field_suffix, exported }
    @output (field + ": "), { frag : true }
    @deep_copy { t, val : "#{receiver}.#{field}" , exported }
    @append_to_last ","

  emit_record_deep_copy : ({obj, go_field_suffix}) ->
    type = @go_export_case(obj.name)
    receiver = "o"
    @output "func (#{receiver} #{type}) DeepCopy() #{type} {"
    @tab()
    @output "return #{type}{"
    @tab()
    for f in obj.fields
      @emit_deep_copy_field { t : f.type, name : f.name, go_field_suffix, receiver, exported : not(f.internal?) }
    @untab()
    @output "}"
    @untab()
    @output "}"

  go_unsnake : ({n, is_private}) ->
    parts = n.split /_+/
    recase = (n,i) -> if (is_private and i is 0) then n.toLowerCase() else (n[0].toUpperCase() + n[1...].toLowerCase())
    (recase(part,i) for part,i in parts).join("")

  case_label_to_go : ({label, prefixed, is_private}) ->
    tmp = if not label? then "Default"
    else if typeof label is 'number'
      if prefixed then "Int" + label
      else label.toString()
    else label.toString()
    @go_unsnake { n : tmp, is_private }

  emit_variant_tag_getter : ({obj, go_field_suffix}) ->
    {type, optional} = @emit_field_type(obj.switch.type, {pointed : false})
    ret_type = type
    fname = @go_translate_identifier { name : obj.switch.name, exported : true }
    @output "func (o *#{@go_export_case(obj.name)}) #{fname}() (ret #{ret_type}, err error) {"
    @tab()
    @output "switch (o.#{@variant_field(obj.switch.name)}) {"
    @tab()
    for c in obj.cases when c.body
      field = @variant_field @case_label_to_go { label : c.label.name, prefixed : true }
      if c.label.name?
        @output "case " + (@variant_switch_value { c, obj }) + ":"
      else
        @output "default:"
      @tab()
      @output "if o.#{field} == nil {"
      @tab()
      @output """err = errors.New("unexpected nil value for #{field}")"""
      @output "return ret, err"
      @untab()
      @output "}"
      @untab()
    @untab()
    @output "}"
    @output "return o.#{@variant_field(obj.switch.name)}, nil"
    @untab()
    @output "}"

  emit_variant_case_getters : ({obj, go_field_suffix}) ->
    cases = []
    def = null
    for c in obj.cases
      if c.label.def
        def = c
      else if c.body?
        cases.push @emit_variant_case_getter { obj, c : c, go_field_suffix }
    if def and def.body?
      cases.push @emit_variant_case_getter { obj, c : def, go_field_suffix, cases, def : true }

  variant_suffix : () -> "__"
  variant_field : (name) ->
    @go_translate_identifier {name, go_field_suffix : @variant_suffix(), exported : true }

  variant_switch_value : ({obj, c }) ->
    tag_val = c.label.name
    unless @is_primitive_switch_type obj.switch.type
      tag_val = @go_lint_capitalize(obj.switch.type) + "_" + tag_val
    return tag_val

  emit_variant_case_getter : ({obj, c, go_field_suffix, cases, def}) ->
    {type, optional} = @emit_field_type(c.body, {pointed : false})
    ret_type = type
    go_label = @case_label_to_go { label : c.label.name, prefixed : true }
    tag_val = @variant_switch_value { obj, c }

    @output "func (o #{@go_export_case(obj.name)}) #{go_label}() (res #{ret_type}) {"
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
    @output "if o.#{@variant_field(go_label)} == nil {"
    @tab()
    @output "return"
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
      if c.body?
        @output "func New#{klass}With#{go_label_unprefixed}(v #{case_type}) #{klass} {"
      else
        @output "func New#{klass}With#{go_label_unprefixed}() #{klass} {"
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
    @emit_variant_deep_copy { obj, go_field_suffix  }

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

  emit_variant_deep_copy : ({obj, go_field_suffix}) ->
    go_field_suffix = @variant_suffix()
    type = @go_export_case(obj.name)
    receiver = "o"
    @output "func (#{receiver} #{type}) DeepCopy() #{type} {"
    @tab()
    @output "return #{type} {"
    @tab()
    @emit_deep_copy_field { t : obj.switch.type, name : obj.switch.name, go_field_suffix, receiver, exported : true }
    for {label,body} in obj.cases when body?
      name = @case_label_to_go { label : label.name, prefixed : true, is_private : true }
      # Cute hack here -- recall that the body is a pointer type since it might be null,
      # so use our internal representation of `union { null, T }` for the bodies. This
      # is done via [ null, body ] just below.
      @emit_deep_copy_field { t : [ null, body ], name : name, go_field_suffix, receiver, exported : true }
    @untab()
    @output "}"
    @untab()
    @output "}"

  emit_fixed_deep_copy : ({t}) ->
    type = t.name
    @output "func (o #{type}) DeepCopy() #{type} {"
    @tab()
    @output "var ret #{type}"
    @output "copy(ret[:], o[:])"
    @output "return ret"
    @untab()
    @output "}"

  emit_fixed : (t) ->
    @output "type #{t.name} [#{t.size}]byte"
    @emit_fixed_deep_copy { t }

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
          @emit_record type, { go_field_suffix }
      when "fixed"
        @emit_fixed type
      when "enum"
        nostring = (type.go is "nostring")
        @emit_enum type, nostring
      when "variant"
        @emit_variant { obj : type, go_field_suffix }

  emit_enum : (t, nostring) ->
    # Type and constants
    name = t.name
    @output "type #{name} int"
    @output "const ("
    @tab()
    for s, _ in t.symbols
      [e_name..., e_num] = s.split("_")
      e_name = e_name.join("_")
      @output "#{name}_#{e_name} #{name} = #{e_num}"
    @untab()
    @output ")"
    @output "func (o #{name}) DeepCopy() #{name} { return o }"

    # Forward map
    @output "var #{name}Map = map[string]#{name}{"
    @tab()
    for s, i in t.symbols
      [e_name..., e_num] = s.split("_")
      e_name = e_name.join("_")
      @output "\"#{e_name}\": #{e_num},"
    @untab()
    @output "}"

    # Reverse map
    @output "var #{name}RevMap = map[#{name}]string{"
    @tab()
    for s, i in t.symbols
      [e_name..., e_num] = s.split("_")
      e_name = e_name.join("_")
      @output "#{e_num}: \"#{e_name}\","
    @untab()
    @output "}"

    unless nostring
      @output "func (e " + name + ") String() string {"
      @tab()
      @output "if v, ok := #{name}RevMap[e]; ok {"
      @tab()
      @output "return v"
      @untab()
      @output "}"
      @output "return \"\""
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
    @emit_record obj, { no_deep_copy : true }
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

  emit_package : ({namespace, compression_type}) ->
    if compression_type?
      @_default_compression_type = compression_type
    @output "package #{@go_package namespace}"
    @output ""
    @_pkg = namespace

  emit_imports : ({imports, messages, types}, outfile, {types_only}) ->
    @output "import ("
    @tab()
    if not types_only
      @output '"github.com/keybase/go-framed-msgpack-rpc/rpc"'
      @output 'context "golang.org/x/net/context"' if Object.keys(messages).length > 0

    prefix = process.env.GOPATH + '/src/'
    relative_file = path_lib.resolve(outfile).replace(prefix, "")
    relative_dir = path_lib.dirname(relative_file)

    for {import_as, path} in imports when path.indexOf('/') >= 0
      if path.match /(\.\/|\.\.\/)/
        path = path_lib.normalize(relative_dir + "/" + path)
      line = ""
      line = import_as + " " if import_as?
      line += '"' + path + '"'
      @output line
    if @count_variants({types}) > 0
      @output '"errors"'
    if Object.keys(messages).length > 0
      @output '"time"'
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
    @untab()
    @output "},"

  emit_server_hook_make_arg : ({name, details}) ->
    arg = details.request
    @output "MakeArg: func() interface{} {"
    @tab()

    # Over the wire, we're expecting either an empty argument array,
    # or an array with one T in it. So we have to pass the decoder
    # a pointer to a one-element T array. This is a little bit convoluted
    # but we're obeying the msgpack spec (which says RPCs take arrays
    # of arguments) and also the library's attempts to avoid unnecessary
    # copies of objects as they are passed from MakeArg, through the
    # decoder, and back into the Handler specified below.
    @output "var ret [1]#{@go_primitive_type(arg.type)}"
    @output "return &ret"
    @untab()
    @output "},"

  emit_server_hook_make_handler : ({name, details}) ->
    arg = details.request
    res = details.response
    resvar = if res? then "ret, " else ""
    pt = @go_primitive_type arg.type
    @output "Handler: func(ctx context.Context, args interface{}) (ret interface{}, err error) {"
    @tab()
    if arg.nargs > 0
      @output "typedArgs, ok := args.(*[1]#{pt})"
      @output "if !ok {"
      @tab()
      @output "err = rpc.NewTypeError((*[1]#{pt})(nil), args)"
      @output "return"
      @untab()
      @output "}"
    farg = if arg.nargs is 0 then ''
    else
      access = if arg.nargs is 1 then ".#{@go_export_case arg.single.name}" else ''
      "typedArgs[0]#{access}"
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
    ctype = ""
    call_method = "Call"
    unless ow
      ctype_in = if details.compression_type? then details.compression_type else @_default_compression_type
      # NOTE: This is for initial backwards compatibility so services can
      # understand `CallCompressed` before any client uses it. It also saves us
      # an int encoding `CompressionNone` on the wire.
      if ctype_in isnt "none"
        call_method = "CallCompressed"
        ctype = ", #{@go_compression_type(ctype_in)}"
    timeout = ", #{details.timeout_msec or 0} * time.Millisecond"

    @output """err = c.Cli.#{if ow then "Notify" else call_method}(ctx, "#{@_pkg}.#{protocol}.#{name}", #{oarg}#{res}#{ctype}#{timeout})"""
    @output "return"
    @untab()
    @output "}"

  emit_preface : (infiles, json, {types_only} = {}) ->
    @output "// Auto-generated to Go #{if types_only then 'types' else 'types and interfaces'} using #{pkg.name} v#{pkg.version} (#{pkg.homepage})"
    if infiles.length == 1
      @output "//   Input file: #{path_lib.relative(process.cwd(), infiles[0])}"
    else
      @output "//   Input files:"
      for infile in infiles
        @output "//   - #{path_lib.relative(process.cwd(), infiles)}"
    @output ""
    @emit_package json

#====================================================================
