package vm.miix.grit.wire 
{
	/**
	 * internal (this thread) server
	 * @author Lis
	 */
	internal class ServerInternal extends ServerBase 
	{
		
		/**
		 * callback function called when new connection is established, must return promise resolved
		 * with anything if connection is accepted or with error if some error has been occured
		 * <listing version="3.0"> function onConnected( connection : Connection ) : void; </listing>
		 */
		private var onConnected : Function;
		
		
		/**
		 * creates new server
		 * @param	address server address
		 * @param	onConnected callback called when new connection is established, must return promise resolved
		 * with anything if connection is accepted or with error if some error has been occured
		 * <listing version="3.0"> function onConnected( connection : Connection ) : void; </listing>
		 */
		public function ServerInternal( address : Address, onConnected : Function ) {
			this.onConnected = onConnected;
			super( address );
			
		}
		
		
		/**
		 * @inheritDoc
		 */
		override internal function establishConnection( connection : Connection ) : void {
			try {
				onConnected( connection.server );
			}
			catch ( err : Error ) {
				connection.client.publisher.error( err );
				connection.close();
			}
		}
		
		
	}

}