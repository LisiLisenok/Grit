package vm.miix.grit.collection 
{
	/**
	 * immutable map containing key-&#62;function pairs.
	 * Can be used as command responder
	 * @author Lis
	 * @see vm.miix.grit.collection.FunctionMapSet
	 */
	public class FunctionMap extends Map 
	{
		
		public function FunctionMap( compare : Function, keys : IIterable, items : IIterable ) {
			super( compare, keys, items );
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
					trace( "FunctionMap: ", err );
				}
			}
		}
		
	}

}