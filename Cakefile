{spawn, exec} = require 'child_process'

task 'doc', 'build the documentation', ->
  exec([
    'docco src/gibdo.coffee'
    'sed "s/docco.css/resources\\/docco.css/" < docs/gibdo.html > index.html'
    'rm -r docs'
  ].join(' && '), (err) ->
    throw err if err
  )