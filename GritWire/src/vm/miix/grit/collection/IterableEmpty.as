package vm.miix.grit.collection 
{
	/**
	 * empty iterable - no any items
	 * @author Lis
	 */
	internal class IterableEmpty implements IIndexed 
	{
		
		private static const _iterator : IIterator = new IteratorEmpty();
		
		public function IterableEmpty() {
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get iterator() : IIterator {
			return _iterator;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get sequence() : IIndexed { return this; }

		/**
		 * @inheritDoc
		 */
		public function getAt( index : int ) : Object {
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function findFirstOccurrence( item : Object ) : int { return -1; }
		
		/**
		 * @inheritDoc
		 */
		public function get empty() : Boolean { return true; }
		
		/**
		 * @inheritDoc
		 */
		public function cycled( nextCycle : Function = null ) : IIterator { return _iterator; }
		
		/**
		 * @inheritDoc
		 */
		public function repeated( nextCycle : Function = null ) : IIterator { return _iterator; }
		
		/**
		 * @inheritDoc
		 */
		public function get reversed() : IIterable { return this; }
		
		/**
		 * @inheritDoc
		 */
		public function get size() : int { return 0; }
		
		/**
		 * @inheritDoc
		 */
		public function count( selecting : Function ) : int { return 0; }
		
		/**
		 * @inheritDoc
		 */
		public function findFirstItem( predicate : Function ) : Object { return null; }
		
		/**
		 * @inheritDoc
		 */
		public function findLastItem( predicate : Function ) : Object { return null; }
		
		/**
		 * @inheritDoc
		 */
		public function chain( other : IIterable ) : IIterable {
			if ( other is IterableEmpty ) {
				return this;
			}
			else {
				return other;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function map( mapping : Function ) : IIterable { return this; }
		
		/**
		 * @inheritDoc
		 */
		public function filter( filtering : Function ) : IIterable { return this; }
		
		/**
		 * @inheritDoc
		 */
		public function range( from : int, to : int ) : IIterable { return this; }
		
		/**
		 * @inheritDoc
		 */
		public function skip( skipped : int ) : IIterable { return this; }
		
		/**
		 * @inheritDoc
		 */
		public function take( taken : int ) : IIterable { return this; }
		
		/**
		 * @inheritDoc
		 */
		public function sort( compare : Function ) : IIndexed { return this; }
		
		/**
		 * @inheritDoc
		 */
		public function zip( other : IIterable, paired : Function ) : void {
			var iterSecond : IIterator = other.iterator;
			while ( iterSecond.hasNext() ) {
				paired( null, iterSecond.next() );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone() : IIterable { return this; }
		
		/**
		 * @inheritDoc
		 */
		public function cloneWith( cloneItem : Function ) : IIterable { return this; }
		
		/**
		 * @inheritDoc
		 */
		public function forEach( perform : Function ) : void {}
		
	}

}