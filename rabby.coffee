amqp = require 'amqplib/callback_api'
crypto = require "crypto"
_ = require "underscore"

module.exports = (options) =>

	@default = {}

	@send = (q, data) =>
		amqp.connect options.host, (err, conn) =>
			conn.createChannel (err, ch) =>
				date = (new Date().toISOString()).split('.')[0].replace(/-|:/g,"")
				random = crypto.randomBytes(8).toString('hex')

				data._uuid = "#{date}_#{data.from}_#{random}" if not data._uuid
				data.created_at = new Date().toISOString()

				data = _.extend data, @default

				ch.assertQueue q, { durable: false }
				ch.sendToQueue q, new Buffer( JSON.stringify(data) )

				return ch.close()

	@listen = (q, cb) ->
		amqp.connect options.host, (err, conn) ->
			if err
				console.error err
				process.exit -1

			conn.createChannel (err, ch) ->
				if err
					console.error err
					process.exit -1

				ch.assertQueue q, {durable: false}

				console.log " [*] Waiting for messages in %s. To exit press CTRL+C", q

				ch.consume q, (msg) ->
					try
						content = JSON.parse msg.content.toString()
					catch e
						content = e
					cb content, msg
				, { noAck: true }

	@
