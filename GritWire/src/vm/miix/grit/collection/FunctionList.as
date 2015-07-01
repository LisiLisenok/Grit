package vm.miix.grit.collection 
{
	import vm.miix.grit.trigger.ITriggered;
	
	/**
	 * list of functions
	 * @author Lis
	 */
	public class FunctionList extends List
	{
		// arguments to invoke with
		private var argStack : Vector.<*> = new Vector.<*>();
		
		// true if invoke with arguments and false otherwise
		private var withArgStack : Vector.<Boolean> = new Vector.<Boolean>();
		
		public function FunctionList() {
			super();
		}
		
		override internal function putBefore( item : Object, before : ListItem ) : ITriggered {
			if ( item is Function ) return super.putBefore( item, before );
			else return null;
		}
		
		private function processInvokeStackItem() : void {
			if ( argStack.length > 0 ) {
				var arg : * = argStack.pop();
				var argType : Boolean = withArgStack.pop();
				if ( argType ) {
					var iter : IIterator = iterator;
					while ( iter.hasNext() ) {
						var fn : Function = iter.next() as Function;
						if ( fn != null ) {
							try { fn( arg ); }
							catch ( err : Error ) {
								trace( "functions are invoking with argument: ", arg, ", error: ", err );
							}
						}
					}
				}
				else {
					iter = iterator;
					while ( iter.hasNext() ) {
						fn = iter.next() as Function;
						if ( fn != null ) {
							try { fn(); }
							catch ( err : Error ) {
								trace( "functions are invoking without arguments: ", err );
							}
						}
					}
				}
			}
		}
		
		private function processInvokeStack() : void {
			if ( !isLocked ) {
				lock();
				var n : int = argStack.length;
				while ( n -- ) processInvokeStackItem();
				unlock();
			}
		}
		
		/**
		 * invoke all functions in the list without arguments
		 */
		public function invoke() : void {
			argStack.push( null );
			withArgStack.push( false );
			processInvokeStack();
		}
		
		/**
		 * invoke all functions in the list with an argument
		 * @param	arg function argument
		 */
		public function invokeWith( arg : * ) : void {
			argStack.push( arg );
			withArgStack.push( true );
			processInvokeStack();
		}
		
		override public function unlock() : void {
			super.unlock();
			if ( argStack.length > 0 ) processInvokeStack();
		}
		
	}

}