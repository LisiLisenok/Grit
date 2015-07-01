package vm.miix.grit.collection 
{
	/**
	 * ranged iterator from..to, including to
	 * @author Lis
	 */
	internal class IteratorRanged implements IIterator 
	{
		
		private var _iterator : IIterator;
		private var _from : int;
		private var _to : int;
		private var _index : int;
		
		public function IteratorRanged( iterator : IIterator, from : int, to : int ) {
			_iterator = iterator;
			_from = from;
			_to = to;
			flipStart();
		}
		
		/* INTERFACE vm.miix.grit.collection.IBaseIterator */
		
		/**
		 * @inheritDoc
		 */
		public function hasNext() : Boolean {
			if ( _index <= _to ) return _iterator.hasNext();
			else return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function next() : Object {
			if ( hasNext() ) {
				_index ++;
				return _iterator.next();
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasPrevious() : Boolean {
			if ( _index > _from ) return _iterator.hasPrevious();
			else return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function previous() : Object {
			if ( hasPrevious() ) {
				_index --;
				return _iterator.previous();
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
			_index = _from;
			for ( var i : int = 0; i < _from; i ++ ) {
				_iterator.next();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function flipEnd() : void {
			_index = _to + 1;
			_iterator.flipStart();
			for ( var i : int = 0; i < _index; i ++ ) {
				_iterator.next();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone() : IIterator {
			return new IteratorRanged( _iterator.clone(), _from, _to );
		}
		
	}

}