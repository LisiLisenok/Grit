package vm.miix.grit.collection 
{
	import vm.miix.grit.trigger.ITriggered;
	
	/**
	 * set is a mutable collection.
	 * When item added / removed active iterators may return not expected results.
	 * All <code>Iterable</code> operations are not lazy and produce new immutable collection.
	 <p>
	 
	 </p>
	 * @author Lis
	 * @see vm.miix.grit.collection.IMutator
	 */
	public interface ISet extends IIterable
	{
		/**
		 * set mutator - add / remove items
		 */
		function get mutator() : IMutator;
		
		/**
		 * add item at first position
		 * @param	item item to be added
		 * @return <code>triggered</code> to activate / deactivate and remove this item from the collection
		 * inactive items don't extracted by iterators
		 */
		function add( item : Object ) : ITriggered;
		
		/**
		 * add item at last position
		 * @param	item item to be added
		 * @return <code>triggered</code> to activate / deactivate and remove this item from the collection
		 * inactive items don't extracted by iterators
		 */
		function push( item : Object ) : ITriggered;
		
		/**
		 * remove first item from the collection and return it
		 * @return first collection item (already removed) or null if doesn't exists
		 */
		function accept() : Object;
		
		/**
		 * remove last item from the collection and return it.
		 * @return last collection item (already removed) or null if doesn't exists
		 */
		function pop() : Object;
		
		/**
		 * remove all items from the list
		 */
		function clear() : void;
		
		/**
		 * lock the collection.
		 * Items removed / added to the collection are not actually removed / added, but not returned by iterators.
		 * To remove / add items call unlock. Lock / unlcok operations performed in pairs. Actual adding / removing
		 * are performed when unlock is called the same time as lock was called before.
		 * @see #unlock
		 */
		function lock() : void;
		
		/**
		 * unlock the collection.
		 * set collection unlocked and actualy add / removed items added / removed during locking
		 * @see #lock
		 */
		function unlock() : void;
		
	}
	
}