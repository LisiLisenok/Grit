package vm.miix.grit.promise 
{
	
	/**
	 * promise represents a value that may not be available yet.
		* exists in one of three states:
		<ul>
			<li>in the promised state, the operation has not yet terminated</li>
			<li>in the fulfilled or resolved state, the operation has produced a value</li>
			<li>in the rejected state, the operation has terminated without producing a value</li>
		</ul>
		* 
		* @author Lis
	 */
	public interface IPromise extends IPromisable
	{
		/**
		 * subscribe on the promise.
		 * If promise has been resolved before subscription,
		 * appropriate callback function is called immediatly after subscription
		 * otherwise it will be called after resolving or rejecting
		 * @param	onFulfilled is a callback when promise is resolved, takes value returned by promise.
		 * <p>If callback returns value or promise, returned promise is resolved with this, if returned nothing, promise is resolved with null</p>
		 * <listing version="3.0"> function onFulfilled( value : ~~ ) : ~~; </listing>
		 * @param	onRejected is a callback when promise is rejected, takes rejected reason 
		 * <listing version="3.0"> function onRejected( value : ~~ ) : void; </listing>
		 * @return	promise chained with current, the promise is resolved with value returned by onFulfilled
		 * (can be another promise or emitter) or rejectedwith the same reason as current
		 * @see vm.miix.grit.promise.IResolver
		 * @see vm.miix.grit.promise.Deferred
		 * @see vm.miix.grit.emitter.IEmitter
		 */
		function onCompleted( onFulfilled : Function, onRejected : Function = null ) : IPromise;
	}
	
}