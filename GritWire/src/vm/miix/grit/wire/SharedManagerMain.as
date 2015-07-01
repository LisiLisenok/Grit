package vm.miix.grit.wire 
{
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import vm.miix.grit.collection.Comparison;
	import vm.miix.grit.collection.MapSet;
	import vm.miix.grit.promise.Deferred;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.trigger.Registration;
	
	/**
	 * manages shared bytes within main context
	 * @see vm.miix.grit.wire.ContextMain
	 * @author Lis
	 */
	internal class SharedManagerMain implements ISharedManager 
	{
		
		/**
		 * exchnging messages with external thread
		 */
		private var exchanger : IMessageExchanger;
		
		
		/**
		 * maps names of shared bytes with actual ones
		 */
		private var nameMapping : MapSet = new MapSet( Comparison.stringIncreasing );
		
		/**
		 * map of SharedValues with queue of shared bytes checkining (external thread or this thread)
		 */
		private var checkInQueue : MapSet = new MapSet( Comparison.stringIncreasing );
		
		/**
		 * worker to exchange shared properties
		 */
		private var swfWorker : Worker;
		
		
		/**
		 * create new manager of shared bytes within main grit context
		 * @param	exchanger
		 */
		public function SharedManagerMain( exchanger : IMessageExchanger ) {
			this.exchanger = exchanger;
			swfWorker = Worker.current.getSharedProperty( ContextBase.swfWorker );
		}
		
		
		/**
		 * convert name of shared bytes to actual name of shared property
		 * used to prevent access to byte array outside shared byte
		 * @param	name name to be converted
		 * @return name of shared property
		 * @see  flash.system.Worker#getSharedProperty
		 * @see  flash.system.Worker#setSharedProperty
		 */
		private static function toActual( name : String ) : String {
			return name + String( getTimer() );
		}
		
		/**
		 * remove shared byte with name <code>name</code>
		 * @param	name name of shred byte to be removed
		 * @param	reason reason of removing
		 */
		private function removeShared( name : String, reason : * ) : void {
			// remove property
			swfWorker.setSharedProperty( nameMapping.remove( name ) as String, null );
			// reject all items in check in queue
			var sh : SharedQueue = checkInQueue.remove( name ) as SharedQueue;
			if ( sh ) sh.reject( reason ) 
			exchanger.sendCommand( new Command( Command.SHARED_REMOVE, name, 0, 0, false, reason ) );
		}
		
		
		/* INTERFACE vm.miix.grit.wire.ISharedManager */
		
		/**
		 * @inheritDoc
		 */
		public function createSharedExternal( command : Command ) : void {
			var name : String = command.address.host;
			if ( swfWorker.getSharedProperty( nameMapping.byKey( name ) as String ) == null ) {
				var actualName : String = toActual( name );
				nameMapping.add( name, actualName );
				var ba : ByteArray = new ByteArray();
				ba.shareable = true;
				swfWorker.setSharedProperty( actualName, ba );
				exchanger.sendCommand( new Command( Command.SHARED_CREATE, name ) );
			}
			else {
				// reject creation - already exists
				exchanger.sendCommand( new Command( Command.SHARED_CREATE, name, 0, 0, false,
					new Error( WireErrorMessages.SHARED_NOTEXISTS ) ) );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeSharedExternal( command : Command ) : void {
			removeShared( command.address.host, command.body );
		}
		
		/**
		 * @inheritDoc
		 */
		public function checkInExternal( command : Command ) : void {
			var name : String = command.address.host;
			if ( swfWorker.getSharedProperty( nameMapping.byKey( name ) as String ) != null ) {
				var sh : SharedQueue = checkInQueue.byKey( name ) as SharedQueue;
				if ( sh == null ) {
					sh = new SharedQueue();
					checkInQueue.add( name, sh );
				}
				var defWait : Deferred = new Deferred();
				defWait.promise.onCompleted (
					function ( val : * ) : void {
						exchanger.sendCommand( new Command( Command.SHARED_CHECKIN, name, 0, 0, false, nameMapping.byKey( name ) ) );
					},
					function ( reason : * ) : void {
						exchanger.sendCommand( new Command( Command.SHARED_CHECKINREJECT, name, 0, 0, false, reason ) );
					}
				);
				sh.add( defWait );
			}
			else {
				exchanger.sendCommand( new Command( Command.SHARED_CHECKINREJECT, name, 0, 0, false,
					new Error( WireErrorMessages.SHARED_NOTEXISTS ) ) );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function checkInRejectExternal( command : Command ) : void {
			// do nothing
		}
		
		/**
		 * @inheritDoc
		 */
		public function checkOutExternal( command : Command ) : void {
			var sh : SharedQueue = checkInQueue.byKey( command.address.host ) as SharedQueue;
			if ( sh ) sh.checkOut();
		}
		
		
		
		/**
		 * @inheritDoc
		 */
		public function createSharedBytes( name : String ) : IPromise {
			var def : Deferred = new Deferred();
			if ( swfWorker.getSharedProperty( nameMapping.byKey( name ) as String ) == null ) {
				// create shared property with actualName instead of name in order to prevent access to byArray outside sharedBytes
				var actualName : String = toActual( name );
				nameMapping.add( name, actualName );
				var ba : ByteArray = new ByteArray();
				ba.shareable = true;
				swfWorker.setSharedProperty( actualName, ba );
				// resolve creation
				def.resolve( new Registration (
					function () : void {
						removeShared( name, new Error( WireErrorMessages.SHARED_REMOVEDBYOWNER ) );
					}
				) );
			}
			else {
				def.reject( new Error( WireErrorMessages.SHARED_ALREADYEXISTS ) );
			}
			return def.promise;
		}
		
		/**
		 * @inheritDoc
		 */
		public function checkInSharedBytes( name : String ) : IPromise {
			var def : Deferred = new Deferred();
			if ( swfWorker.getSharedProperty( nameMapping.byKey( name ) as String ) != null ) {
				// queue of check in waiters
				var sh : SharedQueue = checkInQueue.byKey( name ) as SharedQueue;
				if ( sh == null ) {
					sh = new SharedQueue();
					checkInQueue.add( name, sh );
				}
				// resolve promise with sharedBytes, when available
				var defWait : Deferred = new Deferred();
				defWait.promise.onCompleted (
					
					// sharedBytes can be checked in
					function ( val : * ) : void {
						var byteArray : ByteArray = swfWorker.getSharedProperty( nameMapping.byKey( name ) as String ) as ByteArray;
						if ( byteArray ) {
							def.resolve( new SharedBytes( byteArray, function () : void {
								var sh : SharedQueue = checkInQueue.byKey( name ) as SharedQueue;
								if ( sh ) sh.checkOut();
							} ) );
						}
						else {
							def.reject( new Error( WireErrorMessages.SHARED_NOTEXISTS ) );
						}
					},
					
					// rejecting if some errors
					def.reject
					
				);
				
				sh.add( defWait );
			}
			else {
				def.reject( new Error( WireErrorMessages.SHARED_NOTEXISTS ) );
			}
			return def.promise;
		}
		
	}

}