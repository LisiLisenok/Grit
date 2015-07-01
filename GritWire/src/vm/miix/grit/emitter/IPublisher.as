package vm.miix.grit.emitter 
{
	
	/**
	 * <code>emitter</code> publisher. Publishes values on associated emmiter
	 * @see vm.miix.grit.emitter.IEmitter
	 * @see vm.miix.grit.emitter.IPublisher
	 * @see vm.miix.grit.emitter.EmitterFactory
	 * @author Lis
	 */
	public interface IPublisher 
	{
		/**
		 * publishes value value
		 * @param	value publishing value, can be some value, promise or an emitter.
					<p><ul>
					<li>if promise publish the promise resolving</li>
					<li>if emitter all emitted values will be published</li>
					<li>if another value it is published as is</li>
					</ul></p>
			@see vm.miix.grit.emitter.IEmitter
			@see vm.miix.grit.emitter.IPromise
		 */
		function publish( value : * ) : void;
		
		/**
		 * completes publishing. No any values will be published after calling.
		 */
		function complete() : void;
		
		/**
		 * publishes an error
		 * @param	reason error reason or description
		 */
		function error( reason : * ) : void;
	}
	
}