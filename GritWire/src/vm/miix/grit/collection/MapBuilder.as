package vm.miix.grit.collection 
{
	/**
	 * building map based on vectors
	 * @author Lis
	 */
	internal class MapBuilder 
	{
		/**
		 * key->item pairs
		 */
		internal var pairs : Vector.<Object> = new Vector.<Object>();
		/**
		 * key->index in pairs sorted by key
		 */
		internal var indexies : Vector.<Object> = new Vector.<Object>();
		
		/**
		 * keys comparator
		 */
		internal var compare : Function;
		
		public function MapBuilder( compare : Function ) {
			this.compare = compare;
		}
		
		/**
		 * returns index in indexies of newly added pair (to be added to)
		 * @param	key pair key
		 * @return index pair to be added or -1 if pair with the already exists
		 */
		private function newItemIndex( key : Object ) : int {
			var nFirst : int = 0;
			var nLast : int = indexies.length - 1;
			
			if ( nLast < 0 ) return 0;
			else if ( compare( indexies[0].key, key ) > 0 ) return 0;
			else if ( compare( indexies[nLast].key, key ) < 0 ) return nLast + 1;
			
			var nMid : int;
			
			while ( nFirst < nLast ) {
				nMid = ( nFirst + nLast ) / 2;
				var comp : int = compare( indexies[nMid].key, key );
				if ( comp < 0) nFirst = nMid + 1;
				else if ( comp > 0 ) nLast = nMid;
				else return -1;
			}
			if ( nFirst == indexies.length || nFirst < indexies.length && compare( indexies[nFirst].key, key ) != 0 )
				return nFirst;
			return -1;
		}
		
		/**
		 * returns index in indexies of pair if exists or -1 otherwise
		 * @param	key pairkey to be looked for
		 * @return index of pair if exists or -1 otherwise
		 */
		internal function getSortedIndex( key : Object ) : int {
			var nFirst : int = 0;
			var nLast : int = indexies.length - 1;
			var nMid : int;
			while ( nFirst < nLast ) {
				nMid = ( nFirst + nLast ) / 2;
				var comp : int = compare( indexies[nMid].key, key );
				if ( comp < 0 ) nFirst = nMid + 1;
				else if ( comp > 0 ) nLast = nMid;
				else return nMid;
			}
			if ( nFirst < indexies.length && compare( indexies[nFirst].key, key ) == 0 ) return nFirst;
			return -1;
		}
		
		
		/**
		 * returns index in <code>pairs</code> array
		 * @param	key pair key to be looked for
		 * @return index in <code>pairs</code> array or -1 if not found
		 */
		internal function getPairIndex( key : Object ) : int {
			var index : int = getSortedIndex( key );
			if ( index > -1 ) return indexies[index].item;
			return -1;
		}
		
		/**
		 * find item corresponds to specified <code>key</code>
		 * @param	key <code>key</code> of searching pair
		 * @return item corresponds to key <code>key</code> or null if doesn't exists
		 */
		internal function byKey( key : Object ) : Object {
			var index : int = getPairIndex( key );
			if ( index > -1 ) return pairs[index].item;
			return null;
		}
		
		
		/**
		 * add new key->item pair.
		 * If pair has already existsed, pair item is replaced with new one
		 * @param	key added pair <code>key</code>
		 * @param	item added pair <code>item</code>
		 */
		internal function add( key : Object, item : Object ) : void {
			var n : int = newItemIndex( key );
			if ( n > -1 ) {
				indexies.length ++;
				pairs.length ++;
				for ( var i : int = indexies.length - 1; i > n; i -- ) {
					indexies[i] = indexies[i - 1];
				}
				indexies[n] = new Pair( key, pairs.length - 1 );
				pairs[pairs.length - 1] = new Pair( key, item );
			}
			else {
				n = getPairIndex( key );
				if ( n > -1 ) pairs[n]._item = item;
			}
		}
		
		
		/**
		 * remove pair with key <code>key</code>
		 * @param	key key of removed pair
		 * @return item of removed pair
		 */
		internal function remove( key : Object ) : Object {
			var ret : Object = null;
			var n : int = getSortedIndex( key );
			if ( n > -1 ) {
				var ind : int = indexies[n].item as int;
				ret = pairs[ind].item;
				pairs.splice( ind, 1 );
				indexies.splice( n, 1 );
				for ( var i : int = 0; i < indexies.length; i ++ ) {
					var pair : Pair = indexies[i] as Pair;
					n = pair.item as int;
					if ( n > ind ) pair._item = n - 1;
				}
			}
			return ret;
		}
		
		/**
		 * remove all items
		 */
		internal function clear() : void {
			pairs.splice( 0, pairs.length );
			indexies.splice( 0, indexies.length );
		}
		
	}

}