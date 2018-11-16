
{Main} = require '../..'
fs = require 'fs'

exports.compile_sample = (T,cb) ->
  argv = [ "-l", "go", "-i", "#{__dirname}/../avdl/sample.avdl", "-o", "#{__dirname}/sample.go" ]
  main = new Main
  await main.main { argv }, T.esc(defer(), cb)
  cb()
