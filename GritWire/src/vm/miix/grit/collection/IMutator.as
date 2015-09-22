package vm.miix.grit.collection 
{
	import vm.miix.grit.trigger.ITriggered;
	
	/**
	 * mutate a collection
	 * @author Lis
	 */
	public interface IMutator extends IIterator
	{
		/**
		 * add item to the collection at current position.
		 * @param	item item to be added
		 * @return <code>triggered</code> to activate / deactivate and remove this item from the collection
		 * deactivated item doesn't extracted by iterators
		 */
		function insert( item : Object ) : ITriggered;
		
		/**
		 * remove current item from collection, and returns this item
		 * @return removed item
		 */
		function remove() : Object;
		
	}
	
}