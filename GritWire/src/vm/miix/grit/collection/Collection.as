package vm.miix.grit.collection 
{
	
	/**
	 * immutable collection of potentialy mutable items.
	 * <p>Items can be added only in constructor.
	 * Items from passed array is copied into underlaying buffer.
	 * So, if source array is modified it doesn't lead to modification of this <code>collection</code></p>
	 * <p>Collection may be sorted using <code>comparing</code> function. In this case the searching of item index
	 * <code>findFirstOccurancies</code> is fast. If collection is clonned using <code>cloneWith</code> method,
	 * the clonned array is considered as unsorted, since items may be not only clonned but also mapped to another value</p>
	 * @author Lis
	 */
	public class Collection extends IterableBase implements IIndexed
	{
		
		private var _vector : Vector.<Object>;
		
		private var _comparator : Function = null;
		
		
		/**
		 * produces new collection filled with sequence of <code>next</code> calling
		 * @param	next function which takes previous added item and returns next one, if returns null collection filling is completed
		 * <listing version="3.0"> function next( previous : Object ) : Object; </listing>
		 * @param	first first item in the collection, if null collection is empty
		 * @return collection filled using <code>next</code> function
		 */
		public static function fillCollection( next : Function, first : Object ) : IIndexed {
			if ( first == null ) return emptyIterable;
			var obj : Object = first;
			var v : Vector.<Object> = new Vector.<Object>();
			while ( obj != null ) {
				v.push( obj );
				obj = next( obj );
			}
			return collectionFromVector( v );
		}
		
		/**
		 * constructor
		 * @param	sourceArray is Array or Vector.&lt;T&gt; with items to be filled this array with
		 */
		public function Collection( sourceArray : Object ) {
			if ( sourceArray != null ) {
				try {
					_vector = Vector.<Object>( sourceArray );
					if ( _vector == sourceArray ) {
						// same array - copy items
						_vector = new Vector.<Object>();
						for each ( var item : Object in sourceArray ) {
							_vector.push( item );
						}
					}
				}
				catch ( err : TypeError ) {
					_vector = new Vector.<Object>();
				}
			}
			else {
				_vector = new Vector.<Object>();
			}
		}
		
		/**
		 * only for internal usage  don't copy array, but use them as is
		 * sourceArray passed at constructor is 
		 */
		internal function fromFinalVector( vector : Vector.<Object>, comparator : Function = null ) : void {
			_vector = vector;
			_comparator = comparator;
		}
		
		
		/* INTERFACE vm.miix.grit.collection.IIndexed */
		
		/**
		 * @inheritDoc
		 */
		public function findFirstOccurrence( item : Object ) : int {
			if ( _comparator == null ) {
				for ( var i : int = 0; i < _vector.length; i ++ ) {
					if ( _vector[i] == item ) return i;
				}
			}
			else {
				var nFirst : int = 0;
				var nLast : int = _vector.length - 1;
				var nMid : int;
				while ( nFirst < nLast ) {
					nMid = ( nFirst + nLast ) / 2;
					var comp : int = _comparator( _vector[nMid], item );
					if ( comp < 0 ) nFirst = nMid + 1;
					else if ( comp > 0 ) nLast = nMid;
					else return nMid;
				}
				if ( nFirst < _vector.length && _comparator( _vector[nFirst], item ) == 0 ) return nFirst;
			}
			return -1;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getAt( index : int ) : Object {
			if ( index > -1 && index < size ) return _vector[index];
			return null;
		}
		
		
		/* INTERFACE vm.miix.grit.collection.IIterable */
		
		/**
		 * @inheritDoc
		 * <p><i>lazy</i></p>
		 */
		override public function get sequence() : IIndexed { return this; }
		
		/**
		 * @inheritDoc
		 */
		override public function get empty() : Boolean { return _vector.length == 0; }
		
		/**
		 * @inheritDoc
		 */
		override public function get size() : int { return _vector.length; }
		
		/**
		 * @inheritDoc
		 */
		override public function get iterator() : IIterator { return new Iterator( this ); }
		
		/**
		 * return this, since collection is immutable and no filters, mappings etc can be applied directly to the Collection
		 * @inheritDoc
		 */
		override public function clone() : IIterable {
			if ( empty ) return emptyIterable;
			return this;
		}
		
	}

}