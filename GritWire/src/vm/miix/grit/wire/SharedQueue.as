package vm.miix.grit.wire 
{
	import vm.miix.grit.collection.List;
	import vm.miix.grit.promise.Deferred;
	
	/**
	 * shared bytes check in / out queue of <code>Deferred</code> items
	 * @see vm.miix.grit.promise.Deferred
	 * @author Lis
	 */
	internal final class SharedQueue 
	{
		
		/**
		 * waiters of shared bytes check out
		 */
		private var waiters : List = new List();
		
		/**
		 * true if shared property check in currently
		 */
		private var bCheckIn : Boolean = false;
		
		public function SharedQueue() {
			
		}
		
		
		/**
		 * true if no waiters in the queue
		 */
		internal function get isEmpty() : Boolean { return waiters.empty; }
		
		/**
		 * reject all items in queue
		 * @param	reason rejecting reason
		 */
		internal function reject( reason : * ) : void {
			waiters.lock();
			waiters.forEach (
				function ( def : Deferred ) : void {
					def.reject( reason );
				}
			);
			waiters.unlock();
			waiters.clear();
		}
		
		/**
		 * add item to the queue
		 * @param	def added item
		 */
		internal function add( def : Deferred ) : void {
			waiters.push( def );
			if ( !bCheckIn ) checkOut();
		}
		
		/**
		 * check out current check in and go to the next
		 */
		internal function checkOut() : void {
			if ( waiters.empty ) {
				bCheckIn = false;
			}
			else {
				bCheckIn = true;
				var def : Deferred = waiters.accept() as Deferred;
				def.resolve( true );
			}
		}
		
		
	}

}