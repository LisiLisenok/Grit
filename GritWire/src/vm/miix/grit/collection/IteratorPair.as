package vm.miix.grit.collection 
{
	/**
	 * iterating key or item within a pair
	 * @author Lis
	 */
	internal class IteratorPair extends Iterator 
	{
		
		private var _isKey : Boolean;
		
		/**
		 * 
		 * @param	indexed iterating collection
		 * @param	isKey if true iterates keys otherwise iterates items
		 */
		public function IteratorPair( indexed : IIndexed, isKey : Boolean ) {
			super( indexed );
			_isKey = isKey;
		}
		

		/**
		 * @inheritDoc
		 */
		override public function next() : Object {
			var ret : Pair = super.next() as Pair;
			if ( ret ) {
				if ( _isKey ) return ret.key;
				else return ret.item;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function previous() : Object {
			var ret : Pair = super.previous() as Pair;
			if ( ret ) {
				if ( _isKey ) return ret.key;
				else return ret.item;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function item() : Object {
			var ret : Pair = super.item() as Pair;
			if ( ret ) {
				if ( _isKey ) return ret.key;
				else return ret.item;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone() : IIterator {
			return new IteratorPair( indexed, _isKey );
		}
		
	}

}