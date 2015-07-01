package vm.miix.grit.collection 
{
	
	/**
	 * Map represents a collection of Key-&#62;Item pairs, where each Key maps to a one and only one Item.
	 * All methods of <code>iterable</code> returns <code>iterable</code> of <code>pairs</code>,
	 * which may be not excatly <code>map</code>
	 * @author Lis
	 * @see vm.miix.grit.collection.Pair
	 */
	public interface IMap extends IIterable
	{
		/**
		 * keys within the map
		 * <p><i>lazy</i></p>
		 * @return collection contains keys
		 */
		function get keys() : IIterable;
		
		/**
		 * items within the map
		 * <p><i>lazy</i></p>
		 * @return collection contains items
		 */
		function get items() : IIterable;

		/**
		 * check if map contains pair with key key
		 * @param	key key to be check
		 * @return true if map contains pair with key key and false otherwise
		 */
		function contains( key : Object ) : Boolean;
		
		/**
		 * get item by key
		 * @param	key item key 
		 * @return item corresponds to key key or null if doesn't exists
		 */
		function byKey( key : Object ) : Object;
		
		/**
		 * perform for each key-&#62;item pair in the map.
		 * <code>forEach</code> method is performed for each <code>Pair</code> as argument
		 * while <code>forEachKeyItem</code> is performed for key and item as arguments
		 * @param	perform function called for each key-&#62;item pair in the collection
		 * <listing version="3.0"> function perform( key : Object, item : Object ) : void; </listing>
		 * @see #forEach
		 * @see #forEachItem
		 */
		function forEachKeyItem( perform : Function ) : void;
		
		/**
		 * perform for item from each key-&#62;item pair in the map.
		 * <code>forEach</code> method is performed for each <code>Pair</code> as argument
		 * while <code>forEachItem</code> is performed for item as arguments
		 * @param	perform function called for item each from key-&#62;item pair in the collection
		 * <listing version="3.0"> function perform( item : Object ) : void; </listing>
		 * @see #forEach
		 * @see #forEachKeyItem
		 */
		function forEachItem( perform : Function ) : void;
		
	}
	
}