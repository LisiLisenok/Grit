package vm.miix.grit.wire 
{
	import flash.system.Worker;
	
	/**
	 * main context
	 * @author Lis
	 */
	internal class ContextMain extends ContextBase implements IMessageContext
	{
	
		/**
		 * manage connections within this context
		 */
		private var _connectionManager : IConnectionManager;
		
		/**
		 * manage tasks within this context
		 */
		private var _taskManager : ITaskManager;
		
		/**
		 * manage shared bytes within this context
		 */
		private var _sharedManager : ISharedManager;
		
		
		
		public function ContextMain() {
			// create managers before calling super - in order to install message listeners
			_connectionManager = new ConnectionManagerMain( this );
			_taskManager = new TaskManagerMain( this );
			_sharedManager = new SharedManagerMain( this );
			
			super( Worker.current.getSharedProperty( incomingChannel ), Worker.current.getSharedProperty( outcomingChannel ) );
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function get connectionManager() : IConnectionManager { return _connectionManager; }
		
		/**
		 * @inheritDoc
		 */
		override protected function get taskManager() : ITaskManager { return _taskManager; }
		
		/**
		 * @inheritDoc
		 */
		override protected function get sharedManager() : ISharedManager { return _sharedManager; }
		
	}

}