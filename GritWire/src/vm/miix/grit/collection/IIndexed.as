package vm.miix.grit.collection 
{
	
	/**
	 * indexed collection
	 * @author Lis
	 */
	public interface IIndexed extends IIterable
	{
		
		/**
		 * get item at position <code>index</code>
		 * @param	index position to look for item must be greater or equal to 0 and less than <code>size</code>
		 * @return item at index position or null if no item at the position
		 */
		function getAt( index : int ) : Object;
		
		/**
		 * find first occurancy of the item
		 * @param	item item which index is looking for
		 * @return index of first occurancy or -1 if not found
		 */
		function findFirstOccurrence( item : Object ) : int;
		
	}
	
}