# 1.3.11 (2016-12-14)

- Fix invalid go codegen

# 1.3.10 (2016-12-02)

- Add String() method for enums

# 1.3.9 (2016-09-30)

- New location for RPC library

# 1.3.8 (2016-09-28)

- Support for `void` fields that aren't the default

# 1.3.7 (2016-09-7)

- Add reverse map for enums in Go

# 1.3.6 (2016-09-01)

Bugfixes:
 - emitted types are lowercase
 - don't allow malicious sender to crash us out nil pointer

# 1.3.5 (2016-08-31)

- Add variant type

# 1.3.4 (2016-08-18)

- Add forward map for enums in Go

# 1.3.3 (2016-03-25)

- Fix tests

# 1.3.2 (2016-03-23)

- Fix tests

# 1.3.1 (2016-03-21)

- Also plumb through /** ... */-style docs to typedefs

# 1.3.0 (2016-03-21)

- Plumb /** .. */-style docs through to output Go code.

# 1.2.0 (2016-03-21)

- Support `go_field_suffix` for dealing with method/field clashes programmatically
