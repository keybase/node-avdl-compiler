{TypescriptEmitter} = require("./ts_emit")
pkg                 = require '../package.json'

describe "TypescriptEmitter", () ->
  emitter = null
  beforeEach () ->
    emitter = new TypescriptEmitter

  describe "emit_preface", () ->
    it "Should emit a preface", () ->
      emitter.emit_preface ["./my_test_file.avdl"], {namespace: "chat1"}
      code = emitter._code.join "\n"

      expect(code).toBe("""
      /*
       * chat1
       *
       * Auto-generated to TypeScript types by #{pkg.name} v#{pkg.version} (#{pkg.homepage})
       * Input files:
       * - my_test_file.avdl
       */\n
      """)
      return
    return

  describe "emit_typedef", () ->
    it "should emit a type definition/alias", () ->
      type = {
        type: "record"
        name: "BuildPaymentID"
        fields: []
        typedef: "string"
      }
      emitter.emit_typedef type
      code = emitter._code.join "\n"

      expect(code).toBe("""
        export type BuildPaymentID = string
      """)
      return
    return

  describe "emit_fixed", () ->
    it "Should return a type with the given name and a type of string | null", () ->
      emitter.emit_fixed { name: "FunHash", size: 32 }
      code = emitter._code.join "\n"

      expect(code).toBe("""
        export type FunHash = string | null
      """)
      return
    return

  describe "emit_enum", () ->
    it "Should emit an enum", () ->
      test_enum = {
        type: "enum",
        name: "AuditVersion",
        symbols: [
          "V0_0",
          "V1_1",
          "V2_2",
          "V3_3"
        ]
      }
      emitter.emit_enum test_enum
      code = emitter._code.join "\n"

      expect(code).toBe("""
        export enum AuditVersion {
          V0 = 0,
          V1 = 1,
          V2 = 2,
          V3 = 3,
        }\n
      """)
      return
    return

  describe "Name of the group", () ->

    return

  return
