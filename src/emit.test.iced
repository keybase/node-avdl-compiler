{GoEmitter} = require("./emit");
pkg         = require '../package.json'

describe "GoEmitter", () ->
  emitter = null
  beforeEach () ->
    emitter = new GoEmitter

  describe "emit_preface", () ->
    it "Should emit a preface", () ->
      emitter.emit_preface { infile: "./my_test_file.avdl" }
      code = emitter._code.join "\n"

      expect(code).toBe("""
        // Auto-generated types and interfaces using avdl-compiler v#{pkg.version} (https://github.com/keybase/node-avdl-compiler)
        //   Input file: my_test_file.avdl\n
      """)
      return

    it "Should note that it only generated types if types_only is enabled", () ->
      emitter.emit_preface { infile: "./my_test_file.avdl", types_only: true }
      code = emitter._code.join "\n"

      expect(code).toBe("""
        // Auto-generated types using avdl-compiler v#{pkg.version} (https://github.com/keybase/node-avdl-compiler)
        //   Input file: my_test_file.avdl\n
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

      return

    it "Should emit a struct with an array value", () ->

      return

    it "Should emit a struct with an optional type", () ->

      return

    it "Should emit a struct with a map type", () ->

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
      emitter.emit_enum { t: test_enum }
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
        \treturn ""
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
      emitter.emit_enum { t: test_enum, nostring: true }
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
