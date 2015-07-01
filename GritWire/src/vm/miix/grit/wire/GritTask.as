package vm.miix.grit.wire 
{
	import vm.miix.grit.promise.IPromise;
	
	/**
	 * grit task - is grit context within background worker.
	 * Must be created using the same swf file as main thread as in order to have posibilities to instntiate tasks
	 * using class qualified name.
	 * In main swf thread <code>GritWire</code> manages tasks, connections and share bytes
	 * @example grit usage:
		 * <ul>
		 * <li>main or primordial swf file is used to create secondary thread</li>
		 * <li>instantiate and start <code>GritWire</code> at main or primordial thread</li>
		 * <li>instantiate <code>GritTask</code> at secondary thread</li>
		 * <li>deploy task, which implements <code>ITask</code> interface</li>
		 * <li>task registers server and listen on</li>
		 * <li>when task is started, server is connected from main thread and send message to </li>
		 * </ul>
		 * 
			<listing>
				
				// main class - initialize Grit, deploy server and connect to
				public class ServerTestMain extends Sprite
				{
		
					// main or sub-thread context
					private var wireContext : IContext;
	
					public function ServerTestMain() {
						if ( Worker.current.isPrimordial ) {
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
		
					
					// grit is started - deploy tasks, create connections etc
					private function started( context : IContext ) : void {			
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

	
				// task, which creates server and listen on
				public class ServerTestTask implements ITask
				{
		
					public function ServerTestTask() {
			
					}
	
					private function onServer( messenger : Messenger ) : void {
						messenger.emitter.subscribe (
							function ( info : String ) : void {
								trace( "Server receives: ", info );
								messenger.publisher.publish( "Hello!" );
							}
						);
					}
		
					public function run( context : IContext, registration : IRegistration, param : * ) : IPromise {
						return context.registerServer ( new ServerDescriptor( new Address( "ServerAddress" ),
							ServerTypes.INTERNAL ), onServer );
					}
		
				}
				
			</listing>
	 * @see vm.miix.grit.wire.GritWire
	 * @author Lis
	 */
	public class GritTask implements IContext 
	{
		
		private var context : IContext;
		
		public function GritTask() {
			context = new ContextMain();
		}
		

		/* INTERFACE vm.miix.grit.wire.IContext */
		
		/**
		 * @inheritDoc
		 */
		public function registerServer( descriptor : ServerDescriptor, onConnected : Function ) : IPromise {
			return context.registerServer( descriptor, onConnected );
		}
		
		/**
		 * @inheritDoc
		 */
		public function connect( address : Address ) : IPromise {
			return context.connect( address );
		}
		
		/**
		 * @inheritDoc
		 */
		public function deploy( qualifiedClassName : String, param : * = undefined ) : IPromise {
			return context.deploy( qualifiedClassName, param );
		}
		
		/**
		 * @inheritDoc
		 */
		public function createSharedBytes( name : String ) : IPromise {
			return context.createSharedBytes( name );
		}
		
		/**
		 * @inheritDoc
		 */
		public function checkInSharedBytes( name : String ) : IPromise {
			return context.checkInSharedBytes( name );
		}
		
	}

}