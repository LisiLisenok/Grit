package vm.miix.grit.collection 
{
	/**
	 * pair of Key-&#62;Item
	 * @author Lis
	 */
	public final class Pair 
	{
		
		internal var _key : Object;
		internal var _item : Object;
		
		public function Pair( key : Object, item : Object ) {
			_key = key;
			_item = item;
		}
		
		/**
		 * pair key
		 */
		public function get key() : Object { return _key; }
		
		/**
		 * pair item
		 */
		public function get item() : Object { return _item; }
		
		public function toString() : String {
			return String( key ) + "->" + String( item );
		}
		
	}

}