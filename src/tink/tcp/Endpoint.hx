package tink.tcp;

private typedef EndpointData = {
  public var host(default, null):String;
  public var port(default, null):Int;
  @:optional 
  public var secure(default, null):Bool;
}

@:forward(host, port)
abstract Endpoint(EndpointData) from EndpointData {
  public var secure(get, never): Bool;
  function get_secure()
    return 
      if (this.secure == null)
        this.port == 443
      else
        this.secure;
        
  public inline function new(host, port, ?secure) {
    this = {host: host, port: port, secure: secure}
  }
  
  @:from inline static function fromPort(port:Int):Endpoint
    return { port: port, host: '127.0.0.1' };
  
  @:to public inline function toString():String
    return '${this.host}:${this.port}';
    
  #if java
  @:from static inline function fromJavaSocketAddress(address:java.net.SocketAddress):Endpoint {
    var inet:java.net.InetSocketAddress = cast address;
    return {host: inet.getHostName(), port: inet.getPort()}
  }
  @:to inline function toJavaSocketAddress():java.net.SocketAddress {
    return new java.net.InetSocketAddress(this.host, this.port);
  }
  #end
}