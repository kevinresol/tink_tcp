package;

import haxe.Timer;
import haxe.io.*;
import tink.io.Sink;
import tink.tcp.*;

using tink.io.Source;
using tink.CoreApi;
using Lambda;

@:asserts
class NodeTest {
  var total = 10;
  var message = Bytes.ofString([for (i in 0...10000) 'Is it me you\'re looking for $i?'].join(' '));
  var echoer = 'hello\r\n';
  var client:Client = new tink.tcp.clients.NodeClient();
  
  public function new() {}
  
  @:variant(this.sequential, this.message.length + this.echoer.length * this.total)
  @:variant(this.parallel, (this.message.length + this.echoer.length) * this.total)
  public function echo(fn:Int->Promise<Int>, expected:Int) {
    return Server.bind(3000).next(server -> {
      var echoed = 0;
      server.connected.handle(function (cnx) {
        (echoer:RealSource).append(cnx.source).pipeTo(cnx.sink, {end: true})
          .handle(function(v) {
            asserts.assert(v.match(AllWritten));
            echoed++;
          });
      });
      
      fn(total)
        .next(length -> {
          asserts.assert(echoed == total);
          asserts.assert(length == expected);
          server.close();
        })
        .next(_ -> asserts.done());
    });
    
  }
  
  function sequential(total:Int) {
    var last:RealSource = message;
    var incoming = [];
    var promise = Promise.inSequence([for (i in 0...total)
      Promise.lazy(() -> {
        client.connect(3000).next(cnx -> {
          last.pipeTo(cnx.sink, {end: true}).next(result -> {
            last = cnx.source;
          });
        });
      })
    ]);
    return promise
      .next(_ -> last.all())
      .next(chunk -> chunk.length);
  }
  
  function parallel(total:Int) {
    return Promise.inParallel([for (i in 0...total) {
      client.connect(3000).next(cnx -> {
        var write:RealSource = message;
        write.pipeTo(cnx.sink, {end: true})
          .next(_ -> cnx.source.all())
          .next(chunk -> chunk.length);
      });
    }]).next(v -> v.fold((v, total) -> total + v, 0));
  }
}