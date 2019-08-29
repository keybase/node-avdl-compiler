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

  describe "emit_imports", () ->
    it "should not modify the given path", () ->
      imports = [
        {
          path: "../gregor1",
          type: "idl",
          import_as: "gregor1"
        },
        {
          path:  "github.com/keybase/client/go/protocol/keybase1",
          type: "idl",
          import_as: "keybase1"
        }
      ]
      emitter.emit_imports {imports, messages: {}, types: []}, 'location/of/my/output.go'
      code = emitter._code.join "\n"
      expect(code).toBe("""
        import * as gregor1 from '../gregor1'
        import * as keybase1 from 'github.com/keybase/client/go/protocol/keybase1'\n
      """)

      return

    it "should ignore packages without an import_as field", () ->
      imports = [
        {
          path: "../common.avdl",
          type: "idl",
        }
      ]
      emitter.emit_imports {imports, messages: {}, types: []}, 'location/of/my/output.go'
      code = emitter._code.join "\n"
      expect(code).toBe("")
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

  describe "emit_record", () ->
    it "should emit an ojbect with primative value keys", () ->
      record = {
        type: "record"
        name: "TestRecord"
        fields: [
          {
            type: "string",
            name: "statusDescription"
          },
          {
            type: "boolean"
            name: "isValidThing"
          },
          {
            type: "long",
            name: "longInt"
          },
          {
            type: "double",
            name: "doubleOrNothin"
          },
          {
            type: "bytes",
            name: "takeAByteOfThisApple"
          }
        ]
      }
      emitter.emit_record record
      code = emitter._code.join "\n"

      expect(code).toBe("""
        export type TestRecord = {
          statusDescription: string
          isValidThing: boolean
          longInt: number
          doubleOrNothin: number
          takeAByteOfThisApple: Buffer
        }\n
      """)
      return

    it "Should support custom types as fields", () ->
      record = {
        type: "record"
        name: "TestRecord"
        fields: [
          {
            type: "MySuperCoolCustomType",
            name: "superCool"
          },
        ]
      }
      emitter.emit_record record
      code = emitter._code.join "\n"

      expect(code).toBe("""
        export type TestRecord = {
          superCool: MySuperCoolCustomType
        }\n
      """)
      return

    it "Should emit a struct with an optional type", () ->
      record = {
        type: "record"
        name: "TestRecord"
        fields: [
          {
            type: [null, "string"],
            name: "maybeStatusDescription"
          }
        ]
      }
      emitter.emit_record record
      code = emitter._code.join "\n"

      expect(code).toBe("""
        export type TestRecord = {
          maybeStatusDescription?: string
        }\n
      """)
      return

    it "Should emit a struct with an array value", () ->
      record = {
        type: "record",
        name: "PaymentsPageLocal",
        fields: [
          {
            type: {
              type: "array",
              items: "PaymentOrErrorLocal"
            },
            name: "payments"
          },
        ]
      }
      emitter.emit_record record
      code = emitter._code.join "\n"

      expect(code).toBe("""
        export type PaymentsPageLocal = {
          payments: PaymentOrErrorLocal[]
        }\n
      """)
      return

    it "Should emit a struct with a map type", () ->
      record = {
        type: "record"
        name: "StellarServerDefinitions"
        fields: [
          {
            type: "int",
            name: "revision"
          },
          {
            type: {
              type: "map"
              values: "OutsideCurrencyDefinition"
              keys: "OutsideCurrencyCode"
            }
            name: "currencies"
          }
        ]
      }
      emitter.emit_record record
      code = emitter._code.join "\n"

      expect(code).toBe("""
        export type StellarServerDefinitions = {
          revision: number
          currencies: {[key: OutsideCurrencyCode]: OutsideCurrencyDefinition}
        }\n
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

  return
