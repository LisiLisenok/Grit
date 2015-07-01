package vm.miix.grit.collection 
{
	/**
	 * mutable map set containing key-&#62;function pairs.
	 * @author Lis
	 * @see vm.miix.grit.collection.FunctionMap
	 */
	public class FunctionMapSet extends MapSet 
	{
		
		public function FunctionMapSet( compare : Function ) {
			super( compare );
		}
		
		/**
		 * invoke function stored under key <code>key</code>
		 * @param	key pair key
		 * @param	argument function argument, if is <code>undefined</code> function is called without argument
		 */
		public function invoke( key : Object, argument : * = undefined ) : void {
			var fn : Function = byKey( key ) as Function;
			if ( fn != null ) {
				try {
					if ( argument == undefined ) fn();
					else fn( argument );
				}
				catch ( err : Error ) {
					trace( "FunctionMapSet: ", err );
				}
			}
		}
		
	}

}