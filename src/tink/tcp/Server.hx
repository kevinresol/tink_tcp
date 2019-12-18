package tink.tcp;

#if sys
import sys.net.Host;
import sys.net.Socket;
#end
import tink.io.*;
#if tink_runloop
import tink.runloop.Worker;
import tink.runloop.Task;
#end

using tink.CoreApi;

@:forward
abstract Server(ServerObject) from ServerObject {
  static public function bind(port:Int):Promise<Server> {
    #if java
      return tink.tcp.servers.JavaServer.bind(port);
    #elseif nodejs
      return tink.tcp.servers.NodeServer.bind(port);
    // #elseif ((neko || java || cpp) && tink_runloop)
      // return SysServer.bind(port);
    #else
      return Future.sync(Failure(new Error('Not implemented on current platform')));//technically, this is unreachable
    #end
  }
}

interface ServerObject {
  var connected(get, never):Signal<Connection>;
  function close():Promise<Noise>;
}

// #if (tink_runloop && (neko || java || cpp))
// class RunloopServer implements ServerObject {
//   var usher:Worker;
//   var releaseKeepAlive:Task;
//   var getScribe:Void->Worker;
//   var boundPort: {
//     function close():Void;
//     function accept(reader:Worker, writer:Worker):Connection;
//   };
//   var _connected:SignalTrigger<Connection>;
  
//   public var connected(get, never):Signal<Connection>;
  
//   inline function get_connected() 
//     return _connected.asSignal();
    
//   public function new(usher, getScribe, bind) {
//     this._connected = Signal.trigger();
//     this.usher = usher;
//     this.getScribe = getScribe;
    
//     this.boundPort = bind({ 
//       blocking: 
//           #if concurrent
//             usher.owner != usher
//           #else
//             false
//           #end
//     });
    
//     this.releaseKeepAlive = usher.owner.retain();
    
//     usher.work(accept);    
//   }
  
//   function accept() {
    
//     if (releaseKeepAlive.state != Pending) return;
//     try {
      
//       var scribe = getScribe();
//       var client = boundPort.accept(scribe, scribe);//TODO: consider having separate threads for output to reduce back pressure
      
//       usher.owner.work(function () _connected.trigger(client));
//     }
//     catch (e:Dynamic) {
//       //do something about this?
//     }
        
//     usher.work(accept);
//   }
  
//   public function close() 
//     if (boundPort != null) {
//       releaseKeepAlive.perform();
//       _connected.clear();
//       boundPort.close();
//       boundPort = null;      
//     }  
// }

// class SysServer extends RunloopServer {
//   public function new(usher, getScribe, port:Int) 
//     super(usher, getScribe, function (options) {
//       #if java
//       var s = java.nio.channels.ServerSocketChannel.open();
//       s.bind(new java.net.InetSocketAddress(port));
//       s.configureBlocking(options.blocking);
//       return {
//         close: s.close,
//         accept: function (read, write) {
//           var client = s.accept();
//           client.configureBlocking(false);
//           var peer = client.getRemoteAddress();
//           var endpoint:Endpoint = 1234;
//           return new Connection(
//             new tink.io.java.JavaSource(client, 'Inbound stream from $endpoint', read),
//             new tink.io.java.JavaSink(client, 'Outbound stream to $endpoint', write),
//             'Connection to $endpoint',
//             endpoint,
//             client.close
//           );
//         }
//       }
//       #else
//       var s = new Socket();
//       s.bind(new Host('0.0.0.0'), port);//TODO: find out how to bind for any address
//       s.listen(0x4000);
//       s.setBlocking(options.blocking);
//       return {
//         close: s.close,
//         accept: function (read, write) {
//           var client = s.accept();
//           var peer = client.peer();
          
//           return Connection.wrap( { port: peer.port, host: peer.host.toString() }, client, read, write);  
//         }
//       }
//       #end
//     });
  
//   static public function bind(port:Int) {
//     var workers = [for (i in 0...10) tink.RunLoop.current.createSlave()];
//     return Future.sync(
//       Success(
//         (new SysServer(
//           workers.pop(), 
//           function () {
//             return workers[Std.random(workers.length)];//the naive hope is that randomness makes it harder to glue down a single worker
//           },
//           port
//         ) : Server)
//       )
//     );    
//   }
  
// }

// #end