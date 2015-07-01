package vm.miix.grit.collection 
{
	/**
	 * mutable map of key-&#62;item pairs.
	 * <p>Iternally map stored keys in sorted order, which allows fast key searching.
	 * At the same time <code>pairs</code>, <code>keys</code> and <code>items</code>
	 * are iterated in the same order as pairs have been added</p>
	 * <p>All methods of <code>Iterable</code> produce collection of pairs but not exactly a map</p>
	 * @see vm.miix.grit.collection.Map
	 * @author Lis
	 */
	public class MapSet extends IterableBase implements IMap, IIndexed
	{
		
		private var _map : MapBuilder;
		
		
		/**
		 * creating mutable map.
		 * @param	compare the function comparing a pair of keys:
			 <ul>
				<li>if returns negaive value then first key is forward to second</li>
				<li>if returns positive value then first key is backward to second</li>
				<li>if returns zero value then first key is equal to second</li>
			 </ul>
		 * <listing version="3.0"> function compare( first : Object, second : Object ) : Number; </listing>
		 * @see vm.miix.grit.collection.Comparison
		 */
		public function MapSet( compare : Function ) {
			super();
			_map = new MapBuilder( compare );
		}
		
		/**
		 * add new key-&#62;item pair.
		 * If pair has already existsed, pair item is replaced with new one
		 * @param	key added pair <code>key</code>
		 * @param	item added pair <code>item</code>
		 */
		public function add( key : Object, item : Object ) : void { _map.add( key, item ); }
		
		
		/**
		 * remove pair with key <code>key</code>
		 * @param	key key of removed pair
		 */
		public function remove( key : Object ) : Object { return _map.remove( key ); }
		
		
		/**
		 * remove all pairs
		 */
		public function clear() : void { _map.clear(); }
		
		
		/**
		 * creates immutable map with the same pairs as this map contains
		 */
		public function immutable() : IMap { return Map.fromPairs( _map.compare, this ); }
		
		
		/* INTERFACE vm.miix.grit.collection.IIndexed */
		
		/**
		 * @inheritDoc
		 */
		public function findFirstOccurrence( item : Object ) : int {
			var pair : Pair = item as Pair;
			if ( pair ) return _map.getPairIndex( pair.key );
			return -1;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getAt( index : int ) : Object {
			if ( index > -1 && index < size ) return _map.pairs[index];
			return null;
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
			return _map.getSortedIndex( key ) > -1;
		}
		
		/**
		 * @inheritDoc
		 */
		public function byKey( key : Object ) : Object {
			return _map.byKey( key );
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

		
		
		/* INTERFACE vm.miix.grit.collection.IIterable */

		/**
		 * @inheritDoc
		 */
		override public function get iterator() : IIterator {
			return new Iterator( this );
		}
		
		/**
		 * @inheritDoc
		 */		
		override public function get size() : int { return _map.pairs.length; }
		
		/**
		 * returns iterator from copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function cycled( nextCycle : Function = null ) : IIterator {
			return clone().cycled( nextCycle );
		}
		
		/**
		 * returns iterator from copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function repeated( nextCycle : Function = null ) : IIterator {
			return clone().repeated( nextCycle );
		}
		
		/**
		 * returns copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function get reversed() : IIterable {
			return clone().reversed;
		}
		
		/**
		 * returns copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function chain( other : IIterable ) : IIterable {
			return clone().chain( other );
		}
		
		/**
		 * returns copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function filter( filtering : Function ) : IIterable {
			return clone().filter( filtering );
		}
		
		/**
		 * returns copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function map( mapping : Function ) : IIterable {
			return cloneWith( mapping );
		}
		
		/**
		 * returns copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function range( from : int, to : int ) : IIterable {
			return clone().range( from, to );
		};
		
		/**
		 * returns copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function skip( skipped : int ) : IIterable {
			return clone().skip( skipped );
		}
		
		/**
		 * returns copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function take( taken : int ) : IIterable {
			return clone().take( taken );
		}
		
		
	}

}