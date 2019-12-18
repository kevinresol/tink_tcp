package tink.tcp;

import tink.io.Source;
import tink.io.Sink;

interface Connection {
	final source:RealSource;
	final sink:RealSink;
	final local:Endpoint;
	final peer:Endpoint;
}