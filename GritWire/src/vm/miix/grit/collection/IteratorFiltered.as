package vm.miix.grit.collection 
{
	/**
	 * filtering iterated elements
	 * @author Lis
	 */
	internal class IteratorFiltered implements IIterator 
	{
		
		private var _iterator : IIterator
		private var _filter : Function;
		
		public function IteratorFiltered( iterator : IIterator, filter : Function ) {
			_iterator = iterator;
			_filter = filter;
			flipStart();
		}
		
		
		/* INTERFACE vm.miix.grit.collection.IIterator */
		
		/**
		 * @inheritDoc
		 */
		public function hasNext() : Boolean {
			var count : int = 0;
			while ( _iterator.hasNext() ) {
				count ++;
				if ( _filter( _iterator.next() ) ) {
					while ( count -- ) _iterator.previous();
					return true;
				}
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function next() : Object {
			while ( _iterator.hasNext() ) {
				var ret : Object = _iterator.next();
				if ( _filter( ret ) ) return ret;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function item() : Object {
			if ( _iterator.hasNext() ) {
				var ret : Object = next();
				previous();
				return ret;
			}
			else {
				ret = previous();
				next();
				return ret;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasPrevious() : Boolean {
			var count : int = 0;
			while ( _iterator.hasPrevious() ) {
				count ++;
				if ( _filter( _iterator.previous() ) ) {
					while ( count -- ) _iterator.next();
					return true;
				}
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function previous() : Object {
			while ( _iterator.hasPrevious() ) {
				var ret : Object = _iterator.previous();
				if ( _filter( ret ) ) return ret;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function flipStart() : void {
			_iterator.flipStart();
		}
		
		/**
		 * @inheritDoc
		 */
		public function flipEnd() : void {
			_iterator.flipEnd();
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone() : IIterator {
			return new IteratorFiltered( _iterator.clone(), _filter );
		}
		
	}

}