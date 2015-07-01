package vm.miix.grit.collection 
{
	/**
	 * chained iterator
	 * @author Lis
	 */
	internal class IteratorChained implements IIterator 
	{
		
		private var _first : IIterator;
		private var _second : IIterator;
		private var bFirst : Boolean = true;
		
		public function IteratorChained( first : IIterator, second : IIterator ) {
			_first = first;
			_second = second;
		}
		
		
		/* INTERFACE vm.miix.grit.collection.IIterator */
		
		/**
		 * @inheritDoc
		 */
		public function hasNext() : Boolean {
			if ( bFirst ) {
				if ( _first.hasNext() ) {
					return true;
				}
				else {
					_second.flipStart();
					return _second.hasNext();
				}
			}
			else {
				return _second.hasNext();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function next() : Object {
			if ( bFirst ) {
				if ( _first.hasNext() ) {
					return _first.next();
				}
				else {
					bFirst = false;
					_second.flipStart();
					return _second.next();
				}
			}
			else {
				return _second.next();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasPrevious() : Boolean {
			if ( bFirst ) {
				return _first.hasPrevious();
			}
			else {
				if ( _second.hasPrevious() ) {
					return _second.hasPrevious();
				}
				else {
					_first.flipEnd();
					return _first.hasPrevious();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function previous() : Object {
			if ( bFirst ) {
				return _first.previous();
			}
			else {
				if ( _second.hasPrevious() ) {
					return _second.previous();
				}
				else {
					bFirst = true;
					_first.flipEnd();
					return _first.previous();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function item() : Object {
			if ( bFirst ) return _first.item();
			else return _second.item();
		}
		
		/**
		 * @inheritDoc
		 */
		public function flipStart() : void {
			_first.flipStart();
			bFirst = true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function flipEnd() : void {
			_second.flipEnd();
			bFirst = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone() : IIterator {
			return new IteratorChained( _first.clone(), _second.clone() );
		}
		
	}

}