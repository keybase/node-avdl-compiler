{Main} = require '../..'
fs = require 'fs'
{execFile} = require 'child_process'

exports.compile_sample = (T,cb) ->
  argv = [ "-l", "go", "-i", "#{__dirname}/../avdl/sample.avdl", "-o", "#{__dirname}/sample.go" ]
  main = new Main
  await main.main { argv }, T.esc(defer(), cb)

  # Run gofumpt on the generated file
  await execFile 'gofumpt', ['-w', "#{__dirname}/sample.go"], T.esc(defer(err), cb)
  if err
    console.error "Warning: gofumpt failed:", err.message

  cb()
