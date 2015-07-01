package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Worker;
	import flash.utils.getQualifiedClassName;
	import vm.miix.grit.emitter.Messenger;
	import vm.miix.grit.wire.Address;
	import vm.miix.grit.wire.GritTask;
	import vm.miix.grit.wire.GritWire;
	import vm.miix.grit.wire.IContext;
	import vm.miix.grit.wire.ITask;
	
	
	public class ServerTestMain extends Sprite
	{
		
		// main or sub-thread context depending on worker
		private var wireContext : IContext;
	
		
		public function ServerTestMain() {
			
			if ( Worker.current.isPrimordial ) {
				// main thread
				if ( stage ) init();
				else addEventListener( Event.ADDED_TO_STAGE, init );
			}
			else {
				// secondary thread - instantiate GritTask as thread context
				wireContext = new GritTask();
			}
		}
		
		
		private function init( e : Event = null ) : void {
			
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			// primordial thread - instantiate GritWire as thread context
			var wire : GritWire = new GritWire();
			wireContext = wire;
			
			// start the grit
			wire.start( loaderInfo.bytes ).onCompleted (
				started, // function called when secondary thread is started
				function ( reason : * ) : void { trace( reason ); }
			);
		}
		
		private function started( context : IContext ) : void {
			// grit has been started - deploy tasks, create connections etc
			
			context.deploy( getQualifiedClassName( ServerTestTask ) ).onCompleted (
				function ( val : * ) : void {
					context.connect( new Address( "ServerAddress" ) ).onCompleted ( 						
						function ( messenger : Messenger ) : void {
							messenger.emitter.subscribe	( 
								function ( info : String ) : void {
									trace( "server said: ", info );
								}
							);
							messenger.publisher.publish( "Hello, Server!" );
						},
						function ( reason : * ) : void { trace( "not connected: ", reason ); } );
				}
			);
			
		}
		
	}
					
}

