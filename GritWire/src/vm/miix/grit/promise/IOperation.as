package vm.miix.grit.promise 
{
	import vm.miix.grit.promise.IPromise;
	
	/**
	 * operation interface - some long-time operation.
	 * contains:
	 * <p><ul>
	 * <li>cancel operation</li>
	 * <li>promise resolved with operation result when completed or rejected with some error</li>
	 * </ul></p>
	 * @author Lis
	 */
	public interface IOperation extends IPromise
	{
		/**
		 * cancel operation
		 */
		function cancel() : void;
		
		/**
		 * same as <code>IPromise.onCompleted()</code>but returns operation
		 * @param	onFulfilled fullfilling promise callback
		 * @param	onRejected rejecting promise callback
		 * @return operation fullfilled with onFullfilled return
		 * @see #onCompleted
		 */
		function onOperationCompleted( onFulfilled : Function, onRejected : Function = null ) : IOperation;
	}
}