{Main} = require '../..'
fs = require 'fs'
{execFile} = require 'child_process'

exports.compile_sample = (T,cb) ->
  argv = [ "-l", "go", "-i", "#{__dirname}/../avdl/sample.avdl", "-o", "#{__dirname}/sample.go" ]
  main = new Main
  await main.main { argv }, T.esc(defer(), cb)

  # Run gofumpt on the generated file if available (optional for local dev)
  # In CI, golangci-lint will handle formatting. Silently ignore if not installed.
  await execFile 'gofumpt', ['-w', "#{__dirname}/sample.go"], defer(err)
  # Ignore error - gofumpt is optional

  cb()
