package tink.tcp.servers;

import tink.tcp.Server;
import tink.tcp.Connection;
import tink.tcp.connections.JavaConnection;
import java.nio.channels.AsynchronousServerSocketChannel as Native;
import java.nio.channels.AsynchronousSocketChannel;
import java.nio.channels.CompletionHandler;
import java.lang.Throwable;

import tink.io.Source;
import tink.io.Sink;

using tink.CoreApi;

@:allow(tink.tcp)
class JavaServer implements ServerObject {
  var native:Native;
  var trigger:SignalTrigger<Connection>;
  public var connected(get, null):Signal<Connection>;
  
  function get_connected()
    return connected;
    
  public function new(server) {
    this.native = server;
    connected = trigger = Signal.trigger();
    server.accept(this, new AcceptedHandler());
  }
  
  public function close():Promise<Noise> {
    native.close();
    return Promise.NOISE;
  }
  
  static public function bind(port:Int) {
    return new Promise(function(resolve, reject) {
      var server = Native.open();
      try {
        server.bind(new java.net.InetSocketAddress('0.0.0.0', port));
        resolve((new JavaServer(server):Server));
      } catch(e:java.io.IOException) {
        reject(Error.withData(e.getMessage(), e));
      }
    });
  }
}


private class AcceptedHandler implements CompletionHandler<AsynchronousSocketChannel, JavaServer>  {
  public function new() {}
  
  public function completed(socket:AsynchronousSocketChannel, server:JavaServer) {
    server.trigger.trigger(new JavaConnection('Connection from ${socket.getRemoteAddress()}', socket));
    server.native.accept(server, this); // accept next connection
  }
  
  public function failed(exc:Throwable, server:JavaServer) {
    // TODO: handle java.nio.channels.AsynchronousCloseException? it is thrown when server is closed while accept() is still pending
    // TODO: report other errors
  }
}