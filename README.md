# btcd

NodeJS client for btcd WebSocket API.
Written in CoffeeScript (and published to npm as compiled JavaScript).

### Install
```bash
npm install btcd
```

### Use
```js
// Notice the "/ws" in the url.
var btcd = require('btcd')('wss://user:password@localhost:8334/ws',
                           __dirname + '/rpc.cert');

// All the jsonrpc calls are available as methods:
btcd.getblockhash(0, function(err, hash){
  if (err) throw err;
  console.log(hash); // 000000000019d6689c085ae...
});

btcd.createrawtransaction(
  [{ txid: ..., vout: 0 }],
  { '1KDZMzoahiAHtAbp8VuVvNahm5SaN3PFXc': 0.5 },
  function(err, rawtx) {
   // ...
  }
)

// Calls with notifications emits additional events:
btcd.notifyreceived([ '1KDZMzoahiAHtAbp8VuVvNahm5SaN3PFXc' ], function(err) {
  if (err) throw err;
  // Listening started succesfully, transactions will now trigger 'recvtx' below
});

btcd.on('recvtx', function(tx, block) {
  // process tx
});

// Close the connection
btcd.close();
```

(TODO: document events)

### Test

Running the tests requires setting up a local btcd and configuring the tests to
connect to it.

```bash
# Install dev dependencies
npm install

# Run tests
BTCD_URI=wss://user:pass@localhost:8334/ws \
BTCD_CERT=./rpc.cert \
npm test
```

### Debug

Information about data being sent and received can be displayed using the
[debug](https://github.com/visionmedia/debug) package.
To enable this, start the process with the environment variable `DEBUG=btcd`.

### License

MIT
