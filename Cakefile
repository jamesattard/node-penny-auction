fs = require 'fs'

{print}         = require 'sys'
{exec, spawn}   = require 'child_process'


task 'test', 'Runs tests', ->
  watch = exec "NODE_ENV=test mocha --timeout 15000 --compilers coffee:coffee-script/register spec/SpecHelper.coffee spec/**/*Spec.coffee"
  watch.stdout.on 'data', (data)-> process.stdout.write data.toString()
  watch.stderr.on 'data', (data)-> process.stderr.write data.toString()


task 'watch:server', 'Runs tests', ->
  watch = exec "coffee -wbco api/ src/coffee/api/"
  watch.stdout.on 'data', (data)-> process.stdout.write data.toString()
  watch.stderr.on 'data', (data)-> process.stderr.write data.toString()



