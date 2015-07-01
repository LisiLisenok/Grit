package vm.miix.grit.collection 
{
	/**
	 * empty iterator - no items to iterate
	 * @author Lis
	 */
	internal class IteratorEmpty implements IIterator 
	{
		
		public function IteratorEmpty() {
		}
		
		/* INTERFACE vm.miix.grit.collection.IIterator */
		
		/**
		 * @inheritDoc
		 */
		public function hasNext() : Boolean { return false; }
		
		/**
		 * @inheritDoc
		 */
		public function next() : Object { return null; }
		
		/**
		 * @inheritDoc
		 */
		public function hasPrevious() : Boolean { return false; }
		
		/**
		 * @inheritDoc
		 */
		public function previous() : Object { return null; }
		
		/**
		 * @inheritDoc
		 */
		public function item() : Object { return null; }
		
		/**
		 * @inheritDoc
		 */
		public function flipStart() : void {}
		
		/**
		 * @inheritDoc
		 */
		public function flipEnd() : void {}
		
		/**
		 * @inheritDoc
		 */
		public function clone() : IIterator { return this; }
		
	}

}