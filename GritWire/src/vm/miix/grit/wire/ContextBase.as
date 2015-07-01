package vm.miix.grit.wire 
{
	import flash.events.Event;
	import flash.net.registerClassAlias;
	import flash.system.MessageChannel;
	import flash.system.MessageChannelState;
	import vm.miix.grit.collection.Collection;
	import vm.miix.grit.collection.Comparison;
	import vm.miix.grit.collection.FunctionMap;
	import vm.miix.grit.emitter.IPublisher;
	import vm.miix.grit.emitter.Messenger;
	import vm.miix.grit.promise.IPromise;
	
	/**
	 * base context
	 * @author Lis
	 */
	internal class ContextBase implements IContext, IMessageExchanger
	{
		
		/**
		 * compare to addresses by it string representation
		 * @param	first first address to be compared
		 * @param	second second address to be compared
		 * @return -1.0 if first is less than second, +1.0 if first is greater than second and 0 if first is equal to second
		 */
		internal static function compareAddress( first : Address, second : Address ) : Number {
			return first.toString().localeCompare( second.toString() );
		}
		
		
		// name of channels to connect to main
		internal static const incomingChannel : String = "gritMainIncomingChannel";
		internal static const outcomingChannel : String = "gritMainOutcomingChannel";
		internal static const swfWorker : String = "gritSWFWorker";
		
		// channels
		private var incomeChannel : MessageChannel;
		private var outcomeChannel : MessageChannel;
		
		// command responder functions
		private var commandResponders : FunctionMap;
		
		
		/**
		 * creating new base context
		 * @param	incomeChannel message channel to receive messages
		 * @param	outcomeChannel message channel to send messages
		 */
		public function ContextBase( incomeChannel : MessageChannel, outcomeChannel : MessageChannel ) {
			
			registerClassAlias( "miixWireAddress", Address );
			registerClassAlias( "miixWireCommand", Command );
			registerClassAlias( "miixWireDescriptor", ServerDescriptor );
			registerClassAlias( "baseError", Error );
			
			commandResponders = new FunctionMap	(
				
				Comparison.stringIncreasing,
				
				new Collection( [ Command.CONNECT, Command.CONNECT_SERVER,
								  Command.REGISTER_SERVER, Command.UNREGISTER_SERVER,
								  Command.MESSAGE, Command.ERROR_GRIT,
								  Command.ERROR_CLIENT, Command.COMPLETE,
								  Command.MESSAGE_SERVER, Command.ERROR_SERVER,
								  Command.DEPLOY_TASK, Command.UNDEPLOY_TASK,
								  Command.SHARED_CREATE, Command.SHARED_REMOVE,
								  Command.SHARED_CHECKIN, Command.SHARED_CHECKINREJECT,
								  Command.SHARED_CHECKOUT
								  ] ),
								  
				new Collection( [ connectionManager.connectExternal, connectionManager.connectServerExternal,
								  connectionManager.registerExternal, connectionManager.unregisterExternal,
							      connectionManager.messageExternal, connectionManager.errorGritExternal,
								  connectionManager.errorClientExternal, connectionManager.completeExternal,
								  connectionManager.messageServer, connectionManager.errorServer,
								  taskManager.deployExternal, taskManager.undeployExternal,
								  sharedManager.createSharedExternal, sharedManager.removeSharedExternal,
								  sharedManager.checkInExternal, sharedManager.checkInRejectExternal,
								  sharedManager.checkOutExternal
								  ] )
				
			);
			
			// outcome / income channels
			this.outcomeChannel = outcomeChannel;
			this.incomeChannel = incomeChannel;
			if ( incomeChannel ) {
				incomeChannel.addEventListener( Event.CHANNEL_MESSAGE, performMessageCycling, false, 0, true );
				incomeChannel.addEventListener( Event.CHANNEL_STATE, channelState, false, 0, true );
			}
		}
		
		
		private function channelState( e : Event = null ) : void {
			if ( incomeChannel && incomeChannel.state != MessageChannelState.OPEN ) {
				incomeChannel.removeEventListener( Event.CHANNEL_MESSAGE, performMessageCycling );
				incomeChannel.removeEventListener( Event.CHANNEL_STATE, channelState );
			}
		}
		
		
		
		/**
		 * connection manager behind this context - must be overriden
		 */
		protected function get connectionManager() : IConnectionManager {
			return null;
		}
		
		/**
		 * task manager behind this context - must be overriden
		 */
		protected function get taskManager() : ITaskManager {
			return null;
		}
		
		/**
		 * shared bytes manager behind this context - must be overriden
		 */
		protected function get sharedManager() : ISharedManager {
			return null;
		}
		
		
		/* INTERFACE vm.miix.grit.wire.IMessageExchanger */
		
		/**
		 * resends message from server to client when emitted
		 * @param	address server address
		 * @param	id connection id
		 * @param	messenger messenger to be listened / published
		 * @param	isFromServer true if resends from server and false otherwise
		 * @param	isExternal true if resends message as SERVER
		 */
		public function resendExternal( address : Address, id : uint, messenger : Messenger,
				isFromServer : Boolean, isExternal : Boolean ) : void
		{
			if ( outcomeChannel ) {
				
				var strMSG : String = isExternal ? Command.MESSAGE_SERVER : Command.MESSAGE;
				var strComplete : String = isExternal ? Command.UNREGISTER_SERVER : Command.COMPLETE;
				var strErr : String = isExternal ? Command.ERROR_SERVER : Command.ERROR_CLIENT;
				
				messenger.emitter.subscribe (
					// value emitted
					function ( body : * ) : void {
						if ( messenger ) {
							if ( outcomeChannel.state == MessageChannelState.OPEN ) {
								try {
									sendCommand( new Command( strMSG, address.host, address.port,
											id, isFromServer, body ) );
								}
								catch ( err : Error ) {
									messenger.publisher.error( err );
								}
							}
							else {
								var tmp : IPublisher = messenger.publisher;
								messenger = null;
								if ( tmp ) {
									tmp.complete();
									tmp = null;
								}
							}
						}
					},
					// completed
					function () : void {
						if ( messenger ) {
							if ( outcomeChannel.state == MessageChannelState.OPEN ) {
								try {
									sendCommand( new Command( strComplete, address.host, address.port,
											id, isFromServer, undefined ) );
								}
								catch ( err : Error ) {
									messenger.publisher.error( err );
								}
							}
							else {
								var tmp : IPublisher = messenger.publisher;
								messenger = null;
								if ( tmp ) {
									tmp.complete();
									tmp = null;
								}
							}
						}
					},
					// error
					function ( reason : * ) : void {
						if ( messenger ) {
							if ( outcomeChannel.state == MessageChannelState.OPEN ) {
								try {
									sendCommand( new Command( strErr, address.host, address.port,
											id, isFromServer, reason ) );
								}
								catch ( err : Error ) {
									messenger.publisher.error( err );
								}
							}
							else {
								var tmp : IPublisher = messenger.publisher;
								messenger = null;
								if ( tmp ) {
									tmp.complete();
									tmp = null;
								}
							}
						}
					}
				);
			}
		}
		
		/**
		 * send command to external thread
		 * @param	command command to be send
		 */
		public function sendCommand( command : Command ) : void {
			if ( outcomeChannel && outcomeChannel.state == MessageChannelState.OPEN ) {
				outcomeChannel.send( command );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function performMessageCycling( event : Event = null ) : void {
			if ( incomeChannel ) {
				while ( incomeChannel.messageAvailable ) {
					var command : Command = incomeChannel.receive() as Command;
					if ( command != null ) commandResponders.invoke( command.command, command );
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get messageAvailable() : Boolean {
			return incomeChannel && incomeChannel.messageAvailable;
		}

		
		
		/* INTERFACE vm.miix.grit.wire.IContext */
		
		/**
		 * @inheritDoc
		 */
		public function registerServer( descriptor : ServerDescriptor, onConnected : Function ) : IPromise {
			return connectionManager.registerServer( descriptor, onConnected );
		}
		
		/**
		 * @inheritDoc
		 */
		public function connect( address : Address ) : IPromise {
			return connectionManager.connect( address );
		}
		
		/**
		 * @inheritDoc
		 */
		public function deploy( qualifiedClassName : String, param : * = undefined ) : IPromise {
			return taskManager.deploy( qualifiedClassName, param );
		}
		
		/**
		 * @inheritDoc
		 */
		public function createSharedBytes( name : String ) : IPromise {
			return sharedManager.createSharedBytes( name );
		}
		
		/**
		 * @inheritDoc
		 */
		public function checkInSharedBytes( name : String ) : IPromise {
			return sharedManager.checkInSharedBytes( name );
		}
		
	}

}