package vm.miix.grit.emitter 
{
	import vm.miix.grit.trigger.ITriggered;
	
	/**
	 * <code>emitter</code> basis.
		 <p><ul>
		 <li>subscribe to be notified on emissions, error or emission completion</li>
		 <li>create another emitter with mapping or filtering this emitter</li>
		 </ul></p>
	 * 
	 * @see vm.miix.grit.emitter.EmitterFactory
	 * @author Lis
	 */
	public interface IEmitter extends ITriggered
	{
		/**
		 * subscribe on the emitter.
		 * Subscribed function may not throws errors.
		 * All throwed errors are to be catched internaly and not treated (just traced).
		 * @param	onEmit called when value is emitted
		 * <listing version="3.0"> function onEmit( value : ~~ ) : void; </listing>
		 * @param	onComplete called when emission is completed
		 * <listing version="3.0"> function onComplete() : void; </listing>
		 * @param	onError called when some error is occured
		 * <listing version="3.0"> function onError( reason : ~~ ) : void; </listing>
		 * @return triggering of subscription within with emitter
		 */
		function subscribe( onEmit: Function, onComplete : Function = null, onError : Function = null ) : ITriggered;
		
		/**
		 * Map this emitter to another one.
		 * When this emitter emits a value, returned emitter emits mapped value.
		 * When this emitter emits an error, returned emitter emits error with the same reason.
		 * Returned emitter completes when this emitter completes
		 * 
		 * @param	mapping mapping function
		 * <listing version="3.0"> function mapping( value : ~~ ) : ~~ </listing>
		 * mapping fuction can return value or another emitter
		 * @return new emitter, which maps this
		 */
		function map( mapping : Function ) : IEmitter;
		
		/**
		 * filters emission values
		 * @param	filtering function to filter emittions.
		 * <listing version="3.0"> function filtering( value : ~~ ) : Boolean </listing>
		 * If filtering returns <code>true</code> the value is to be emitted and not emitted otherwise
		 * @return new emitter, which filters emission of this emitter
		 */
		function filter( filtering : Function ) : IEmitter;
				
	}
	
}