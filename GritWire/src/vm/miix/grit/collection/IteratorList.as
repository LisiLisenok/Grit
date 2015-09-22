package vm.miix.grit.collection 
{
	/**
	 * itarate linked list
	 * @author Lis
	 */
	internal class IteratorList implements IIterator 
	{
		
		internal var list : List;
		internal var _current : ListItem;
		
		public function IteratorList( list : List ) {
			this.list = list;
			flipStart();
		}

		
		/* INTERFACE vm.miix.grit.collection.IIterator */
		
		/**
		 * @inheritDoc
		 */
		public function hasNext() : Boolean {
			return list.nextActive( _current ) != null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function next() : Object {
			_current = list.nextActive( _current );
			if ( _current ) {
				var ret : ListItem = _current;
				_current = _current.next;
				return ret.item;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasPrevious() : Boolean {
			if ( _current ) return list.prevActive( _current.prev ) != null;
			else return list.prevActive( list._last ) != null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function previous() : Object {
			if ( _current ) {
				_current = list.prevActive( _current.prev );
				if ( _current ) return _current.item;
				else flipStart();
			}
			else {
				_current = list.prevActive( list._last );
				if ( _current ) return _current.item;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function item() : Object {
			if ( _current ) return _current.item;
			else {
				var l : ListItem = list.prevActive( list._last );
				if ( l ) return l.item;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function flipStart() : void {
			_current = list.nextActive( list._first );
		}
		
		/**
		 * @inheritDoc
		 */
		public function flipEnd() : void {
			_current = null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone() : IIterator {
			return new IteratorList( list );
		}
		
	}

}