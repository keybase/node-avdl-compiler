path_lib   = require 'path'
pkg        = require '../package.json'
{is_primitive} = require './utils'

###
An Emitter is a class that can transform a json ast from an avdl file to generated code in a language.

Each emitter supports a single language, and should be named of the form `LanguageEmitter` (e.g., GoEmitter, PythonEmitter, etc.)
BaseEmitter is an abstract base class that every emitter should inherit from. It should never be instantiated directly.
###
exports.BaseEmitter = class BaseEmitter
  constructor : () ->
    if this.constructor == BaseEmitter
      throw new Error "Can not construct abstract class."
    @_code = []
    @_tabs = 0


  tab : () -> @_tabs++
  untab : () -> @_tabs--
  tabs : () -> (@_tab_char for i in [0...@_tabs]).join("")

  output : (line, {frag} = {}) ->
    if @_last_frag
      @_code[@_code.length-1] += line
      @_last_frag = false
    else
      @_code.push (@tabs() + line)
    if frag
      @_last_frag = true
    else
      @_code.push("") if (line is "}" or line is ")") and @_tabs is 0


  get_field_type : (type) ->
    if typeof type is 'string'
      return type
    else
      if Array.isArray type
        return type[1]
      else if type.type is 'array'
        return @get_field_type type.items
      else if type.type is 'map'
        return @get_field_type type.values


  create_dep_graph : (types) ->
    graph = {}
    for type in types
      graph[type.name] = {type, in_count: 0, children: []}

    for type in types
      switch type.type
        when "record"
          if type.typedef and not is_primitive type.typedef
            graph[type.typedef].children = [type.name]
            graph[type.name].in_count++
          else
            for field in type.fields
              field_type = @get_field_type field.type
              if not is_primitive(field_type) and not graph[field_type].children.includes type.name
                graph[field_type].children.push type.name
                graph[type.name].in_count++
        when "variant"
          for case_ in type.cases
            if not case_.body?
              continue
            case_type = if typeof case_.body == 'object' then case_.body.items else case_.body
            if not is_primitive(case_type) and not graph[case_type].children.includes type.name
              graph[case_type].children.push type.name
              graph[type.name].in_count++

    graph

  sort_types : (types) ->
    graph = @create_dep_graph types

    # Topological sort
    res_types = []
    prev_length = Object.keys(graph).length
    while Object.keys(graph).length > 0
      sources = Object.values(graph).filter((node) => node.in_count == 0)
      for type in sources
        res_types.push type.type
        for child in type.children
          graph[child].in_count--
        delete graph[type.type.name]
      if Object.keys(graph).length == prev_length
        # we're in a cycle, break with everything appended
        res_types.concat Object.keys(graph).map((type) -> type.type)
        break
      prev_length = Object.keys(graph).length

    res_types

  ###
  Runs the emitter.

  `run` takes 4 arguments:
   - `infiles`: An array of strings. Each element is the path to an input file.
   - `outfile`: The file to output.
   - `json`: A representation of our abstract syntax tree
   - `options`
     - `types_only`: Whether just types or types and interfaces should be generated

  Returns an array of strings, with each element corresponding to the ith line of the output code.
  ###
  run : ({infiles, outfile, json, options}) ->
    options = {} unless options?
    infiles.sort()
    json.types = @sort_types json.types
    @create_dep_graph json.types
    @emit_preface infiles, json, options
    console.log 'outfile:', outfile
    @emit_imports json, outfile, options
    @emit_types json
    @emit_interface json unless options.types_only
    @_code


  ###
  Emits a preface to the generated file noting information such as the output language, package name, input files, and version of the compiler.

  Arguments:
   - `infiles`: An array of strings. Each element is the path to an input file
   - `json`: A representation of our abstract syntax tree
   - `options`
     - `types_only`: Whether just types or types and interfaces should be generated
  ###
  emit_preface : (infiles, json, {types_only}) ->
    throw new Error "emit_preface should be implemented by the child class"

  ###
  Emits a preface to the generated file noting information such as the output language, package name, input files, and version of the compiler.

  Arguments:
   - `json`: A representation of our abstract syntax tree
   - `outfile`: A string representing the output file
   - `types_only`: Whether just types or types and interfaces should be generated
  ###
  emit_imports : (json, outfile, {types_only}) ->
    throw new Error "emit_imports should be implemented by the child class"


  ###
  Emits all types defined in the input avro file.

  Arguments:
   - `json`: A representation of our abstract syntax tree
  ###
  emit_types : ({types}) ->
    for type in types
      @emit_type type

  ###
  Emit a single type.

  Arguments:
   - `type`: A representation of our type in the abstract syntax tree
  ###
  emit_type : (type) ->
    @output_doc type.doc
    switch type.type
      when "record"
        if type.typedef
          @emit_typedef type
        else
          @emit_record type
      when "fixed"
        @emit_fixed type
      when "enum"
        nostring = (type.go is "nostring")
        @emit_enum type, nostring
      when "variant"
        @emit_variant type
      else
        throw new Error "Unrecognized type: #{type}"

  ###
  Output any documentation comments associated with a type.

  Arguments:
   - `doc`: The doc string that should be emitted.
  ###
  output_doc : (doc) ->
    throw new Error "output_doc should be implemented by the child class"


  ###
  Emit a type alias.
  Ref: https://avro.apache.org/docs/current/spec.html#Aliases

  Arguments:
   - `type`: The type object that should be emitted.
  ###
  emit_typedef : (type) ->
    throw new Error "emit_typedef should be implemented by the child class"

  ###
  Emit a record/object.
  Ref: https://avro.apache.org/docs/current/spec.html#schema_record

  Arguments:
   - `type`: The type object that should be emitted.
  ###
  emit_record : (type) ->
    throw new Error "emit_record should be implemented by the child class"

  ###
  Emit a fixed length field.
  Ref: https://avro.apache.org/docs/current/spec.html#Fixed

  Arguments:
   - `type`: The type object that should be emitted.
  ###
  emit_fixed : (type) ->
    throw new Error "emit_fixed should be implemented by the child class"

  ###
  Emit an enum.
  Ref: https://avro.apache.org/docs/current/spec.html#Enums

  Arguments:
   - `type`: The type object that should be emitted.
  ###
  emit_enum : (type) ->
    throw new Error "emit_enum should be implemented by the child class"

  ###
  Emits a variant.

  Variants are a custom Keybase extension to AVDL. See the below link for details.
  https://github.com/keybase/client/blob/master/protocol/docs/variants.md

  Arguments:
   - `type`: The type object that should be emitted.
  ###
  emit_variant : (type) ->
    throw new Error "emit_variant should be implemented by the child class"

  ###
  Emit all functions defined in the input file(s).

  Arguments:
   - `json`: A representation of our abstract syntax tree
  ###
  emit_interface : ({protocol, messages, doc}) ->
    throw new Error "emit_interface should be implemented by the child class"
