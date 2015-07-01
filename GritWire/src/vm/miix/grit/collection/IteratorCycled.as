package vm.miix.grit.collection 
{
	/**
	 * cycled iterator, so when reached end it is reversed.
	 * Produce infinite iterations
	 * @author Lis
	 */
	internal class IteratorCycled implements IIterator 
	{
		private var _iterator : IIterator;
		private var forward : Boolean = true;
		
		private var _cycleFeed : Function;
		private var _active : Boolean = true;
		
		public function IteratorCycled( iterator : IIterator, cycleFeed : Function = null ) {
			_iterator = iterator;
			_cycleFeed = cycleFeed;
		}
		
		private function nextCycle() : Object {
			if ( _iterator.hasNext() ) {
				return _iterator.next();
			}
			else {
				forward = false;
				_iterator.previous();
				if ( _iterator.hasPrevious() ) {
					return _iterator.previous();
				}
				else {
					forward = true;
					return _iterator.next();
				}
			}
		}
		
		private function prevCycle() : Object {
			if ( _iterator.hasPrevious() ) {
				var ret : Object = _iterator.previous();
				if ( !_iterator.hasPrevious() && _cycleFeed != null ) {
					_active = _cycleFeed();
				}
				return ret;
			}
			else {
				forward = true;
				_iterator.next();
				if ( _iterator.hasNext() ) {
					return _iterator.next();
				}
				else {
					forward = false;
					return _iterator.previous();
				}
			}
		}
		
		/* INTERFACE vm.miix.grit.collection.IIterator */
		
		/**
		 * @inheritDoc
		 */
		public function hasNext() : Boolean {
			return _active && ( _iterator.hasNext() || _iterator.hasPrevious() );
		}
		
		/**
		 * @inheritDoc
		 */
		public function next() : Object {
			if ( _active ) {
				if ( forward ) return nextCycle();
				else return prevCycle();
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasPrevious() : Boolean {
			return _active && ( _iterator.hasNext() || _iterator.hasPrevious() );
		}
		
		/**
		 * @inheritDoc
		 */
		public function previous() : Object {
			if ( _active ) {
				if ( forward ) return nextCycle();
				else return prevCycle();
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function item() : Object {
			return _iterator.item();
		}
		
		/**
		 * @inheritDoc
		 */
		public function flipStart() : void {
			_iterator.flipStart();
			forward = true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function flipEnd() : void {
			_iterator.flipEnd();
			forward = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone() : IIterator {
			return new IteratorCycled( _iterator.clone() );
		}
		
	}

}