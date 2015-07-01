package vm.miix.grit.wire 
{
	import vm.miix.grit.collection.MapSet;
	import vm.miix.grit.promise.Deferred;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.trigger.Registration;
	
	/**
	 * manage tasks within thread context
	 * @see vm.miix.grit.wire.ContextThread
	 * @author Lis
	 */
	internal class TaskManagerThread implements ITaskManager 
	{
		
		/**
		 * exchnging messages with external thread
		 */
		private var exchanger : IMessageExchanger;
		
		
		/**
		 * waiters of task deployement as <code>Deferred</code>
		 */
		private var _waitDeploy : MapSet = new MapSet( ContextBase.compareAddress );
		
		/**
		 * last deployed task id
		 */
		private var _lastTaskID : uint = 0;
		
		
		public function TaskManagerThread( exchanger : IMessageExchanger ) {
			this.exchanger = exchanger;
		}
		
		
		
		/* INTERFACE vm.miix.grit.wire.ITaskManager */
		
		/**
		 * @inheritDoc
		 */
		public function deployExternal( command : Command ) : void {
			var address : Address = command.address.clone();
			var def : Deferred = _waitDeploy.remove( address ) as Deferred;
			if ( def ) {
				def.resolve( new Registration (
						function () : void {
							exchanger.sendCommand( new Command( Command.UNDEPLOY_TASK, address.host, address.port ) );
						}
					)
				);
			}
		}
		
		/**
		 * task has been deployed - notify deployer
		 * @param	command command with details
		 */
		public function undeployExternal( command : Command ) : void {
			var def : Deferred = _waitDeploy.remove( command.address ) as Deferred;
			if ( def ) def.reject( command.body );
		}
		
		/**
		 * error during task deployement - notify deployer
		 * @param	command command with details
		 */
		public function deploy( qualifiedClassName : String, param : * = undefined ) : IPromise {
			var def : Deferred = new Deferred();
			var address : Address = new Address( qualifiedClassName, _lastTaskID ++ );
			_waitDeploy.add( address, def );
			exchanger.sendCommand( new Command( Command.DEPLOY_TASK, address.host, address.port, 0, false, param ) );
			return def.promise;
		}
		
	}

}