package vm.miix.grit.collection 
{
	/**
	 * item of a list
	 * @author Lis
	 */
	internal class ListItem 
	{
		
		internal static const STATE_ACTIVE : uint = 		0x0;
		internal static const STATE_INACTIVE : uint = 		0x01;
		internal static const STATE_REMOVING : uint = 		0x02;
		internal static const STATE_CANCELED : uint = 		0x04;
		
		
		/**
		 * item value
		 */
		internal var item : Object;
		
		/**
		 * next item or null if it is last item
		 */
		internal var next : ListItem = null;
		
		/**
		 * previous item or null ig it is first item
		 */
		internal var prev : ListItem = null;
		
		/**
		 * false if item is canceled and has to be removed from the collection
		 */
		//internal var inLife : Boolean = true;
		
		/**
		 * true if item is active
		 */
		//internal var active : Boolean = true;
		
		private var _state : uint;
		
		
		/**
		 * creates new list item
		 * @param	item item data
		 * @param	next next item
		 * @param	prev previous item
		 */
		public function ListItem( item : Object, next : ListItem, prev : ListItem ) {	
			this.next = next;
			this.prev = prev;
			this.item = item;
			state = STATE_ACTIVE;
		}
		
		
		/**
		 * current state of list item.
		 * Can be set if item has not been canceled
		 */
		internal function get state() : uint { return _state; }
		internal function set state( s : uint ) : void {
			if ( state != STATE_CANCELED ) {
				if ( state != STATE_REMOVING ) _state = s;
				else if ( s == STATE_CANCELED ) _state = STATE_CANCELED;
			}
		}
		
		/**
		 * ture if item is active na not canceled
		 */
		internal function get isActive() : Boolean { return state == STATE_ACTIVE; }
		
		/**
		 * true if item has been already removed
		 */
		internal function get isCanceled() : Boolean { return state == STATE_CANCELED; }
		
		/**
		 * true if item has to be removed
		 */
		internal function get isRemoving() : Boolean { return state == STATE_REMOVING; }
		
	}

}