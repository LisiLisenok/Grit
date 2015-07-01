package vm.miix.grit.wire 
{
	import vm.miix.grit.collection.List;
	import vm.miix.grit.emitter.Messenger;
	import vm.miix.grit.promise.Deferred;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.trigger.IRegistration;
	import vm.miix.grit.trigger.ITriggered;
	
	/**
	 * context manages only one task.
	 * All connection, servers and shared bytes opened by this task are closed when task is completed.
	 * While all tasks deployed from this task continue to work
	 * @author Lis
	 */
	internal class ContextTask implements IContext 
	{
		
		private static function closeRegistration( reg : IRegistration ) : void { reg.cancel(); }
		private static function closeConnection( messenger : Messenger ) : void { messenger.publisher.complete(); }
		
		/**
		 * parent context to delegate all operations
		 */
		private var _parent : IContext;
		
		/**
		 * task run on this context
		 */
		private var _task : ITask;
		
		
		/**
		 * servers opened within this context
		 */
		private var _servers : List = new List();
		
		/**
		 * connections opened within this context
		 */
		private var _connections : List = new List();
		
		/**
		 * shared bytes created within this context
		 */
		private var _shareds : List = new List();
		
		
		public function ContextTask( parent : IContext, task : ITask ) {
			this._parent = parent;
			this._task = task;
		}
		
		/**
		 * task behind this context
		 */
		internal function get task() : ITask { return _task; }
		
		/**
		 * close all servers and connections related to this context
		 */
		internal function close() : void {
			
			_parent = null;
			_task = null;
			
			// close connections
			_connections.lock();
			_connections.forEach( closeConnection );
			_connections.unlock();
			_connections.clear();
			
			// close servers
			_servers.lock();
			_servers.forEach( closeRegistration );
			_servers.unlock();
			_servers.clear();
			
			// close shared bytes
			_shareds.lock();
			_shareds.forEach( closeRegistration );
			_shareds.unlock();
			_shareds.clear();
		
		}
		
		/**
		 * store new server registration
		 * @param	registration server registration
		 * @return registration to complete submited registration and remove it from list
		 */
		private function addServer( registration : IRegistration ) : IRegistration {
			var reg : RegistrationWrapper = new RegistrationWrapper( registration );
			reg.triggered = _servers.add( reg );
			return reg;
		}
		
		/**
		 * add connection opened within this context
		 * @param	messenger connection messenger
		 */
		private function addConnection( messenger : Messenger ) : void {
			var trig : ITriggered = _connections.add( messenger );
			messenger.emitter.subscribe( null, trig.cancel );
		}
		
		/**
		 * store new shared bytes registration
		 * @param	registration shared bytes registration
		 * @return registration to complete submited registration and remove it from list
		 */
		private function addShared( registration : IRegistration ) : IRegistration {
			var reg : RegistrationWrapper = new RegistrationWrapper( registration );
			reg.triggered = _shareds.add( reg );
			return reg;
		}

		
		
		/* INTERFACE vm.miix.grit.wire.IContext */
		
		/**
		 * @inheritDoc
		 */
		public function registerServer( descriptor : ServerDescriptor, onConnected : Function ) : IPromise {
			if ( _parent ) {
				return _parent.registerServer( descriptor, onConnected ).onCompleted( addServer );
			}
			else {
				var def : Deferred = new Deferred();
				def.reject( new Error( WireErrorMessages.TASK_COMPLETED ) );
				return def.promise;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function connect( address : Address ) : IPromise {
			if ( _parent ) {
				var promise : IPromise = _parent.connect( address );
				promise.onCompleted( addConnection );
				return promise;
			}
			else {
				var def : Deferred = new Deferred();
				def.reject( new Error( WireErrorMessages.TASK_COMPLETED ) );
				return def.promise;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function deploy( qualifiedClassName : String, param : * = undefined ) : IPromise {
			if ( _parent ) {
				return _parent.deploy( qualifiedClassName, param );
			}
			else {
				var def : Deferred = new Deferred();
				def.reject( new Error( WireErrorMessages.TASK_COMPLETED ) );
				return def.promise;
			}
		}
		
		
		
		/**
		 * @inheritDoc
		 */
		public function createSharedBytes( name : String ) : IPromise {
			if ( _parent ) {
				return _parent.createSharedBytes( name ).onCompleted( addShared );
			}
			else {
				var def : Deferred = new Deferred();
				def.reject( new Error( WireErrorMessages.TASK_COMPLETED ) );
				return def.promise;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function checkInSharedBytes( name : String ) : IPromise {
			if ( _parent ) {
				return _parent.checkInSharedBytes( name );
			}
			else {
				var def : Deferred = new Deferred();
				def.reject( new Error( WireErrorMessages.TASK_COMPLETED ) );
				return def.promise;
			}
		}
		
		
	}

}