{PythonEmitter} = require("./py_emit")
pkg             = require '../package.json'

describe "PythonEmitter", () ->
  emitter = null

  beforeEach () ->
    emitter = new PythonEmitter

  describe "output_doc", () ->
    it "should output a Python docstring", () ->
      emitter.output_doc "This is a test comment with\na new line."
      code = emitter._code.join "\n"
      expect(code).toBe("""
        \"\"\"
        This is a test comment with
        a new line.
        \"\"\"
      """)
      return
    return

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

  describe "emit_imports", () ->
    it "should output all imports used by the file", () ->
      imports = [
        {
          path: "../gregor1"
          type: "idl"
          import_as: "gregor1"
        },
        {
          path: "../keybase1"
          type: "idl",
          import_as: "keybase1"
        },
        {
          path: "common.avdl"
          type: "idl"
        },
        {
          path: "chat_ui.avdl"
          type: "idl"
        },
        {
          path: "unfurl.avdl"
          type: "idl"
        },
        {
          path: "commands.avdl"
          type: "idl"
        }
      ]
      emitter.emit_imports {imports}, "test/output/dir/name/__init__.py"
      code = emitter._code.join "\n"

      expect(code).toBe("""
        from dataclasses import dataclass, field
        from enum import Enum
        from typing import Dict, List, Optional, Union
        from typing_extensions import Literal

        from dataclasses_json import config, DataClassJsonMixin

        import test.output.dir.gregor1 as gregor1
        import test.output.dir.keybase1 as keybase1\n
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
        BuildPaymentID = str
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
        @dataclass
        class TestRecord(DataClassJsonMixin):
            status_description: str = field(metadata=config(field_name='statusDescription'))
            is_valid_thing: bool = field(metadata=config(field_name='isValidThing'))
            long_int: int = field(metadata=config(field_name='longInt'))
            double_or_nothin: float = field(metadata=config(field_name='doubleOrNothin'))
            take_a_byte_of_this_apple: str = field(metadata=config(field_name='takeAByteOfThisApple'))\n
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
        @dataclass
        class TestRecord(DataClassJsonMixin):
            super_cool: MySuperCoolCustomType = field(metadata=config(field_name='superCool'))\n
      """)
      return

    it "should support optional types, and have non-optionals be declared first", () ->
      record = {
        "type": "record",
        "name": "MsgSender",
        "fields": [
          {
            "type": "string",
            "name": "uid",
            "jsonkey": "uid"
          },
          {
            "type": "string",
            "name": "username",
            "jsonkey": "username",
            "optional": true
          },
          {
            "type": "string",
            "name": "deviceID",
            "jsonkey": "device_id"
          },
          {
            "type": "string",
            "name": "deviceName",
            "jsonkey": "device_name",
            "optional": true
          }
        ]
      }

      emitter.emit_record record
      code = emitter._code.join "\n"

      expect(code).toBe("""
        @dataclass
        class MsgSender(DataClassJsonMixin):
            uid: str = field(metadata=config(field_name='uid'))
            device_id: str = field(metadata=config(field_name='device_id'))
            username: Optional[str] = field(default=None, metadata=config(field_name='username'))
            device_name: Optional[str] = field(default=None, metadata=config(field_name='device_name'))\n
      """)

      return

    it "Should support optional arrays", () ->
      record = {
        type: "record",
        name: "Thread",
        fields: [
          {
            type: {
              type: "array",
              items: "Message"
            },
            name: "messages",
            jsonkey: "messages"
          },
          {
            type: [
              null,
              "Pagination"
            ],
            name: "pagination",
            jsonkey: "pagination"
          },
          {
            type: "boolean",
            name: "offline",
            jsonkey: "offline",
            optional: true
          },
          {
            type: {
              "type": "array",
              "items": "keybase1.TLFIdentifyFailure"
            },
            name: "identifyFailures",
            jsonkey: "identify_failures",
            optional: true
          },
          {
            type: {
              "type": "array",
              "items": "RateLimitRes"
            },
            name: "rateLimits",
            jsonkey: "ratelimits",
            optional: true
          }
        ]
      }

      emitter.emit_record record
      code = emitter._code.join "\n"

      expect(code).toBe("""
        @dataclass
        class Thread(DataClassJsonMixin):
            messages: Optional[List[Message]] = field(default=None, metadata=config(field_name='messages'))
            pagination: Optional[Pagination] = field(default=None, metadata=config(field_name='pagination'))
            offline: Optional[bool] = field(default=None, metadata=config(field_name='offline'))
            identify_failures: Optional[List[keybase1.TLFIdentifyFailure]] = field(default=None, metadata=config(field_name='identify_failures'))
            rate_limits: Optional[List[RateLimitRes]] = field(default=None, metadata=config(field_name='ratelimits'))\n
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
        @dataclass
        class StellarServerDefinitions(DataClassJsonMixin):
            revision: int = field(metadata=config(field_name='revision'))
            currencies: Dict[str, OutsideCurrencyDefinition] = field(metadata=config(field_name='currencies'))\n
      """)
      return

    return

  describe "emit_fixed", () ->
    it "should emit a string", () ->
      emitter.emit_fixed { name: "FunHash", size: 32 }
      code = emitter._code.join "\n"

      expect(code).toBe("""
        FunHash = Optional[str]
      """)
      return
    return

  describe "emit_enum", () ->
    it "should emit both an int and string enum", () ->
      test_enum = {
        type: "enum",
        name: "AuditVersion",
        symbols: [
          "V0_0",
          "V1_1",
          "V2_2",
          "V3_3"
        ]
        "doc": "This is a docstring\nhi"
      }
      emitter.emit_enum test_enum
      code = emitter._code.join "\n"

      expect(code).toBe("""
        class AuditVersion(Enum):
            \"\"\"
            This is a docstring
            hi
            \"\"\"
            V0 = 0
            V1 = 1
            V2 = 2
            V3 = 3

        class AuditVersionStrings(Enum):
            V0 = 'v0'
            V1 = 'v1'
            V2 = 'v2'
            V3 = 'v3'\n\n
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
        @dataclass
        class MyVariant__VERSIONHIT(DataClassJsonMixin):
            rtype: Literal[InboxResTypeStrings.VERSIONHIT]
            VERSIONHIT: None

        @dataclass
        class MyVariant__FULL(DataClassJsonMixin):
            rtype: Literal[InboxResTypeStrings.FULL]
            FULL: Optional[InboxViewFull]

        @dataclass
        class MyVariant__HELLO(DataClassJsonMixin):
            rtype: Literal[InboxResTypeStrings.HELLO]
            HELLO: Optional[bool]

        @dataclass
        class MyVariant__DECK(DataClassJsonMixin):
            rtype: Literal[InboxResTypeStrings.DECK]
            DECK: Optional[List[int]]

        MyVariant = Union[MyVariant__VERSIONHIT, MyVariant__FULL, MyVariant__HELLO, MyVariant__DECK]\n
      """)
      return
    return

  return
