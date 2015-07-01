package vm.miix.grit.collection 
{
	/**
	 * repeates one reached ends.
	 * Produce infinite iterations
	 * @author Lis
	 */
	internal class IteratorRepeated implements IIterator 
	{
		
		private var _iterator : IIterator;
		
		private var _cycleFeed : Function;
		private var _active : Boolean = true;
		
		public function IteratorRepeated( iterator : IIterator, cycleFeed : Function = null ) {
			_iterator = iterator;
			_cycleFeed = cycleFeed;
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
				if ( !_iterator.hasNext() ) flipStart();
				var ret : Object = _iterator.next();
				if ( !_iterator.hasNext() && _cycleFeed != null ) {
					_active = _cycleFeed();
				}
				return ret;
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
				if ( !_iterator.hasPrevious() ) flipEnd();
				var ret : Object = _iterator.previous();
				if ( !_iterator.hasPrevious() && _cycleFeed != null ) {
					_active = _cycleFeed();
				}
				return ret;
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
		public function flipStart() : void { _iterator.flipStart(); }
		
		/**
		 * @inheritDoc
		 */
		public function flipEnd() : void { _iterator.flipEnd() }
		
		/**
		 * @inheritDoc
		 */
		public function clone() : IIterator {
			return new IteratorRepeated( _iterator.clone() );
		}
		
	}

}