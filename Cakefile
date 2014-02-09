fs = require 'fs'

{print}         = require 'sys'
{exec, spawn}   = require 'child_process'


task 'watch', 'Watches all coffee fiels', ->
  coffee = spawn 'coffee', ['-w', '-b', '-c', '-o', ".", "./src/coffee"]
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()

task 'wall', 'Watches all coffee and scss files', ->
  invoke 'watch'
  invoke 'scss'

task 'test', 'Runs tests', ->
  coffee = spawn 'jasmine-node', ['--coffee', "spec/"]
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()


task 'scss', 'starts watch for changes in SCSS', ->
  scss = spawn 'scss', ['--watch', "./src/scss/:./public/stylesheets/"]
  scss.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  scss.stdout.on 'data', (data) ->
    print data.toString()