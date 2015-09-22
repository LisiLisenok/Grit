package vm.miix.grit.collection 
{
	/**
	 * immutable map as a collection of key-&#62;item pairs.
	 * <p>Iternally map stored keys in sorted order, which allows fast key searching.
	 * At the same time <code>pairs</code>, <code>keys</code> and <code>items</code>
	 * are iterated in the same order as received in constructor</p>
	 * <p>All methods of <code>Iterable</code> produce collection of pairs but not exactly a map</p>
	 * @see vm.miix.grit.collection.Pair
	 * @author Lis
	 */
	public class Map extends Collection implements IMap 
	{
		
		private var _indexies : Collection = new Collection( null );
		
		/**
		 * creating map with <code>keys</code> and <code>items</code> pairs.
		 * If the streams <code>keys</code> and <code>items</code> have different size, the largest one is truncated
		 * @param	compare the function comparing a pair of keys:
			 <ul>
				<li>if returns negaive value then first key is forward to second</li>
				<li>if returns positive value then first key is backward to second</li>
				<li>if returns zero value then first key is equal to second</li>
			 </ul>
		 * <listing version="3.0"> function compare( first : Object, second : Object ) : Number; </listing>
		 * @param	keys stream contains keys of the map
		 * @param	items stream contains items of the map such as key corresponds to item with the same index 
		 * @see vm.miix.grit.collection.Comparison
		 */
		public function Map( compare : Function, keys : IIterable, items : IIterable ) {
			super( null );
			var builder : MapBuilder = new MapBuilder( compare );
			keys.zip( items, function ( key : Object, item : Object ) : void {
					//if ( key != null && item != null ) {
					if ( key != null ) {
						builder.add( key, item );
					}
				}
			);	
			
			_indexies.fromFinalVector ( 
				builder.indexies,
				function ( first : Pair, second : Pair ) : Number {
					return compare( first.key, second.key );
				}
			);
			fromFinalVector( builder.pairs );
		}
		
		
		/**
		 * create map from iterable of pairs
		 * @param	pairs stream with pairs (each iterated item must be <code>pair</code>)
		 * @param	compare comparator function
		 * @return new map containing exactly the same pairs and in the same order as specified in <code>pairs</code> stream
		 * @see vm.miix.grit.collection.Pair
		 * @see #Map
		 */
		public static function fromPairs( compare : Function, pairs : IIterable ) : Map {
			var seq : IIndexed = pairs.sequence;
			return new Map	(
				compare,
				new Iterable( new IteratorPair( seq, true ) ),
				new Iterable( new IteratorPair( seq, false ) )
			);
		}
		
		/* INTERFACE vm.miix.grit.collection.IMap */
		
		/**
		 * @inheritDoc
		 */
		public function get keys() : IIterable {
			if ( empty ) return emptyIterable;
			else return new Iterable( new IteratorPair( this, true ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function get items() : IIterable {
			if ( empty ) return emptyIterable;
			else return new Iterable( new IteratorPair( this, false ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function contains( key : Object ) : Boolean {
			return _indexies.findFirstOccurrence( new Pair( key, null ) ) > -1;
		}
		
		/**
		 * @inheritDoc
		 */
		public function byKey( key : Object ) : Object {
			var nKeyIndex : int = _indexies.findFirstOccurrence( new Pair( key, null ) );
			if ( nKeyIndex > -1 ) {
				return getAt( _indexies.getAt( nKeyIndex ).item ).item;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function forEachKeyItem( perform : Function ) : void {
			forEach( function ( pair : Pair ) : void { perform( pair.key, pair.item ); } );
		}
		
		/**
		 * @inheritDoc
		 */
		public function forEachItem( perform : Function ) : void {
			forEach( function ( pair : Pair ) : void { perform( pair.item ); } );
		}
		
	}

}