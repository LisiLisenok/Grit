package vm.miix.grit.promise
{
	
	/**
	 * operations with a promise
	 * @see vm.miix.grit.promise.IResolver
	 * @see vm.miix.grit.promise.IPromise
	 * @see vm.miix.grit.promise.Deferred
	 * @author Lis
	 */
	public interface IPromisable 
	{
		
		/**
		 * promise associated with this promisable
		 */
		function get promise() : IPromise;
		
		/**
		 * composition with another promise.
		 * Resolves or rejects current promisable with the same value / reason as passed promise is resolved or rejected
		 * @param	promise promise to be composed with
		 * @return promise associated with this promisable
		 */
		function compose( promise : IPromise ) : IPromise;
		
		/**
		 * creates new promise which is resolved with map of value which the current promise is resolved
		 * @param	mapping, takes resolved value and returns another one which resolves returned promise,
		 * can return another promise or emitter
		 * <listing version="3.0"> function mapping( value : ~~ ) : ~~; </listing>
		 * @return promise resolved with value resolved the current promise and mapped using mapping function
		 */
		function map( mapping : Function ) : IPromise;
		
		/**
		 * combine the current promisable with provided promise.
		 * Returns new promise that:
			<p><ul>
			<li>resolves when both the current promisable and the other promise are resolved
				with value provided by specified combine function</li>
			<li>rejects when either the current term or the other promise is rejected.
				Rejected reason is the same as corresponding promise is rejected</li>
			</ul></p>
		 * @param	promise promise to be combined with this
		 * @param	combine combining function, which takes values resolved by first and second promise and returns combined value
		 * <listing version="3.0"> function combine( first : ~~, second : ~~ ) : ~~; </listing>
		 * @return combined promise
		 */
		function and( promise : IPromise, combine : Function ) : IPromise;
	}
	
}