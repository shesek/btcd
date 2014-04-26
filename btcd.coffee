WebSocket = require 'ws'
{ readFileSync } = require 'fs'
{ EventEmitter } = require 'events'
debug = require('debug')('btcd')
methods = require './methods'

class Client extends EventEmitter
  VER = '1.0'
  counter = 0

  constructor: (uri, cert) ->
    cert = readFileSync cert if typeof cert is 'string'
    opt = if cert? then { cert, ca: [ cert ] } else { }
    @ws = new WebSocket uri, opt
    @ws.on 'message', @handle_message

  call: (method, params..., cb) ->
    # Queue requests until we're connected
    if @ws.readyState is WebSocket.CONNECTING
      return @ws.once 'open', @call.bind this, arguments...

    id = ++counter
    msg = JSON.stringify { jsonrpc: VER, id, method, params }
    debug '-> %s', msg
    @ws.send msg, (err) =>
      if err? then cb err
      else @once 'res:'+id, cb

  close: -> @ws.close()

  handle_message: (msg) =>
    { id, error, result, method, params } = JSON.parse msg
    debug "<- %s", msg

    # If we have an id, notify the listener
    if id?
      if error? then @emit 'res:'+id, error
      else @emit 'res:'+id, null, result
    # If we got an error and no id, emit a generic error
    else if error? then  @emit 'error', error
    # If we got a notification, emit with the method as the event name
    else if method? then @emit method, params...
    # This should never happen...
    else @emit 'error', new Error 'Invalid message: '+msg

  methods.forEach (method) =>
    @::[method] = (a...) -> @call method, a...

module.exports = (uri, cert) -> new Client uri, cert
