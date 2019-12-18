package tink.tcp;

using tink.CoreApi;

interface Client {
	function connect(to:Endpoint):Promise<Connection>;
}
