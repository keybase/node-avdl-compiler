{PythonEmitter} = require("./py_emit")
pkg             = require '../package.json'

describe "PythonEmitter", () ->
  emitter = null
  beforeEach () ->
    emitter = new PythonEmitter

  describe "emit_preface", () ->
    it "Should emit a preface", () ->
      emitter.emit_preface ["./my_test_file.avdl"], {namespace: "chat1"}
      code = emitter._code.join "\n"

      expect(code).toBe("""
      \"\"\"chat1

      Auto-generated to Python types by #{pkg.name} v#{pkg.version} (#{pkg.homepage})
      Input files:
       - my_test_file.avdl
      \"\"\"\n
      """)
      return
    return
  return
