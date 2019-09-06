{TypescriptEmitter} = require("./ts_emit")
pkg                 = require '../package.json'

describe "TypescriptEmitter", () ->
  emitter = null
  beforeEach () ->
    emitter = new TypescriptEmitter

  describe "output_doc", () ->
    it "should output a TSDoc comment", () ->
      emitter.output_doc "This is a test comment with\na new line."
      code = emitter._code.join "\n"
      expect(code).toBe("""
        /**
         * This is a test comment with
         * a new line.
         */
      """)
      return
    return

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
        export type BuildPaymentID = string\n
      """)
      return
    return

  describe "emit_record", () ->
    it "should emit an object with primative value keys", () ->
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
          longInt: never
          doubleOrNothin: number
          takeAByteOfThisApple: Buffer
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
          },
          {
            type: "boolean",
            name: "offline",
            jsonkey: "offline",
            optional: true
          },
        ]
      }
      emitter.emit_record record
      code = emitter._code.join "\n"

      expect(code).toBe("""
        export type TestRecord = {
          maybeStatusDescription?: string
          offline?: boolean
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
          payments: PaymentOrErrorLocal[] | null
        }\n
      """)
      return

    it "Should use a field's name unless a json key is provided", () ->
      record = {
        type: "record",
        name: "SendRes",
        fields: [
          {
            type: "string",
            name: "message",
            jsonkey: "message"
          },
          {
            type: [
              null,
              "MessageID"
            ],
            name: "messageID",
            jsonkey: "id"
          }
        ]
      }
      emitter.emit_record record
      code = emitter._code.join "\n"

      expect(code).toBe("""
        export type SendRes = {
          message: string
          id?: MessageID
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
          currencies: {[key: string]: OutsideCurrencyDefinition}
        }\n
      """)
      return

    it "should remove duplicates", () ->
      record = {
        "type": "record",
        "name": "UnreadUpdate",
        "fields": [
          {
            type: "ConversationID",
            name: "convID"
          },
          {
            type: "int",
            name: "unreadMessages"
          },
          {
            type: "int",
            name: "compatUnreadMessages",
            mpackkey: "UnreadMessages",
            jsonkey: "UnreadMessages"
          }
        ]
      }
      emitter.emit_record record
      code = emitter._code.join "\n"

      expect(code).toBe("""
        export type UnreadUpdate = {
          convId: ConversationID
          unreadMessages: number
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
          V0 = 'v0',
          V1 = 'v1',
          V2 = 'v2',
          V3 = 'v3',
        }\n
      """)
      return
    return

  describe "emit_variant", () ->
    it "should emit a variant", () ->
      variant =
        type: "variant",
        name: "MyVariant",
        switch: {
          type: "InboxResType",
          name: "rtype"
        },
        cases: [
          {
            label: {
              name: "VERSIONHIT",
              def: false
            },
            body: null
          },
          {
            label: {
              name: "FULL",
              def: false
            },
            body: "InboxViewFull"
          },
          {
            label: {
              name: "HELLO",
              def: false
            },
            body: "bool"
          },
          {
            label: {
              name: "BLAH",
              def: true
            },
            body: "int"
          },
          {
            label: {
              name: "DECK",
              def: false
            },
            body: {
              type: "array",
              items: "int"
            }
          }
        ]
      emitter.emit_variant variant
      code = emitter._code.join "\n"

      expect(code).toBe("""
        export type MyVariant = { rtype: InboxResType.VERSIONHIT } | { rtype: InboxResType.FULL, 'FULL': InboxViewFull | null } | { rtype: InboxResType.HELLO, 'HELLO': boolean | null } | { rtype: InboxResType.DECK, 'DECK': number[] | null } | { rtype: Exclude<InboxResType, InboxResType.VERSIONHIT | InboxResType.FULL | InboxResType.HELLO | InboxResType.DECK> }\n
      """)
      return
    return
  return
