package vm.miix.grit.collection 
{
	
	/**
	 * extract items from a collection in series
	 * @author Lis
	 */
	public interface IIterator 
	{
		/**
		 * @return true if has next item to iterate
		 */
		function hasNext() : Boolean;
		
		/**
		 * @return next iterated item or null if doesn't exists
		 */
		function next() : Object;
		
		/**
		 * @return true if has previous item to iterate
		 */
		function hasPrevious() : Boolean;
		
		/**
		 * @return previous iterated item or null if doesn't exists
		 */
		function previous() : Object;
		
		/**
		 * @return current item without shifting pointer
		 */
		function item() : Object;
		
		/**
		 * flip iterator to start
		 */
		function flipStart() : void;
		
		/**
		 * flip iterator to end
		 */
		function flipEnd() : void;
		
		/**
		 * clone this iterator
		 * @return cloned clean iterator flipped to collection start
		 */
		function clone(): IIterator;
	}
	
}