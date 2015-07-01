package vm.miix.grit.wire 
{
	/**
	 * connection address.
	 * Address is String host + uint port.
	 * @author Lis
	 */
	public final class Address 
	{
		
		private var _host : String;
		private var _port : uint;
		
		private var _str : String;
		
		
		public function Address( host : String = "", port : uint = 0 ) {
			_host = host;
			_port = port;
			_str = _host + ":" + String( _port );
		}
		
		
		/**
		 * address host
		 */
		public function get host() : String { return _host; }
		
		/**
		 * address port
		 */
		public function get port() : uint { return _port; }
		
		/**
		 * clone this address
		 * @return new address with the same host and port
		 */
		public function clone() : Address { return new Address( host, port ); }
		
		/**
		 * string representation of address as host:port
		 * @return string representation of address
		 */
		public function toString() : String { return _str; }
	
		
	}

}