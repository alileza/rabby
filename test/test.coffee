rabby = require('./rabby')({ "amqp://localhost" })


rabby.listen 'test', (msg) ->
  setTimeout () ->
    rabby.send 'test', msg
  , 1000

rabby.send 'test', { from: "heaven" }
