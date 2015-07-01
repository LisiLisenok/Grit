package vm.miix.grit.wire 
{
	import flash.system.MessageChannel;
	
	/**
	 * context runned in thread separated from main
	 * @author Lis
	 */
	internal class ContextThread extends ContextBase 
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
		
		
		
		/**
		 * creating new thread context
		 * @param	incomeChannel message channel to receive messages
		 * @param	outcomeChannel message channel to send messages
		 */
		public function ContextThread( incomeChannel : MessageChannel, outcomeChannel : MessageChannel ) {
			// create managers before calling super - in order to install message listeners
			_connectionManager = new ConnectionManagerThread( this );
			_taskManager = new TaskManagerThread( this );
			_sharedManager = new SharedManagerThread( this );
			
			super( incomeChannel, outcomeChannel );
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