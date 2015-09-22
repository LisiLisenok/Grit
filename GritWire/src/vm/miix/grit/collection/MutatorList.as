package vm.miix.grit.collection 
{
	import vm.miix.grit.trigger.ITriggered;
	
	/**
	 * list mutator
	 * @author Lis
	 */
	internal class MutatorList extends IteratorList implements IMutator 
	{
		
		public function MutatorList( list : List ) {
			super( list );
		}
		
		
		/* INTERFACE vm.miix.grit.collection.IMutator */
		
		/**
		 * @inheritDoc
		 */
		public function insert( item : Object ) : ITriggered {
			return list.putBefore( item, _current );
		}
		
		/**
		 * @inheritDoc
		 */
		public function remove() : Object {
			if ( _current ) {
				var rem : ListItem = _current;
				_current = _current.next != null ? _current.next : _current.prev;
				list.removeItem( rem );
				return rem.item;
			}
			return null;
		}
		
		
	}

}