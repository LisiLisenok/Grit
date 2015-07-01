package vm.miix.grit.collection 
{
	/**
	 * reversed iterations
	 * @author Lis
	 */
	internal class IteratorReveresed implements IIterator 
	{
		
		private var _iterator : IIterator;
		
		public function IteratorReveresed( iterator : IIterator ) {
			_iterator = iterator;
			flipStart();
		}
		
		/* INTERFACE vm.miix.grit.collection.IBaseIterator */
		
		/**
		 * @inheritDoc
		 */
		public function hasNext() : Boolean { return _iterator.hasPrevious(); }
		
		/**
		 * @inheritDoc
		 */
		public function next() : Object { return _iterator.previous(); }
		
		/**
		 * @inheritDoc
		 */
		public function hasPrevious() : Boolean { return _iterator.hasNext(); }
		
		/**
		 * @inheritDoc
		 */
		public function previous() : Object { return _iterator.next(); }
		
		/**
		 * @inheritDoc
		 */
		public function item() : Object { return _iterator.item(); }
		
		/**
		 * @inheritDoc
		 */
		public function flipStart() : void { _iterator.flipEnd(); }
		
		/**
		 * @inheritDoc
		 */
		public function flipEnd() : void { _iterator.flipStart(); }
		
		/**
		 * @inheritDoc
		 */
		public function clone() : IIterator {
			return new IteratorReveresed( _iterator.clone() );
		}
		
	}

}