package vm.miix.grit.wire 
{
	import vm.miix.grit.collection.Comparison;
	import vm.miix.grit.collection.MapSet;
	import vm.miix.grit.emitter.EmitterFactory;
	import vm.miix.grit.emitter.IPublisher;
	import vm.miix.grit.emitter.Messenger;
	import vm.miix.grit.promise.Deferred;
	import vm.miix.grit.promise.IPromise;
	
	/**
	 * server base for both internal (this thread) and external (another thread)
	 * @author Lis
	 */
	internal class ServerBase implements IServer 
	{
		/**
		 * id of last stored connection
		 */
		private var lastConnection : uint;
		
		/**
		 * map of id->connections
		 */
		private var connections : MapSet = new MapSet( Comparison.uintIncreasing );
		
		
		/**
		 * server address
		 */
		private var address : Address;
		
		
		public function ServerBase( address : Address ) {
			lastConnection = 1;
			this.address = address;
		}
		
		
		private static function closeConnection( connection : Connection ) : void {
			connection.close();
		}
		
		/**
		 * create new connection
		 * @return created connection
		 */
		private function createConnection() : Connection {
			
			// messengers used behind the server
			var cross : Vector.<Messenger> = EmitterFactory.crossMessengers();
			// add connection to the list
			var connection : Connection = new Connection( lastConnection ++, address.clone(), cross[0], cross[1] );
			connections.add( connection.id, connection );
			
			// close connection when emitter completes
			cross[0].emitter.subscribe( null, closeCreatedConnection );
			cross[1].emitter.subscribe( null, closeCreatedConnection );
			
			return connection;
			
			
			function closeCreatedConnection() : void {
				if ( connection ) {
					var tmpConnection : Connection = connection;
					connection = null;
					connections.remove( tmpConnection.id );
					tmpConnection.close();
					tmpConnection = null;
				}
			}
			
		}
		
		/**
		 * establish new connection - must be overriden
		 * @param	connection connection to be established
		 */
		internal function establishConnection( connection : Connection ) : void {
			
		}
		
		
		/* INTERFACE vm.miix.grit.wire.IServer */
		
		public function connect() : IPromise {
			// establish new connection
			var connection : Connection = createConnection();
			establishConnection( connection );
			// return connection
			var def : Deferred = new Deferred();
			def.resolve( connection );
			return def.promise;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function cancel() : void {
			connections.forEachItem( closeConnection );
			connections.clear();
		}
		
		/**
		 * @inheritDoc
		 */
		public function clientSocket( id : uint ) : IPublisher {
			var connection : Connection = connections.byKey( id ) as Connection;
			if ( connection ) return connection.client.publisher;
			else return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function serverSocket( id : uint ) : IPublisher {
			var connection : Connection = connections.byKey( id ) as Connection;
			if ( connection ) return connection.server.publisher;
			else return null;
		}
		
	}

}