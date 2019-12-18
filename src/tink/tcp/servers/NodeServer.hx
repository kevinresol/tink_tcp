package tink.tcp.servers;

import tink.tcp.Server;
import tink.tcp.Connection;
import tink.tcp.connections.NodeConnection;

import tink.io.Source;
import tink.io.Sink;

using tink.CoreApi;

class NodeServer implements ServerObject {
  var native:js.node.net.Server;
  public var connected(get, null):Signal<Connection>;
  
  function get_connected()
    return connected;
    
  public function new(server) {
    this.native = server;
    var t = Signal.trigger();
    native.on('connection', function (c:js.node.net.Socket) {
      t.trigger((new NodeConnection('Connection from ${c.remoteAddress}', c):Connection));
    });
    connected = t;
  }
  
  public function close():Promise<Noise> {
    return new Promise(function(resolve, reject) {
      // TODO: remove `cast` when https://github.com/HaxeFoundation/hxnodejs/pull/154 is fixed
      native.close(cast function(e) if(e == null) resolve(Noise) else reject(Error.ofJsError(e)));
    });
  }
  
  static public function bind(port:Int) {
    var server = js.node.Net.createServer();
    server.listen(port);
    return 
      Future.async(function (cb) {
        server.on('listening', function (_) {
          cb(Success((new NodeServer(server) : Server)));
        });
        server.on('error', function (e) {
          cb(Failure(new Error('Failed to open server on port $port because $e')));
        });
      });
  }

}