package;

import haxe.io.*;
import tink.io.*;
import tink.io.PipeResult;
import tink.tcp.*;
import tink.tcp.nodejs.*;
import tink.unit.*;
import tink.testrunner.*;
using StringTools;
using tink.CoreApi;

@:asserts
@:name("Issue #3")
class TestIssue3{
  
  public function new() {}
  
  @:describe("Read from a web server")
  public function test() {
    
    NodejsConnector.connect({host:'www.example.com', port:80}, function(i:Incoming):Outgoing {
      i.stream.pipeTo(Sink.blackhole).handle(function(o) asserts.assert(o == AllWritten));
      return {
        stream: 'GET / HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n',
        allowHalfOpen: true
      }
    }).handle(function(p) {
      asserts.assert(p.isSuccess());
      asserts.done();
    });
    
    return asserts;
  }
  
}

