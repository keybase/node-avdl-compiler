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
  return
