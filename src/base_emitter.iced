path_lib   = require 'path'
pkg        = require '../package.json'

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
    @emit_preface infiles, json, options
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
