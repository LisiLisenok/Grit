package vm.miix.grit.wire 
{
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	import vm.miix.grit.promise.Deferred;
	import vm.miix.grit.promise.IPromise;
	
	/**
	 * main class of GritWire within main swf thread.
	 * Manages servers, connections and tasks within main swf thread.
	 * <code>GritTask</code> manages servers, connections and tasks within secondary swf thread.
	 * @example grit usage:
		 * <ul>
		 * <li>main or primordial swf file is used to create secondary thread</li>
		 * <li>instantiate and start <code>GritWire</code> at main or primordial thread</li>
		 * <li>instantiate <code>GritTask</code> at secondary thread</li>
		 * <li>deploy task, which implements <code>ITask</code> interface</li>
		 * <li>task registers server and listen on</li>
		 * <li>when task is started, server is connected from main thread and send message to </li>
		 * </ul>
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
	 * @see vm.miix.grit.wire.GritTask
	 * @author Lis
	 */
	public class GritWire implements IContext 
	{
		// underlaying context
		private var context : ContextThread;
		// thread worker
		private var gritWorker : Worker;
		// deferred returned from start
		private var defStart : Deferred;
		
		
		public function GritWire() {
		}
		
		
		private function onWorkerState( e : Event ) : void {
			if ( gritWorker.state != WorkerState.NEW ) {
				gritWorker.removeEventListener( Event.WORKER_STATE, onWorkerState );
				if ( gritWorker.state == WorkerState.RUNNING ) {
					defStart.resolve( this );
				}
				else {
					defStart.reject( new Error( WireErrorMessages.GRITWIRE_NOTSTARTED ) );
				}
			}
		}
		
		/**
		 * start Grit. Must be called before using to initialize threads
		 * @return <code>promise</code> resolved with this wire context - <code>IContext</code>
		 * or rejected if some error has been occured
		 * @see vm.miix.grit.wire.IContext
		 */
		public function start( gritBytes : ByteArray ) : IPromise {
			if ( defStart == null ) {
				defStart = new Deferred();
		
				// create main grit
				gritWorker = WorkerDomain.current.createWorker( gritBytes );
			
				// setup message channels
				var gritIncomeChannel : MessageChannel = Worker.current.createMessageChannel( gritWorker );
				gritWorker.setSharedProperty( ContextBase.incomingChannel, gritIncomeChannel );
			
				var gritOutcomeChannel : MessageChannel = gritWorker.createMessageChannel( Worker.current );
				gritWorker.setSharedProperty( ContextBase.outcomingChannel, gritOutcomeChannel );
			
				// set this worker as sfw to grit
				gritWorker.setSharedProperty( ContextBase.swfWorker, Worker.current );
			
				// context behind this thread
				context = new ContextThread( gritOutcomeChannel, gritIncomeChannel );
			
				// start main grit thread
				gritWorker.addEventListener( Event.WORKER_STATE, onWorkerState );
				gritWorker.start();
			}
			
			return defStart.promise;
		}
		
		
		/**
		 * terminate context. This will abort the current executions
		 */
		public function terminate() : void {
			if ( context ) {
				var tmpContext : ContextThread = context;
				context = null;
				tmpContext.terminate();
			}
			if ( gritWorker ) {
				gritWorker.removeEventListener( Event.WORKER_STATE, onWorkerState );
				var tmpWorker : Worker = gritWorker;
				gritWorker = null;
				tmpWorker.terminate();
			}
		}
		
		
		/* INTERFACE vm.miix.grit.wire.IContext */
		
		/**
		 * @inheritDoc
		 */
		public function registerServer( descriptor : ServerDescriptor, onConnected : Function ) : IPromise {
			if ( context ) {
				return context.registerServer( descriptor, onConnected );
			}
			else {
				var def : Deferred = new Deferred();
				def.reject( new Error( WireErrorMessages.GRITWIRE_NOTSTARTED ) );
				return def.promise;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function connect( address : Address ) : IPromise {
			if ( context ) {
				return context.connect( address );
			}
			else {
				var def : Deferred = new Deferred();
				def.reject( new Error( WireErrorMessages.GRITWIRE_NOTSTARTED ) );
				return def.promise;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function deploy( qualifiedClassName : String, param : * = undefined ) : IPromise {
			if ( context ) {
				return context.deploy( qualifiedClassName, param );
			}
			else {
				var def : Deferred = new Deferred();
				def.reject( new Error( WireErrorMessages.GRITWIRE_NOTSTARTED ) );
				return def.promise;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function createSharedBytes( name : String ) : IPromise {
			if ( context ) {
				return context.createSharedBytes( name );
			}
			else {
				var def : Deferred = new Deferred();
				def.reject( new Error( WireErrorMessages.GRITWIRE_NOTSTARTED ) );
				return def.promise;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function checkInSharedBytes( name : String ) : IPromise {
			if ( context ) {
				return context.checkInSharedBytes( name );
			}
			else {
				var def : Deferred = new Deferred();
				def.reject( new Error( WireErrorMessages.GRITWIRE_NOTSTARTED ) );
				return def.promise;
			}
		}
		
	}

}