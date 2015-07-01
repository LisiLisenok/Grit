package vm.miix.grit.wire 
{
	import vm.miix.grit.emitter.Messenger;
	
	/**
	 * describes a connection
	 * @author Lis
	 */
	internal final class Connection 
	{
		/**
		 * connection id
		 */
		internal var id : uint;
		
		/**
		 * address to be connectd to
		 */
		internal var address : Address;
		
		/**
		 * listen / send messages to client
		 */
		internal var client : Messenger;
		
		/**
		 * listen / send messages to server
		 */
		internal var server : Messenger;
		
		
		/**
		 * creates new connection
		 * @param	id connection id
		 * @param	address connection address 
		 * @param	client connection client
		 * @param	server connection server
		 */
		public function Connection( id : uint, address : Address, client : Messenger, server : Messenger ) {
			this.id = id;
			this.address = address;
			this.client = client;
			this.server = server;
		}
		
		/**
		 * close this connection
		 */
		internal function close() : void {
			var tmpClient : Messenger = client;
			client = null;
			var tmpServer : Messenger = server;
			server = null;
			if ( tmpClient ) tmpClient.publisher.complete();
			if ( tmpServer ) tmpServer.publisher.complete();
		}
		
	}

}