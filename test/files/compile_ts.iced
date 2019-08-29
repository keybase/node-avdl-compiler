{Main} = require '../..'
fs = require 'fs'

exports.compile_sample = (T, cb) ->
  argv = [ "-l", "typescript", "-i", "#{__dirname}/../avdl/sample.avdl", "-o", "#{__dirname}/sample.ts" ]
  main = new Main
  await main.main { argv }, T.esc(defer(), cb)
  cb()
