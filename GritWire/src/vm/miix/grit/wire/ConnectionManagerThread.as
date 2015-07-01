package vm.miix.grit.wire 
{
	import vm.miix.grit.collection.Comparison;
	import vm.miix.grit.collection.FunctionMapSet;
	import vm.miix.grit.collection.IMap;
	import vm.miix.grit.collection.List;
	import vm.miix.grit.collection.MapSet;
	import vm.miix.grit.emitter.EmitterFactory;
	import vm.miix.grit.emitter.IPublisher;
	import vm.miix.grit.emitter.Messenger;
	import vm.miix.grit.promise.Deferred;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.trigger.Registration;
	
	/**
	 * manages connections in external thread (which is main swf-file thread)
	 * @author Lis
	 */
	internal class ConnectionManagerThread implements IConnectionManager 
	{
			
		/**
		 * map with address key and items of map with connection id key and connection item
		 */
		private var _clientConnections : MapSet = new MapSet( ContextBase.compareAddress );
		
		/**
		 * map with address key and items of map with connection id key and connection item
		 */
		private var _serverConnections : MapSet = new MapSet( ContextBase.compareAddress );
		
		/**
		 * waiters of connections as <code>Deferred</code>
		 */
		private var _waitConnection : MapSet = new MapSet( ContextBase.compareAddress );
		
		/**
		 * waiters of server registering as <code>Deferred</code>
		 */
		private var _waitRegistration : MapSet = new MapSet( ContextBase.compareAddress );
		
		/**
		 * server notifications on connections
		 */
		private var _servers : FunctionMapSet = new FunctionMapSet( ContextBase.compareAddress );
		
		
		/**
		 * exchnging messages with external thread
		 */
		private var exchanger : IMessageExchanger;
		
		
	
		public function ConnectionManagerThread( exchanger : IMessageExchanger ) {
			this.exchanger = exchanger;
		}
		
		
		// publisher to from client
		private function getPublisherClient( command : Command ) : IPublisher {
			if ( command.isFromServer ) {
				var s : IMap = _clientConnections.byKey( command.address ) as IMap;
				if ( s ) {
					var connection : Connection = s.byKey( command.connectionID ) as Connection;
					if ( connection ) return connection.server.publisher;
				}
			}
			else {
				s = _clientConnections.byKey( command.address ) as IMap;
				if ( s ) {
					connection = s.byKey( command.connectionID ) as Connection;
					if ( connection ) return connection.client.publisher;
				}
			}
			return null;
		}
		
		// publish to / from server
		private function getServerPublisher( command : Command ) : IPublisher {
			if ( command.isFromServer ) {
				var s : IMap = _serverConnections.byKey( command.address ) as IMap;
				if ( s ) {
					var connection : Connection = s.byKey( command.connectionID ) as Connection;
					if ( connection ) return connection.client.publisher;
				}
			}
			else {
				s = _serverConnections.byKey( command.address ) as IMap;
				if ( s ) {
					connection = s.byKey( command.connectionID ) as Connection;
					if ( connection ) return connection.server.publisher;
				}
			}
			return null;
		}
		
		
		// get connection or create new if doesn't exists
		private static function getConnection( connections : MapSet, address : Address, id : uint ) : Connection {
			
			var mapConnection : MapSet = connections.byKey( address ) as MapSet;
			if ( mapConnection == null ) {
				
				mapConnection = new MapSet( Comparison.uintIncreasing );
				connections.add( address, mapConnection );
			}
			else {
				var connection : Connection = mapConnection.byKey( id ) as Connection;
				if ( connection ) return connection;
			}
			
			// create new connection
			var cross : Vector.<Messenger> = EmitterFactory.crossMessengers();
			connection = new Connection( id, address.clone(), cross[0], cross[1] );
			mapConnection.add( id, connection );
			return connection;
		}
		
		
		/* INTERFACE vm.miix.grit.wire.IConnectionManager */
		
		/**
		 * @inheritDoc
		 */
		public function connectExternal( command : Command ) : void {
			// find connection waiting
			var defList : List = _waitConnection.byKey( command.address ) as List;
			if ( defList && !defList.empty ) {
				
				var def : Deferred = defList.accept() as Deferred;
				if ( defList.empty ) _waitConnection.remove( command.address );
				
				var connection : Connection = getConnection( _clientConnections, command.address, command.connectionID );
				
				// tune resending message from client
				exchanger.resendExternal( command.address, command.connectionID, connection.server, false, false );
				
				// resolve promise with client messenger (client receives messenger to send / listen server)
				def.resolve( connection.client );
			}
			else {
				// no connection waiting or server registered - complete this
				exchanger.sendCommand( new Command( Command.COMPLETE, command.address.host, command.address.port,
						command.connectionID, false ) );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function connectServerExternal( command : Command ) : void {
			if ( _servers.contains( command.address ) ) {
				var connection : Connection = getConnection( _serverConnections, command.address, command.connectionID );
				// tune resending message from client
				exchanger.resendExternal( command.address, command.connectionID, connection.server, true, false );
				_servers.invoke( command.address, connection.client );
			}
			else {
				// no connection waiting or server registered - complete this
				exchanger.sendCommand( new Command( Command.COMPLETE, command.address.host, command.address.port,
						command.connectionID, false ) );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function registerExternal( command : Command ) : void {
			// find connection waiting
			var def : Deferred = _waitRegistration.remove( command.address ) as Deferred;
			if ( def ) {
				// server registration - to cancel this server
				var address : Address = command.address.clone();
				var reg : Registration = new Registration (
					function () : void {
						exchanger.sendCommand( new Command( Command.UNREGISTER_SERVER, address.host,
								address.port, 0, false ) );
					}
				);
				def.resolve( reg );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function unregisterExternal( command : Command ) : void {
			var def : Deferred = _waitRegistration.remove( command.address ) as Deferred;
			if ( def ) def.reject( command.body );
			_servers.remove( command.address );
			_serverConnections.remove( command.address );
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function messageExternal( command : Command ) : void {
			var publisher : IPublisher = getPublisherClient( command );
			if ( publisher ) publisher.publish( command.body );
		}
		
		/**
		 * @inheritDoc
		 */
		public function errorGritExternal( command : Command ) : void {
			// registration error
			var def : Deferred = _waitRegistration.remove( command.address ) as Deferred;
			if ( def ) def.reject( command.body );
			
			// connection error
			var l : List = _waitConnection.remove( command.address ) as List;
			if ( l ) {
				l.forEach (
					function ( defConnection : Deferred ) : void {
						defConnection.reject( command.body );
					}
				);
				l.clear();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function errorClientExternal( command : Command ) : void {
			// server error
			var publisher : IPublisher = getPublisherClient( command );
			if ( publisher ) publisher.error( command.body );
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function completeExternal( command : Command ) : void {
			var mServer : MapSet = _clientConnections.byKey( command.address ) as MapSet;
			if ( mServer != null ) {
				var c : Connection = mServer.remove( command.connectionID ) as Connection;
				if ( c ) c.close();
				if ( mServer.size == 0 ) _clientConnections.remove( command.address );
			}
		}

		
		/**
		 * @inheritDoc
		 */
		public function messageServer( command : Command ) : void {
			var publisher : IPublisher = getServerPublisher( command );
			if ( publisher ) publisher.publish( command.body );
		}
		
		/**
		 * @inheritDoc
		 */
		public function errorServer( command : Command ) : void {
			var publisher : IPublisher = getServerPublisher( command );
			if ( publisher ) publisher.error( command.body );
		}
		
		
		
		/**
		 * @inheritDoc
		 */
		public function registerServer( descriptor : ServerDescriptor, onConnected : Function ) : IPromise {
			var def : Deferred = new Deferred();
			var address : Address = descriptor.address;
			if ( _servers.contains( address ) ) {
				def.reject( WireErrorMessages.SERVER_EXISTS );
			}
			else {				
				_waitRegistration.add( address, def );
			
				_servers.add( address,
					function ( server : Messenger ) : void {
						try {
							onConnected( server );
						}
						catch ( err : Error ) {
							server.publisher.error( err );
							server.publisher.complete();
						}
					}
				);
			
				try {
					exchanger.sendCommand( new Command( Command.REGISTER_SERVER, address.host, address.port, 0, false, descriptor ) );
				}
				catch ( err : Error ) {
					_waitRegistration.remove( address );
					def.reject( err );
				}
			}
			return def.promise;
		}
		
		/**
		 * @inheritDoc
		 */
		public function connect( address : Address ) : IPromise {
			var def : Deferred = new Deferred();
			var l : List;
			if ( _waitConnection.contains( address ) ) {
				l = _waitConnection.byKey( address ) as List;
			}
			else {
				l = new List();
				_waitConnection.add( address, l );
			}
			l.push( def );
			exchanger.sendCommand( new Command( Command.CONNECT, address.host, address.port, 0, false ) );
			return def.promise;
			
		}
		
	}

}