package vm.miix.grit.collection 
{
	/**
	 * map iterating items with mapping function
	 * @author Lis
	 */
	internal class IteratorMap implements IIterator 
	{
		
		private var _iterator : IIterator;
		private var _mapping : Function;
		
		public function IteratorMap( iter : IIterator, mapping : Function ) {
			_iterator = iter;
			_mapping = mapping;
		}
		
		/* INTERFACE vm.miix.grit.collection.IIterator */
		
		/**
		 * @inheritDoc
		 */
		public function hasNext() : Boolean {
			return _iterator.hasNext();
		}
		
		/**
		 * @inheritDoc
		 */
		public function next() : Object {
			return _mapping( _iterator.next() );
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasPrevious() : Boolean {
			return _iterator.hasPrevious();
		}
		
		/**
		 * @inheritDoc
		 */
		public function previous() : Object {
			return _mapping( _iterator.previous() );
		}
		
		/**
		 * @inheritDoc
		 */
		public function item() : Object {
			return _mapping( _iterator.item() );
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
			return new IteratorMap( _iterator.clone(), _mapping );
		}
		
	}

}