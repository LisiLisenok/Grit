package vm.miix.grit.collection 
{
	
	/**
	 * iterable collection
	 * following methods may not produce new collection but just refers to the current collection (lazy operation):
	   <ul>
	   <li><code>reversed</code></li>
	   <li><code>sequence</code></li>
	   <li><code>filter</code></li>
	   <li><code>chain</code></li>
	   <li><code>map</code></li>
	   <li><code>range</code></li>
	   <li><code>skip</code></li>
	   <li><code>take</code></li>
	   </ul>
	   <p>
	   Use <code>clone</code> to produce new collection with the same items as current has.
	   Sorting with <code>sort</code> function always produce new collection (eager operation).
	   </p>
	 * @see vm.miix.grit.collection.Collection
	 * @see vm.miix.grit.collection.IIterator
	 * @author Lis
	 */
	public interface IIterable 
	{
		/**
		 * <code>true</code> if collection is empty and <code>false</code> otherwise
		 */
		function get empty() : Boolean;
		
		/**
		 * iterating collection using iterator
		 */
		function get iterator() : IIterator;
		
		/**
		 * infinite cycling iterating.
		 * Iteration is reversed when reaching collection end (or start).
		 * <code>nextCycle</code> is called each time when next cycle is started.
		 * If <code>nextCycle</code> returns <code>false</code> iterations will be completed from this point in both directions.
		 * If <code>nextCycle</code> == <code>null</code> iterations are infinite
		 * @param	nextCycle
		 * <listing version="3.0"> function nextCycle() : Boolean; </listing>
		 * @return iterator for cycled iteration of the collection
		 */
		function cycled( nextCycle : Function = null ) : IIterator;
		
		/**
		 * infinite repeated iterating.
		 * Iteration begins from start when reaching end (or begins from end when reaching start for reverse iterations).
		 * <code>nextCycle</code> is called each time when next cycle is started.
		 * If <code>nextCycle</code> returns <code>false</code> iterations will be completed from this point in both directions.
		 * If <code>nextCycle</code> == <code>null</code> iterations are infinite
		 * @param	nextCycle
		 * <listing version="3.0"> function nextCycle() : Boolean; </listing>
		 * @return iterator for cycled iteration of the collection
		 */
		function repeated( nextCycle : Function = null ) : IIterator;
		
		/**
		 * collection contained the same elements but in reverse order
		 * <p><i>lazy</i></p>
		 */
		function get reversed() : IIterable;
		
		/**
		 * sequence, which can be iterated by index
		 * <p><i>eager or lazy</i></p> depending on collection nature
		 */
		function get sequence() : IIndexed;
		
		/**
		 * total number of elements in the collection, may requires collection iteration
		 */
		function get size() : int;
		
		/**
		 * counting of items returned by predicate function <code>selecting</code>
		 * @param	selecting predicate function
		 * <listing version="3.0"> function selecting( item : Object ) : Boolean; </listing>
		 * @return number of elements meet predicate function
		 */
		function count( selecting : Function ) : int;
		
		/**
		 * find first item meets <code>predicate</code> function
		 * @param	predicate function to check if object meets required.
		 * Must return true if object meets and false otherwise
		 * <listing>function predicate( item : Object ) : Boolean</listing>
		 * @return first object which meets <code>predicate</code> function or null if object hasn't been found
		 */
		function findFirstItem( predicate : Function ) : Object;
		
		/**
		 * find last item meets <code>predicate</code> function
		 * @param	predicate function to check if object meets required.
		 * Must return true if object meets and false otherwise
		 * <listing>function predicate( item : Object ) : Boolean</listing>
		 * @return last object which meets <code>predicate</code> function or null if object hasn't been found
		 */
		function findLastItem( predicate : Function ) : Object;
		
		/**
		 * produces a collection which contains items of this collection, in the order in which they occur in this collection,
		 * followed by the items of the other collection in the order in which they occur in the other collection.
		 * <p><i>lazy</i></p>
		 * @param	other collection to be chained with this
		 * @return collection which contains items of both this and other collections
		 */
		function chain( other : IIterable ) : IIterable;
		
		/**
		 * produces new collection with elements meet predicate function <code>filtering</code>
		 * <p><i>lazy</i></p>
		 * @param	filtering predicate function, have to return <code>true</code>
		 * if item is to be added to returned collection and <code>false</code> otherwise
		 * <listing version="3.0"> function filtering( item : Object ) : Boolean; </listing>
		 * @return collection with elements meet predicate function
		 */
		function filter( filtering : Function ) : IIterable;
		
		/**
		 * produces new collection with elements mapped by <code>mapping</code> function
		 * <p><i>lazy</i></p>
		 * @param	mapping function have to return mapped or converted element to be contained in returned collection
		 * <listing version="3.0"> function mapping( item : Object ) : Boolean; </listing>
		 * @return collection with mapped elements
		 */
		function map( mapping : Function ) : IIterable;
		
		/**
		 * produces a collection containing only items within specified range including ends
		 * <p><i>lazy</i></p>
		 * @param	from range start
		 * @param	to range end, if end is less than 0 items up to the end will be iterated
		 * @return collection with items ithin specified range
		 */
		function range( from : int, to : int ) : IIterable;
		
		/**
		 * produces a collection containing the items of this collection,
		 * after skipping the first <code>skipped</code> items produced by its iterator.
		 * If this collection does not contain more items than the specified number of items to skip,
		 * the resulting collection has no items.
		 * If the specified number of items to skip is zero or fewer,
		 * the resulting collection contains the same items as this collection.
		 * <p><i>lazy</i></p>
		 * @param	skipped number of items to be skipped
		 * @return collection with skipped first <code>skipped</code> items
		 */
		function skip( skipped : int ) : IIterable;
		
		/**
		 * produces a collection containing the first <code>taken</code> items of this collection.
		 * If the specified number of items to take is larger than the number of items of this collection,
		 * the resulting collection contains the same items as this collection.
		 * If the specified number of items to take is fewer than one, the resulting collection has no items.
		 * <p><i>lazy</i></p>
		 * @param	taken number of items to be taken
		 * @return collection containing first <code>taken</code> items
		 */
		function take( taken : int ) : IIterable;
		
		/**
		 * produce new collection containing items of this collection sorted according to <code>comparator function</code>
		 * <p><i>eager</i></p> by nature
		 * @param	compare the function comparing a pair of items:
			 <ul>
				<li>if returns negaive value then first item is forward to second</li>
				<li>if returns positive value then first item is backward to second</li>
				<li>if returns zero value then first item is equal to second</li>
			 </ul>
		 * <listing version="3.0"> function compare( first : Object, second : Object ) : Number; </listing>
		 * @return new collection with the same items as current but in sorted order
		 * @see vm.miix.grit.collection.Comparison
		 */
		function sort( compare : Function ) : IIndexed;
		
		/**
		 * zip this iterable with another.
		 * function <code>paired</code> is called for each pair produced by this and <code>other</code> iterators simultaneously.
		 * If no item is produced by any of iterables, corresponding item in <code>paired</code> argument is set to null
		 * @param	other iterable to be zipped with this
		 * @param	paired callback for each pair, first argument is item from this collection (or null if no) and
		 * second is from <code>other</code> collection
		 * <listing version="3.0"> function paired( first : Object, second : Object ) : void; </listing>
		 */
		function zip( other : IIterable, paired : Function ) : void;
		
		/**
		 * clone the current collection
		 * <p><i>lazy or eager</i></p> depending if collection contains items directly or as filtered, mapped etc
		 * @return new collection with the same items and in the same order as current has
		 */
		function clone() : IIterable;
		
		/**
		 * produces new collection with items cloned using <code>cloneItem</code> function.
		 * Since items are potentially mutable, this operation can provide some save mutable operations
		 * <p><i>eager</i></p>
		 * @param	cloneItem item cloning - takes an item and returns its copy (or may be another mapped item)
		 * <listing version="3.0"> function cloneItem( item : Object ) : Object; </listing>
		 * @return new collection with items cloned using <code>cloneItem</code> function
		 */
		function cloneWith( cloneItem : Function ) : IIterable;
		
		/**
		 * calls specified funcion for each item in the collection
		 * @param	perform function called for each item in the collection
		 * <listing version="3.0"> function perform( item : Object ) : void; </listing>
		 */
		function forEach( perform : Function ) : void;
		
	}
	
}