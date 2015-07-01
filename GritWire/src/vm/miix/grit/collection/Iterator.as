package vm.miix.grit.collection 
{
	/**
	 * base iterator imlementation
	 * @author Lis
	 */
	internal class Iterator implements IIterator 
	{
		
		private var _indexed : IIndexed;
		private var _current : int = 0;
		
		public function Iterator( indexed : IIndexed ) {
			_indexed = indexed;
		}
		
		
		/**
		 * indexed this iterator iterates
		 */
		internal function get indexed() : IIndexed { return _indexed; }
		
		
		/* INTERFACE vm.miix.grit.collection.IBaseIterator */
		
		/**
		 * @inheritDoc
		 */
		public function hasNext() : Boolean { return _current < _indexed.size; }
		
		/**
		 * @inheritDoc
		 */
		public function next() : Object {
			if ( hasNext() ) return _indexed.getAt( _current ++ );
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasPrevious() : Boolean { return _current > 0; }
		
		/**
		 * @inheritDoc
		 */
		public function previous() : Object {
			if ( hasPrevious() ) return _indexed.getAt( --_current );
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function item() : Object {
			if ( _current < _indexed.size ) return _indexed.getAt( _current );
			else if ( _indexed.size > 0 ) return _indexed.getAt( _indexed.size - 1 );
			else return null;
		}

		/**
		 * @inheritDoc
		 */
		public function flipStart() : void {
			_current = 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public function flipEnd() : void {
			_current = _indexed.size;
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone() : IIterator {
			return new Iterator( _indexed );
		}
		
	}

}