package vm.miix.grit.collection 
{
	/**
	 * base abstract iterable, implements all, except iterator
	 * size is calculated by iterator at first glance
	 * @author Lis
	 */
	internal class IterableBase implements IIterable 
	{
		
		// empty iterable - static
		internal static const emptyIterable : IIndexed = new IterableEmpty();
		
		/**
		 * new collection from vector
		 * @param	v
		 * @return
		 */
		internal static function collectionFromVector( v : Vector.<Object>, comparator : Function = null ) : Collection {
			var arr : Collection = new Collection( null );
			arr.fromFinalVector( v, comparator );
			return arr;
		}
		
		// number of items in iterable if -1 - must be calculated
		private var _size : int = -1;
		
		
		public function IterableBase() {
		}
		
		/**
		 * copy collection items into a vector
		 * @param	cloneItem function to clone item, if null items are not cloned
		 * <listing version="3.0"> function cloneItem( item : Object ) : Object; </listing>
		 * @return vector with items returned by <code>iterator</code>
		 */
		protected function toVector( cloneItem : Function = null ) : Vector.<Object> {
			var v : Vector.<Object> = new Vector.<Object>();
			var iter : IIterator = iterator;
			if ( cloneItem == null ) {
				while ( iter.hasNext() ) v.push( iter.next() );
			}
			else {
				while ( iter.hasNext() ) v.push( cloneItem( iter.next() ) );
			}
			return v;
		}
		
		
		/* INTERFACE vm.miix.grit.collection.IIterable */
		
		/**
		 * @inheritDoc
		 */
		public function get empty() : Boolean { return !iterator.hasNext(); }
		
		/**
		 * @inheritDoc
		 */
		public function get iterator() : IIterator { return null; }
		
		/**
		 * @inheritDoc
		 */
		public function get first() : Object {
			return iterator.next();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get last() : Object {
			var iter : IIterator = iterator;
			iter.flipEnd();
			return iter.previous();
		}

		/**
		 * @inheritDoc
		 */
		public function cycled( nextCycle : Function = null ) : IIterator {
			if ( empty ) return emptyIterable.iterator;
			return new IteratorCycled( iterator, nextCycle );
		}
		
		/**
		 * @inheritDoc
		 */
		public function repeated( nextCycle : Function = null ) : IIterator {
			if ( empty ) return emptyIterable.iterator;
			return new IteratorRepeated( iterator, nextCycle );
		}
		
		/**
		 * @inheritDoc
		 */
		public function get reversed() : IIterable {
			if ( empty ) return emptyIterable;
			return new Iterable( new IteratorReveresed( iterator ) );
		}
		
		/**
		 * returns copied immutable indexed collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		public function get sequence() : IIndexed {
			if ( empty ) return emptyIterable;
			return collectionFromVector( toVector() );
		}
		
		/**
		 * @inheritDoc
		 */
		public function get size() : int {
			if ( _size < 0 ) {
				var iter : IIterator = iterator;
				_size = 0;
				while ( iter.hasNext() ) {
					iter.next();
					_size ++;
				}
			}
			return _size;
		}
		
		/**
		 * @inheritDoc
		 */
		public function count( selecting : Function ) : int {
			return filter( selecting ).size;
		}
		
		/**
		 * @inheritDoc
		 */
		public function findFirstItem( predicate : Function ) : Object {
			var iter : IIterator = iterator;
			while ( iter.hasNext() ) {
				var obj : Object = iter.next();
				if ( predicate( obj ) ) return obj;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function findLastItem( predicate : Function ) : Object {
			var iter : IIterator = iterator;
			while ( iter.hasPrevious() ) {
				var obj : Object = iter.previous();
				if ( predicate( obj ) ) return obj;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function chain( other : IIterable ) : IIterable {
			if ( empty ) return other;
			else return new Iterable( new IteratorChained( iterator, other.iterator ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function filter( filtering : Function ) : IIterable {
			if ( empty ) return emptyIterable;
			else return new Iterable( new IteratorFiltered( iterator, filtering ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function map( mapping : Function ) : IIterable {
			if ( empty ) return emptyIterable;
			else return new Iterable( new IteratorMap( iterator, mapping ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function range( from : int, to : int ) : IIterable {
			var s : int = size;
			if ( from < 0 ) from = 0;
			if ( to < 0 || to >= size ) to = size - 1;
			if ( !empty && to >= from ) {
				return new Iterable( new IteratorRanged( iterator, from, to ) );
			}
			return emptyIterable;
		}
		
		/**
		 * @inheritDoc
		 */
		public function skip( skipped : int ) : IIterable {
			return range( skipped, -1 );
		}
		
		/**
		 * @inheritDoc
		 */
		public function take( taken : int ) : IIterable {
			if ( taken <= 0 ) return emptyIterable;
			return range( 0, taken - 1 );
		}
		
		/**
		 * @inheritDoc
		 */
		public function sort( compare : Function ) : IIndexed {
			if ( empty ) return emptyIterable;
			return collectionFromVector( toVector().sort( compare ), compare );
		}
		
		/**
		 * @inheritDoc
		 */
		public function zip( other : IIterable, paired : Function ) : void {
			var iterFirst : IIterator = iterator;
			var iterSecond : IIterator = other.iterator;
			while ( iterFirst.hasNext() || iterSecond.hasNext() ) {
				paired( iterFirst.next(), iterSecond.next() );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone() : IIterable {
			return sequence;
		}
		
		/**
		 * @inheritDoc
		 */
		public function cloneWith( cloneItem : Function ) : IIterable {
			if ( empty ) return emptyIterable;
			return collectionFromVector( toVector( cloneItem ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function forEach( perform : Function ) : void {
			var iter : IIterator = iterator;
			while ( iter.hasNext() ) {
				perform( iter.next() );
			}
		}
		
		/**
		 * String representation of the collection
		 * @return string with string representation of items returned by iterator separated by ','
		 */
		public function toString() : String {
			var str : String = "[";
			var iter : IIterator = iterator;
			while ( iter.hasNext() ) {
				str += String( iter.next() );
				if ( iter.hasNext() ) str += ", ";
			}
			str += "]";
			return str;
		}
		
	}

}