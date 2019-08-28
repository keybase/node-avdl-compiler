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
  return
