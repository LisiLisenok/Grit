package vm.miix.grit.wire 
{
	import flash.utils.getDefinitionByName;
	import vm.miix.grit.collection.MapSet;
	import vm.miix.grit.promise.Deferred;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.trigger.IRegistration;
	import vm.miix.grit.trigger.Registration;
	/**
	 * manages tasks within main context
	 * @author Lis
	 */
	internal class TaskManagerMain implements ITaskManager, IContext 
	{
		
		/**
		 * exchnging messages with external thread
		 */
		private var exchanger : IMessageContext;
		
		
		/**
		 * specific task contexts deployed within this context
		 * @see vm.miix.grit.wire.ContextTask
		 */
		private var taskContexts : MapSet = new MapSet( ContextBase.compareAddress );
		
		/**
		 * last id of deployed task
		 */
		private var lastTaskID : uint = 0;
		
		/**
		 * tasks deployed within thread context
		 * @see vm.miix.grit.wire.ContextTask
		 */
		private var externalTaskContexts : MapSet = new MapSet( ContextBase.compareAddress );
				
		
		
		public function TaskManagerMain( exchanger : IMessageContext ) {
			this.exchanger = exchanger;
		}
		
		
		
		/**
		 * reject task deployement
		 * @return promise already rejected with error
		 */
		private function rejectDeployement() : IPromise {
			var def : Deferred = new Deferred();
			def.reject( new Error( WireErrorMessages.TASK_NOTRUNNABLE ) );
			return def.promise;
		}
		
		
		/* INTERFACE vm.miix.grit.wire.ITaskManager */
		
		/**
		 * @inheritDoc
		 */
		public function deployExternal( command : Command ) : void {
			var address : Address = command.address.clone();
			try {
				var cc : Class = getDefinitionByName( address.host ) as Class;
				var task : ITask;
				if ( cc ) task = new cc();
				else task = null;
			}
			catch ( err : Error ) {
				// task can't be created (doesn't satisfy ITask interface or incorrect name)
				exchanger.sendCommand( new Command( Command.UNDEPLOY_TASK, address.host, address.port, 0, false,
					new Error( err.message ) ) );
			}
			if ( task ) {
				// run task on each own context in order to free all connections and servers opened within the task
				// when task is closing
				var context : ContextTask = new ContextTask( this, task );
				externalTaskContexts.add( address, context );
				
				// task registration - cancel the task externaly
				var registration : Registration = new Registration( function() : void {
						closeTask( new Error( WireErrorMessages.TASK_COMPLETED ) );
					}
				);
				try {
					// run task
					var taskPromise : IPromise = task.run( context, registration, command.body );
					if ( taskPromise ) {
						taskPromise.onCompleted (
							function( val : * ) : void {
								if ( address ) {
									exchanger.sendCommand( new Command( Command.DEPLOY_TASK, address.host, address.port ) );
									address = null;
								}
							},
							closeTask
						);
					}
					else if ( address ) {
						exchanger.sendCommand( new Command( Command.DEPLOY_TASK, address.host, address.port ) );
						address = null;
					}
				}
				catch ( err : Error ) {
					closeTask( new Error( err.message ) );
				}
			}
			else {
				exchanger.sendCommand( new Command( Command.UNDEPLOY_TASK, address.host, address.port, 0, false,
						new Error( WireErrorMessages.TASK_NOTRUNNABLE ) ) );
			}
			
			
			function closeTask( reason : * ) : void {
				if ( context && address ) {
					var tmpAddress : Address = address;
					address = null;
					var tmpContext : ContextTask = context;
					context = null;
					externalTaskContexts.remove( tmpAddress );
					tmpContext.close();
					exchanger.sendCommand( new Command( Command.UNDEPLOY_TASK, tmpAddress.host,
								tmpAddress.port, 0, false, reason ) );
					tmpAddress = null;
					tmpContext = null;
				}
			}
			
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function undeployExternal( command : Command ) : void {
			var context : ContextTask = externalTaskContexts.remove( command.address ) as ContextTask;
			if ( context ) context.close();
		}
		
		/**
		 * @inheritDoc
		 */
		public function deploy( qualifiedClassName : String, param : * = undefined ) : IPromise {
			try {
				// create task from class name
				var cc : Class = getDefinitionByName( qualifiedClassName ) as Class;
				var task : ITask;
				if ( cc ) task = new cc();
				else task = null;
			}
			catch ( err : Error ) {
				// task can't be created (doesn't satisfy ITask interface or incorrect name)
				return rejectDeployement();
			}
			if ( task ) {
				// run task on each own context in order to free all connections and servers opened within the task
				// when task is closing
				var address : Address = new Address( qualifiedClassName, lastTaskID ++ );
				var context : ContextTask = new ContextTask( this, task );
				taskContexts.add( address, context );
				var def : Deferred = new Deferred();
				
				// task registration - cancel the task externaly
				var registration : Registration = new Registration( function() : void {
						if ( address && context ) {
							var tmpAddress : Address = address;
							address = null;
							var tmpContext : ContextTask = context;
							context = null;
							taskContexts.remove( tmpAddress );
							tmpContext.close();
							tmpAddress = null;
							tmpContext = null;
						}
					}
				);
				try {
					// run task
					var taskPromise : IPromise = task.run( context, registration, param );
					if ( taskPromise ) {
						def.resolve( taskPromise.map( function ( val : * ) : IRegistration { return registration; } ) );
					}
					else {
						def.resolve( registration );
					}
				}
				catch ( err : Error ) {
					registration.cancel();
					def.reject( err );
				}
				return def.promise;
			}
			else return rejectDeployement();
		}
		
				
		/* INTERFACE vm.miix.grit.wire.IContext */
		
		/**
		 * @inheritDoc
		 */
		public function registerServer( descriptor : ServerDescriptor, onConnected : Function ) : IPromise {
			return exchanger.registerServer( descriptor, onConnected );
		}
		
		/**
		 * @inheritDoc
		 */
		public function connect( address : Address ) : IPromise {
			return exchanger.connect( address );
		}
		
		/**
		 * @inheritDoc
		 */
		public function createSharedBytes( name : String ) : IPromise {
			return exchanger.createSharedBytes( name );
		}
		
		/**
		 * @inheritDoc
		 */
		public function checkInSharedBytes( name : String ) : IPromise {
			return exchanger.checkInSharedBytes( name );
		}
		

	}

}