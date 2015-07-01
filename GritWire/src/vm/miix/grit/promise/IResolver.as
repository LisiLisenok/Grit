package vm.miix.grit.promise 
{
	
	/**
	 * resolver - resolves or rejects associated promise
	 * @see vm.miix.grit.promise.IPromise
	 * @see vm.miix.grit.emitter.IEmitter
	 * @author Lis
	 */
	public interface IResolver extends IPromisable
	{
		/**
		 * resolve this resolver with value value.
		 <p>The value can be:
		 <ul>
		 <li><code>value</code> - the promise is resolved with this value</li>
		 <li><code>promise</code> - this promise will be resolved with passed promise resolved value</li>
		 <li><code>emtter</code> - this promise will be resolved with first value resolved by emitter</li>
		 </ul></p>
		 * @see vm.miix.grit.promise.IPromise
		 * @see vm.miix.grit.emitter.IEmitter
		 * @param	value resolving value, promise or emitter
		 */
		function resolve( value : * ) : void;
		
		/**
		 * reject this resolver with reason reason
		 * @param	reason rejecting reason
		 */
		function reject( reason : * ) : void;
	}
	
}