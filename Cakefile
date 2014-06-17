fs = require 'fs'

{print}         = require 'sys'
{exec, spawn}   = require 'child_process'


task 'test', 'Runs tests', ->
#  coffee = spawn 'mocha', ['--compilers', "coffee:coffee-script/register", "spec/SpecHelper.coffee", "spec/**/*Spec.coffee"]
#  coffee.stderr.on 'data', (data) ->
#    process.stderr.write data.toString()
#  coffee.stdout.on 'data', (data) ->
#    print data.toString()

  watch = exec "NODE_ENV=test mocha --compilers coffee:coffee-script/register spec/SpecHelper.coffee spec/**/*Spec.coffee"
  watch.stdout.on 'data', (data)-> process.stdout.write data.toString()
  watch.stderr.on 'data', (data)-> process.stderr.write data.toString()



#task 'test', 'Runs tests', ->
#  coffee = spawn 'jasmine-node', ['--coffee', "--captureExceptions", "spec/"]
#  coffee.stderr.on 'data', (data) ->
#    process.stderr.write data.toString()
#  coffee.stdout.on 'data', (data) ->
#    print data.toString()