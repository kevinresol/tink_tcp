package tink.tcp.clients;

import java.lang.Throwable;
import java.nio.channels.CompletionHandler;
import java.nio.channels.AsynchronousSocketChannel;
import tink.tcp.Client;
import tink.tcp.Connection;
import tink.tcp.connections.JavaConnection;

using tink.CoreApi;

class JavaClient implements Client {
  public function new() {}
  public function connect(to:Endpoint):Promise<Connection> {
    return Future.async(function(cb) {
      // TODO: secure
      var native = AsynchronousSocketChannel.open();
      native.connect(to, native, new ConnectedHandler('Connection to $to', cb));
    });
  }
}



private class ConnectedHandler implements CompletionHandler<java.lang.Void, AsynchronousSocketChannel>  {
  var name:String;
  var cb:Callback<Outcome<Connection, Error>>;
  
  public function new(name, cb) {
    this.name = name;
    this.cb = cb;
  }
  
  public function completed(result:java.lang.Void, socket:AsynchronousSocketChannel) {
    cb.invoke(Success(new JavaConnection('Connection to ${socket.getRemoteAddress()}', socket)));
  }
  
  public function failed(exc:Throwable, socket:AsynchronousSocketChannel) {
    cb.invoke(Failure(Error.withData('Connection failed, reason: ' + exc.getMessage(), exc)));
  }
}