btcd = require '../btcd.coffee'
{ ok, equal: eq } = require 'assert'

btcd_uri = process.env.BTCD_URI or throw new Error 'BTCD_URI must be specified'
btcd_cert = process.env.BTCD_CERT or throw new Error 'BTCD_CERT must be specified'

describe 'btcd', ->
  @timeout 5000

  client = null

  it 'takes a URI and cert and returns a Client', ->
    client = btcd btcd_uri, btcd_cert
    ok client.createrawtransaction?

  it 'works with the websocket calls', (done) ->
    client.getbestblock (err, res) ->
      return done err if err?
      eq typeof res.hash, 'string'
      eq res.hash.length, 64
      eq typeof res.height, 'number'
      do done

  it 'works with the standard http calls', (done) ->
    client.getbestblockhash (err, hash) ->
      return done err if err?
      eq typeof hash, 'string'
      eq hash.length, 64
      do done

  it 'works with notification', (done) ->
    @timeout 10000
    found_tx = false

    client.rescan 160, [ '1Q2TWHE3GMdB6BZKafqwxXtWAWgFt5Jvm3' ], [], 180, (err) ->
      return done err if err?
      ok found_tx
      do done

    client.on 'recvtx', (txid, block) ->
      eq block.height, 170
      eq block.hash, '00000000d1145790a8694403d4063f323d499e655c83426834d4ce2f8dd4a2ee'
      found_tx = true

  after -> client.close()
