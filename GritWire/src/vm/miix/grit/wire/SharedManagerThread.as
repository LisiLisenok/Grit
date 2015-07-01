package vm.miix.grit.wire 
{
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import vm.miix.grit.collection.Comparison;
	import vm.miix.grit.collection.IIterator;
	import vm.miix.grit.collection.List;
	import vm.miix.grit.collection.MapSet;
	import vm.miix.grit.promise.Deferred;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.trigger.Registration;
	
	/**
	 * shared manager used within <code>thread context</code>
	 * @see vm.miix.grit.wire.ContextThread
	 * @author Lis
	 */
	internal class SharedManagerThread implements ISharedManager 
	{
		
		/**
		 * exchnging messages with external thread
		 */
		private var exchanger : IMessageExchanger;
		
		
		/**
		 * map of deferred waiting shared bytes creation
		 */
		private var waitersCreation : MapSet = new MapSet( Comparison.stringIncreasing );
		
		/**
		 * map of List of Deferred waiting shared bytes checkining
		 */
		private var waitersCheckIn : MapSet = new MapSet( Comparison.stringIncreasing );
		
		
		
		public function SharedManagerThread( exchanger : IMessageExchanger ) {
			this.exchanger = exchanger;
		}
		
		
		
		/* INTERFACE vm.miix.grit.wire.ISharedManager */
		
		/**
		 * shared bytes has been created or rejected - notify recipient
		 * @param	command related command
		 */
		public function createSharedExternal( command : Command ) : void {
			var name : String = command.address.host;
			// reject creation if reason exists
			if ( command.body ) checkInRejectExternal( command );
			
			var def : Deferred = waitersCreation.remove( name ) as Deferred;
			if ( def ) {
				if ( command.body ) {
					// creation rejected
					def.reject( command.body );
				}
				else {
					// successfully created
					def.resolve( new Registration(
						function () : void {
							exchanger.sendCommand( new Command( Command.SHARED_REMOVE, name, 0, 0, false,
								new Error( WireErrorMessages.SHARED_REMOVEDBYOWNER ) ) );
						}
					) );
				}
			}
		}
		
		/**
		 * shared bytes has been removed
		 * @param	command related command
		 */
		public function removeSharedExternal( command : Command ) : void {
			checkInRejectExternal( command );
			var def : Deferred = waitersCreation.remove( command.address.host ) as Deferred;
			if ( def ) def.reject( command.body );
		}
		
		/**
		 * do check in
		 * @param	command related command
		 */
		public function checkInExternal( command : Command ) : void {
			var name : String = command.address.host;
			var list : List = waitersCheckIn.byKey( name ) as List;
			var bCheckOut : Boolean = true;
			
			if ( list && !list.empty ) {
				var def : Deferred = list.accept() as Deferred;
				if ( list.empty ) waitersCheckIn.remove( name );
				if ( def ) {
					var byteArray : ByteArray = Worker.current.getSharedProperty( command.body as String ) as ByteArray;
					if ( byteArray != null ) {
						// cancel immedite check out
						bCheckOut = false;
						// resolve with shared bytes
						def.resolve( new SharedBytes( byteArray,
							function () : void {
								exchanger.sendCommand( new Command( Command.SHARED_CHECKOUT, name ) );
							}
						) );
					}
					else {
						// reject promise
						def.reject( new Error( WireErrorMessages.SHARED_NOTEXISTS ) );
					}
				}
			}
			
			if ( bCheckOut ) {
				// no one can check in
				exchanger.sendCommand( new Command( Command.SHARED_CHECKOUT, name ) );
			}
		}

		/**
		 * @inheritDoc
		 */
		public function checkInRejectExternal( command : Command ) : void {
			var list : List = waitersCheckIn.byKey( command.address.host ) as List;
			if ( list ) {
				list.lock();
				var iter : IIterator = list.iterator;
				while ( iter.hasNext() ) {
					var def : Deferred = iter.next() as Deferred;
					if ( def ) def.reject( command.body );
				}
				list.unlock();
				list.clear();
				waitersCheckIn.remove( command.address.host );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function checkOutExternal( command : Command ) : void {
			// do nothing
		}
		
		
		
		/**
		 * @inheritDoc
		 */
		public function createSharedBytes( name : String ) : IPromise {
			var def : Deferred = new Deferred();
			waitersCreation.add( name, def );
			exchanger.sendCommand( new Command( Command.SHARED_CREATE, name ) );
			return def.promise;
		}
		
		/**
		 * @inheritDoc
		 */
		public function checkInSharedBytes( name : String ) : IPromise {
			var def : Deferred = new Deferred();
			var list : List = waitersCheckIn.byKey( name ) as List;
			if ( list == null ) {
				list = new List();
				waitersCheckIn.add( name, list );
			}
			list.push( def );
			exchanger.sendCommand( new Command( Command.SHARED_CHECKIN, name ) );
			return def.promise;
		}
		
	}

}