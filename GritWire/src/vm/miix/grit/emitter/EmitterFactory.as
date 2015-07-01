package vm.miix.grit.emitter 
{
	import flash.events.IEventDispatcher;
	import vm.miix.grit.trigger.ITrigger;
	import vm.miix.grit.trigger.ITriggered;
	import vm.miix.grit.trigger.Triggered;
	import vm.miix.grit.trigger.TriggeredList;
	
	/**
	 * provides static methods to create emitters.
		 * <p><ul>
		 <li> from events</li>
		 <li> combination each from a list of emitter</li>
		 <li> messenger, whcih contains emitter and publisher</li>
		 <li> promised emitter, which is like to messenger, but emits only once </li>
		 </ul></p>
	 *
	 * @see vm.miix.grit.emitter.IEmitter
	 * @see vm.miix.grit.emitter.IPublisher
	 * @author Lis
	 */
	public class EmitterFactory 
	{
		
		/**
		 * creates emitter from events
		 * @param	dispatcher events dispatcher
		 * @param	... list of String event names
		 * @return emitter, which listens dispatcher and emits events values
		 */
		public static function fromEvents( dispatcher : IEventDispatcher, ... events ) : IEmitter {
			var emitter : Emitter = new Emitter( new Triggered( clear, resume, stop ) );
			resume();
			return emitter;
			
			function clear() : void {
				if ( dispatcher && emitter && events ) {
					
					var tmpDispatcher : IEventDispatcher = dispatcher;
					dispatcher = null;
					var tmpEmitter : Emitter = emitter;
					emitter = null;
					var tmpEvent : Array = events;
					events = null;
					
					for each ( var event : String in tmpEvent ) {
						tmpDispatcher.removeEventListener( event, tmpEmitter.emit );
					}
				}
			}
			
			function stop() : void {
				if ( dispatcher && emitter && events ) {
					for each ( var event : String in events ) {
						dispatcher.removeEventListener( event, emitter.emit );
					}
				}
			}
			function resume() : void {
				if ( dispatcher && emitter && events ) {
					for each ( var event : String in events ) {
						dispatcher.addEventListener( event, emitter.emit );
					}
				}
			}
			
		}
		
		
		/**
		 * combines emitters from the list. Resulting emitter emits all emissions of combined emitters
		 * @param	... list of emitters to be combined into a one
		 * @return resulting emitter, which emits all values from listed emitters
		 */
		public static function combine( ... emitters ) : IEmitter {
			var trig : TriggeredList = new TriggeredList();
			var e : Emitter = new Emitter( trig );
			for each ( var emitter : IEmitter in emitters ) {
				var subs : ITriggered = emitter.subscribe (
					e.emit,
					function () : void {
						e.complete();
						if ( subs ) {
							var tmpSub : ITriggered = subs;
							subs = null;
							trig.removeTrigger( tmpSub );
							tmpSub = null;
						}
					},
					e.error
				);
				trig.addTrigger( subs );
			}
			return e;
		}
		
		/**
		 * creates new messenger (publisher + emitter)
		 * @return messenger
		 */
		public static function messenger() : Messenger {
			var publisher : Publisher = new Publisher();
			return new Messenger( publisher, publisher.emitter );
		}
		
		
		/**
		 * creates two cross-messenger - if publish in one of them, another messenger emits
		 * @return vector of two messengers
		 */
		public static function crossMessengers() : Vector.<Messenger> {
			var first : Publisher = new Publisher();
			var second : Publisher = new Publisher();
			var v : Vector.<Messenger> = new Vector.<Messenger>( 2, true );
			v[0] = new Messenger( first, second.emitter );
			v[1] = new Messenger( second, first.emitter );
			return v;
		}
		
		
		/**
		 * promised emitter - emits only once.
		 * If subscribed after emision (resolving) responds immediately
		 * @return promise messenger
		 * @see vm.miix.grit.promise.IPromise
		 */
		public static function promise() : Messenger {
			var publisher : Publisher = new Publisher( new PromisedEmitter() );
			return new Messenger( publisher, publisher.emitter );
		}
		
		
		/**
		 * emits value returned by <code>next</code> when <code>trigger</code> alarms
		 * @param	trigger alarms when value to be emitted or completes when emission to be completed
		 * @param	hasNext returns <code>true</code> if next value is available, otherwise emission is completed
		 * <listing version="3.0"> function hasNext() : Boolean; </listing>
		 * @param	next returns next value to be emitted, may be <code>promise</code>
		 * <listing version="3.0"> function next( value : ~~ ) : *; </listing>
		 * @return new emitter, which emits value when <code>trigger</code> alarms
		 * @see vm.miix.grit.collection.IIterator
		 */
		public static function fromTrigger( trigger : ITrigger, hasNext : Function, next : Function ) : IEmitter {
			var emitter : Emitter = new Emitter();
			trigger.subscribe (
				function () : void {
					if ( emitter ) {
						if ( hasNext() ) {
							emitter.emit( next() );
						}
						else {
							var tmpEmitter : Emitter = emitter;
							emitter = null;
							tmpEmitter.complete();
						}
					}
				},
				function () : void {
					if ( emitter ) {
						var tmpEmitter : Emitter = emitter;
						emitter = null;
						next = null;
						hasNext = null;
						tmpEmitter.complete();
					}
				}
			);
			return emitter;
		}
		
		
		
		/**
		 * factory has only static methods - no instance is required
		 */
		public function EmitterFactory() {
			
		}
		
	}

}