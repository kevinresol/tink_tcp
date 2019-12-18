package tink.tcp.clients;

import tink.tcp.Client;
import tink.tcp.Connection;
import tink.tcp.connections.NodeConnection;

using tink.CoreApi;

class NodeClient implements Client {
	public function new() {}
	public function connect(to:Endpoint):Promise<Connection> {
		return new Promise(function(resolve, reject) {
			var native = to.secure ? js.node.Tls.connect(to.port, to.host) : js.node.Net.connect(to.port, to.host);
			native.once('connect', function () resolve((new NodeConnection('Connection to $to', native):Connection)));
			native.once('error', function (e) reject(Error.ofJsError(e)));
		});
	}
}

