{GoEmitter} = require("./go_emit");
pkg         = require '../package.json'
path_lib    = require 'path'

describe 'GoEmitter', () ->
  emitter = null
  beforeEach () ->
    emitter = new GoEmitter "github.com/keybase/node-avdl-compiler", path_lib.resolve()

  describe "emit_preface", () ->
    it "Should emit a preface", () ->
      emitter.emit_preface ["./my_test_file.avdl"], {namespace: "chat1"}
      code = emitter._code.join "\n"

      expect(code).toBe("""
        // Auto-generated to Go types and interfaces using avdl-compiler v#{pkg.version} (https://github.com/keybase/node-avdl-compiler)
        //   Input file: my_test_file.avdl

        package chat1\n
      """)
      return

    it "Should note that it only generated types if types_only is enabled", () ->
      emitter.emit_preface ["./my_test_file.avdl"], {namespace: "chat1"}, {types_only: true}
      code = emitter._code.join "\n"

      expect(code).toBe("""
        // Auto-generated to Go types using avdl-compiler v#{pkg.version} (https://github.com/keybase/node-avdl-compiler)
        //   Input file: my_test_file.avdl

        package chat1\n
      """)
      return
    return

  describe "emit_imports", () ->
    it "should handle both GOPATH based paths and relative paths", () ->
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
        },
      ]

      emitter.emit_imports {imports, messages: {}, types: []}, 'location/of/my/output.go', {types_only: true}
      code = emitter._code.join "\n"

      expect(code).toBe('''
        import (
        \tgregor1 "github.com/keybase/node-avdl-compiler/location/of/gregor1"
        \tkeybase1 "github.com/keybase/client/go/protocol/keybase1"
        )\n\n
      ''')
      return

    it "should ignore packages that aren't imported with a package name", () ->
      imports = [
        {
          path: "common.avdl",
          type: "idl"
        }
      ]

      emitter.emit_imports {imports, messages: {}, types: []}, 'location/of/my/output.go', {types_only: true}
      code = emitter._code.join "\n"
      expect(code).toBe("""
      import (
      )\n\n
      """)
      return

    it "should only import the rpc package if types_only is false", () ->
      emitter.emit_imports {imports: [], messages: {}, types: []}, 'location/of/my/output.go', {types_only: false}
      code = emitter._code.join "\n"
      expect(code).toBe("""
        import (
        \t"github.com/keybase/go-framed-msgpack-rpc/rpc"
        )\n\n
      """)
      return

    it "should only import the content and time packages if types_only is false and the file contains messages", () ->
      emitter.emit_imports {imports: [], messages: {fake_message: 'blah'}, types: []}, 'location/of/my/output.go', {types_only: false}
      code = emitter._code.join "\n"
      expect(code).toBe("""
        import (
        \t"github.com/keybase/go-framed-msgpack-rpc/rpc"
        \tcontext "golang.org/x/net/context"
        \t"time"
        )\n\n
      """)
      return

    it "should output the errors package if there are variants", () ->
      emitter.emit_imports {imports: [], messages: {}, types: [{
        type: "variant",
        name: "TextPaymentResult",
      }]}, 'location/of/my/output.go', {types_only: true}
      code = emitter._code.join "\n"
      expect(code).toBe("""
        import (
        \t"errors"
        )\n\n
      """)
      return

    return

  describe "emit_typedef", () ->
    it "Should emit a string typedef", () ->
      type = {
        type: "record"
        name: "BuildPaymentID"
        fields: []
        typedef: "string"
      }
      emitter.emit_typedef type
      code = emitter._code.join "\n"

      expect(code).toBe("""
        type BuildPaymentID string
        func (o BuildPaymentID) DeepCopy() BuildPaymentID {
        \treturn o
        }\n
      """)
      return
    return

  describe "emit_record", () ->
    it "Should emit a struct with primative value keys", () ->
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
          }
        ]
      }
      emitter.emit_record record
      code = emitter._code.join "\n"

      expect(code).toBe("""
        type TestRecord struct {
        \tStatusDescription\tstring\t`codec:"statusDescription" json:"statusDescription"`
        \tIsValidThing\tbool\t`codec:"isValidThing" json:"isValidThing"`
        \tLongInt\tint64\t`codec:"longInt" json:"longInt"`
        \tDoubleOrNothin\tfloat64\t`codec:"doubleOrNothin" json:"doubleOrNothin"`
        }

        func (o TestRecord) DeepCopy() TestRecord {
        \treturn TestRecord{
        \t\tStatusDescription: o.StatusDescription,
        \t\tIsValidThing: o.IsValidThing,
        \t\tLongInt: o.LongInt,
        \t\tDoubleOrNothin: o.DoubleOrNothin,
        \t}
        }\n
      """)
      return

    it "Should not emit a DeepCopy function in the option is given", () ->
      record = {
        type: "record"
        name: "TestRecord"
        fields: [
          {
            type: "string",
            name: "statusDescription"
          },
        ]
      }
      emitter.emit_record record, { no_deep_copy: true }
      code = emitter._code.join "\n"

      expect(code).toBe("""
        type TestRecord struct {
        \tStatusDescription\tstring\t`codec:"statusDescription" json:"statusDescription"`
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
        type TestRecord struct {
        \tSuperCool\tMySuperCoolCustomType\t`codec:"superCool" json:"superCool"`
        }

        func (o TestRecord) DeepCopy() TestRecord {
        \treturn TestRecord{
        \t\tSuperCool: o.SuperCool.DeepCopy(),
        \t}
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
        type TestRecord struct {
        \tMaybeStatusDescription\t*string\t`codec:"maybeStatusDescription,omitempty" json:"maybeStatusDescription,omitempty"`
        }

        func (o TestRecord) DeepCopy() TestRecord {
        \treturn TestRecord{
        \t\tMaybeStatusDescription: (func (x *string) *string {
        \t\t\tif x == nil {
        \t\t\t\treturn nil
        \t\t\t}
        \t\t\ttmp := (*x)
        \t\t\treturn &tmp
        \t\t})(o.MaybeStatusDescription),
        \t}
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
        type PaymentsPageLocal struct {
        \tPayments	[]PaymentOrErrorLocal	`codec:"payments" json:"payments"`
        }

        func (o PaymentsPageLocal) DeepCopy() PaymentsPageLocal {
        \treturn PaymentsPageLocal{
        \t\tPayments: (func (x []PaymentOrErrorLocal) []PaymentOrErrorLocal {
        \t\t\tif x == nil {
        \t\t\t\treturn nil
        \t\t\t}
        \t\t\tret := make([]PaymentOrErrorLocal, len(x))
        \t\t\tfor i, v := range x {
        \t\t\t\tvCopy := v.DeepCopy()
        \t\t\t\tret[i] = vCopy
        \t\t\t}
        \t\t\treturn ret
        \t\t})(o.Payments),
        \t}
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
        type StellarServerDefinitions struct {
        \tRevision\tint\t`codec:"revision" json:"revision"`
        \tCurrencies\tmap[OutsideCurrencyCode]OutsideCurrencyDefinition\t`codec:"currencies" json:"currencies"`
        }

        func (o StellarServerDefinitions) DeepCopy() StellarServerDefinitions {
        \treturn StellarServerDefinitions{
        \t\tRevision: o.Revision,
        \t\tCurrencies: (func (x map[OutsideCurrencyCode]OutsideCurrencyDefinition) map[OutsideCurrencyCode]OutsideCurrencyDefinition {
        \t\t\tif x == nil {
        \t\t\t\treturn nil
        \t\t\t}
        \t\t\tret := make(map[OutsideCurrencyCode]OutsideCurrencyDefinition, len(x))
        \t\t\tfor k, v := range x {
        \t\t\t\tkCopy := k.DeepCopy()
        \t\t\t\tvCopy := v.DeepCopy()
        \t\t\t\tret[kCopy] = vCopy
        \t\t\t}
        \t\t\treturn ret
        \t\t})(o.Currencies),
        \t}
        }\n
      """)
      return

    return


  describe "emit_fixed", () ->
    it "Should emit a fixed length type", () ->
      emitter.emit_fixed { name: "FunHash", size: 32 }
      code = emitter._code.join "\n"

      expect(code).toBe("""
        type FunHash [32]byte
        func (o FunHash) DeepCopy() FunHash {
        \tvar ret FunHash
        \tcopy(ret[:], o[:])
        \treturn ret
        }\n
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
        type AuditVersion int
        const (
        \tAuditVersion_V0 AuditVersion = 0
        \tAuditVersion_V1 AuditVersion = 1
        \tAuditVersion_V2 AuditVersion = 2
        \tAuditVersion_V3 AuditVersion = 3
        )

        func (o AuditVersion) DeepCopy() AuditVersion { return o }
        var AuditVersionMap = map[string]AuditVersion{
        \t"V0": 0,
        \t"V1": 1,
        \t"V2": 2,
        \t"V3": 3,
        }

        var AuditVersionRevMap = map[AuditVersion]string{
        \t0: "V0",
        \t1: "V1",
        \t2: "V2",
        \t3: "V3",
        }

        func (e AuditVersion) String() string {
        \tif v, ok := AuditVersionRevMap[e]; ok {
        \t\treturn v
        \t}
        \treturn fmt.Sprintf("%v", int(e))
        }\n
      """)
      return

    it "Should not emit a string function if nostring is given", () ->
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
      emitter.emit_enum test_enum, true
      code = emitter._code.join "\n"

      expect(code).toBe("""
        type AuditVersion int
        const (
        \tAuditVersion_V0 AuditVersion = 0
        \tAuditVersion_V1 AuditVersion = 1
        \tAuditVersion_V2 AuditVersion = 2
        \tAuditVersion_V3 AuditVersion = 3
        )

        func (o AuditVersion) DeepCopy() AuditVersion { return o }
        var AuditVersionMap = map[string]AuditVersion{
        \t"V0": 0,
        \t"V1": 1,
        \t"V2": 2,
        \t"V3": 3,
        }

        var AuditVersionRevMap = map[AuditVersion]string{
        \t0: "V0",
        \t1: "V1",
        \t2: "V2",
        \t3: "V3",
        }\n
      """)
      return
    return

  return
