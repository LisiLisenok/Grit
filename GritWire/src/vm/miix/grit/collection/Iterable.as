package vm.miix.grit.collection 
{
	/**
	 * itarable based on iterator
	 * @author Lis
	 */
	internal class Iterable extends IterableBase
	{
		private var _iterator : IIterator;
		
		public function Iterable( iterator : IIterator ) {
			_iterator = iterator;
		}
		
		/* INTERFACE vm.miix.grit.collection.IIterable */
		
		/**
		 * @inheritDoc
		 */
		override public function get iterator() : IIterator {
			return _iterator.clone();
		}
				
	}

}