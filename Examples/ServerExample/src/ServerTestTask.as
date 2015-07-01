package 
{
	import vm.miix.grit.emitter.Messenger;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.trigger.IRegistration;
	import vm.miix.grit.wire.Address;
	import vm.miix.grit.wire.IContext;
	import vm.miix.grit.wire.ITask;
	import vm.miix.grit.wire.ServerDescriptor;
	import vm.miix.grit.wire.ServerTypes;
	
	/**
	 * example: task registered server
	 * @author Lis
	 */
	public class ServerTestTask implements ITask
	{
		
		public function ServerTestTask() {
			
		}
	
		// new connection to the server
		private function onServer( messenger : Messenger ) : void {
			// trace received data and reply with "Hello!" message
			messenger.emitter.subscribe (
				function ( info : String ) : void {
					trace( "Server receives: ", info );
					messenger.publisher.publish( "Hello!" );
				}
			);
		}
		
		/**
		 * @inheritDoc
		 */
		public function run( context : IContext, registration : IRegistration, param : * ) : IPromise {
			// register server with host "ServerAddress" at start
			return context.registerServer ( new ServerDescriptor( new Address( "ServerAddress" ),
				ServerTypes.INTERNAL ), onServer );
		}
		
	}

}