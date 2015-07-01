package vm.miix.grit.collection 
{
	/**
	 * item of a list
	 * @author Lis
	 */
	internal class ListItem 
	{
		
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
		 * false if item is canceled and will be removed from the collection
		 */
		internal var inLife : Boolean = true;
		
		/**
		 * true if item is active
		 */
		internal var active : Boolean = true;
		
		public function ListItem( item : Object, next : ListItem, prev : ListItem ) {	
			this.next = next;
			this.prev = prev;
			this.item = item;
		}
		
		/**
		 * ture if item is active na not canceled
		 */
		internal function get isActive() : Boolean { return active && inLife; }
		
	}

}