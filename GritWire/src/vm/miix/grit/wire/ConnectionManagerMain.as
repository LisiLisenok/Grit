package vm.miix.grit.wire 
{
	import vm.miix.grit.collection.MapSet;
	import vm.miix.grit.emitter.IPublisher;
	import vm.miix.grit.emitter.Messenger;
	import vm.miix.grit.promise.Deferred;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.trigger.Registration;
	/**
	 * mnages connections in grit main
	 * @author Lis
	 */
	internal class ConnectionManagerMain implements IConnectionManager 
	{
		
		/**
		 * exchnging messages with external thread
		 */
		private var exchanger : IMessageExchanger;
		
		/**
		 * servers registered within grit
		 */
		private var servers : MapSet = new MapSet( ContextBase.compareAddress );
		
		
		/**
		 * create new connections manager within main grit thread
		 * @param	exchanger exchanging messages with another thread
		 */
		public function ConnectionManagerMain( exchanger : IMessageExchanger ) {
			this.exchanger = exchanger;
		}
		
		
		private function getPublisher( command : Command ) : IPublisher {
			if ( command.isFromServer ) {
				var s : IServer = servers.byKey( command.address ) as IServer;
				if ( s ) return s.serverSocket( command.connectionID );
			}
			else {
				s = servers.byKey( command.address ) as IServer;
				if ( s ) return s.clientSocket( command.connectionID );
			}
			return null;
		}

		private function establishExternalConnection( connection : Connection ) : void {
			// from server
			exchanger.resendExternal( connection.address, connection.id, connection.client, true, false );
			exchanger.sendCommand( new Command( Command.CONNECT, connection.address.host,
				connection.address.port, connection.id, true ) );
		}
		
		
		private function connectionClient( connection : Connection ) : Messenger {
			return connection.client;
		}

		
		
		/* INTERFACE vm.miix.grit.wire.IConnectionManager */
		
		/**
		 * @inheritDoc
		 */
		public function connectExternal( command : Command ) : void {
			var server : IServer = servers.byKey( command.address ) as IServer;
			if ( server ) {
				// connect to server
				server.connect().onCompleted ( establishExternalConnection,
					function ( reason : * ) : void {
						try {
							exchanger.sendCommand( new Command( Command.ERROR_GRIT, command.address.host, command.address.port,
									command.connectionID, true, reason ) );
						}
						catch ( err : Error ) {
							exchanger.sendCommand( new Command( Command.ERROR_GRIT, command.address.host, command.address.port,
									command.connectionID, true, err ) );
						}
					}
				);
			}
			else {
				// server hasn't been registered
				exchanger.sendCommand( new Command( Command.ERROR_GRIT, command.address.host, command.address.port, command.connectionID, true, 
						new Error( WireErrorMessages.SERVER_NOTFOUND ) ) );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function connectServerExternal( command : Command ) : void {
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function registerExternal( command : Command ) : void {
			var descriptor : ServerDescriptor = command.body as ServerDescriptor;
			if ( descriptor && descriptor.type == ServerTypes.INTERNAL ) {
				// add new server
				var server : IServer = new ServerExternal( command.address, exchanger );
				servers.add( command.address, server );
				// server has been registered
				exchanger.sendCommand( new Command( Command.REGISTER_SERVER, command.address.host, command.address.port, 0, true ) );
			}
			else {
				exchanger.sendCommand( new Command( Command.UNREGISTER_SERVER, command.address.host,
							command.address.port, 0, true, new Error( WireErrorMessages.SERVER_UNTYPED ) ) );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function unregisterExternal( command : Command ) : void {
			var server : IServer = servers.remove( command.address ) as IServer;
			if ( server ) {	
				server.cancel();
				// server has been registered
				exchanger.sendCommand( new Command( Command.UNREGISTER_SERVER, command.address.host,
							command.address.port, 0, true, command.body ) );
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function messageExternal( command : Command ) : void {
			var publisher : IPublisher = getPublisher( command );
			if ( publisher ) publisher.publish( command.body );
		}
		
		/**
		 * @inheritDoc
		 */
		public function errorClientExternal( command : Command ) : void {
			var publisher : IPublisher = getPublisher( command );
			if ( publisher ) publisher.error( command.body );
		}
		
		/**
		 * @inheritDoc
		 */
		public function errorGritExternal( command : Command ) : void {
		}
		
		/**
		 * @inheritDoc
		 */
		public function completeExternal( command : Command ) : void {
			var publisher : IPublisher = getPublisher( command );
			if ( publisher ) publisher.complete();
		}

		
		/**
		 * @inheritDoc
		 */
		public function messageServer( command : Command ) : void {
		}
		
		/**
		 * @inheritDoc
		 */
		public function errorServer( command : Command ) : void {
		}

		
		/**
		 * @inheritDoc
		 */
		public function registerServer( descriptor : ServerDescriptor, onConnected : Function ) : IPromise {
			var def : Deferred = new Deferred();
			if ( descriptor.type == ServerTypes.INTERNAL ) {
				var address : Address = descriptor.address;
				
				if ( servers.contains( address ) ) {
					def.reject( WireErrorMessages.SERVER_EXISTS );
				}
				else {
					// add new server
					var server : IServer = new ServerInternal( address, onConnected );
					servers.add( address, server );
				
					// server registration - to cancel this server
					var reg : Registration = new Registration (
						function () : void {
							if ( server && address ) {	
								servers.remove( address );
								server.cancel();
							}
						}
					);
					def.resolve( reg );
				}
			}
			else {
				def.reject( new Error( WireErrorMessages.SERVER_UNTYPED ) );
			}
			return def.promise;
		}
		
		/**
		 * @inheritDoc
		 */
		public function connect( address : Address ) : IPromise {
			var server : IServer = servers.byKey( address ) as IServer;
			if ( server ) {
				return server.connect().onCompleted( connectionClient );
			}
			else {
				var def : Deferred = new Deferred();
				def.reject( new Error( WireErrorMessages.SERVER_NOTFOUND, address ) );
				return def.promise;
			}
		}
		
	}

}