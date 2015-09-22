package vm.miix.grit.collection 
{
	import vm.miix.grit.trigger.ITriggered;
	import vm.miix.grit.trigger.Triggered;
	/**
	 * dual-direction mutable linked list of items
	 * @author Lis
	 */
	public class List extends IterableBase implements ISet 
	{
		/**
		 * first item in the list
		 */
		internal var _first : ListItem = null;
		
		/**
		 * last item in the list
		 */
		internal var _last : ListItem = null;
		
		/**
		 * items to be added
		 */
		private var _addStack : Vector.<ListItem> = new Vector.<ListItem>();
		
		/**
		 * number of items in the list
		 */
		private var _size : int = 0;
		
		/**
		 * if == 0 then uncloked, if > 0 then locked
		 */
		private var _locking : uint = 0;
		
		
		/**
		 * creates new empty list
		 */
		public function List() {
			super();
		}
		
		
		/**
		 * true if list is locked to add / remove items
		 */
		public function get isLocked() : Boolean { return _locking > 0; }
		
		
		private function putListItem( listItem : ListItem, before : ListItem ) : void {
			listItem.next = before;
			if ( before ) {
				var prev : ListItem = before.prev;
				before.prev = listItem;
				if ( prev ) {
					listItem.prev = prev;
					prev.next = listItem;
				}
				else {
					_first = listItem;
					listItem.prev = null;
					if ( _last == null ) _last = listItem;
				}
			}
			else {
				if ( _last ) {
					listItem.prev = _last;
					_last.next = listItem;
					_last = listItem;
				}
				else {
					listItem.prev = null;
					_first = listItem;
					_last = listItem;
				}
			}
			_size ++;
		}
		
		/**
		 * put new item before specified, if listItem is null put last
		 * @param	item item to be put
		 * @param	before new item is to be put before, if null new item is put last
		 * @return triggered for the newly addeditem
		 */
		internal function putBefore( item : Object, before : ListItem ) : ITriggered {
			var listItem : ListItem = new ListItem( item, before, null );			
			if ( !isLocked ) putListItem( listItem, before );
			else _addStack.push( listItem );
			return itemTriggered( listItem );
		}
		
		/**
		 * remove item if unlocked
		 * @param	listItem item to be removed
		 */
		internal function removeItem( listItem : ListItem ) : void {
			if ( !listItem.isCanceled ) {
				if ( !listItem.isRemoving ) _size --;
				if ( !isLocked ) {
					listItem.state = ListItem.STATE_CANCELED;
					removeItemFromList( listItem );
				}
				else {
					listItem.state = ListItem.STATE_REMOVING;
				}
			}
		}
		
		/**
		 * directly remove item from list without changing state and nevetherless list is locked or not
		 * @param	listItem
		 */
		internal function removeItemFromList( listItem  : ListItem ) : void {
			var prev : ListItem = listItem.prev;
			if ( prev ) {
				prev.next = listItem.next;
				if ( listItem.next ) {
					listItem.next.prev = prev;
					listItem.next = null;
				}
				else _last = prev;
				listItem.prev = null;
			}
			else {
				_first = listItem.next;
				if ( _first ) _first.prev = null;
				else _last = null;
				listItem.next = null;
			}
		}
		
		/**
		 * add items from stack and remove canceled items
		 */
		private function normalize() : void {
			if ( !isLocked ) {
				// add items
				for ( var i : int = 0; i < _addStack.length; i ++ ) {
					putListItem( _addStack[i], _addStack[i].next );
				}
				_addStack.splice( 0, _addStack.length );
				// remove items
				var item : ListItem = _first;
				while ( item ) {
					var tmp : ListItem = item.next;
					if ( item.isRemoving ) removeItem( item );
					item = tmp;
				}
			}
		}
		
		/**
		 * returns trigerred for the list item
		 * @param	listItem item the triggered is looking for
		 * @return triggered to trigger specified item
		 */
		internal function itemTriggered( listItem : ListItem ) : ITriggered {
			return new Triggered (
				function () : void {
					if ( listItem ) {
						var tmpListItem : ListItem = listItem;
						listItem = null;
						removeItem( tmpListItem );
					}
				},
				function () : void {
					if ( listItem ) {
						listItem.state = ListItem.STATE_ACTIVE;
						_size ++;
					}
				},
				function () : void {
					if ( listItem ) {
						listItem.state = ListItem.STATE_INACTIVE;
						_size --;
					}
				}
			);
		}
		
		/**
		 * next active invluding listItem
		 * @param	listItem next to which active is looked for (including listItem)
		 * @return next (including listItem) active item
		 */
		internal function nextActive( listItem : ListItem ) : ListItem {
			var ret : ListItem = listItem;
			while ( ret && !ret.isActive ) {
				ret = ret.next;
			}
			return ret;
		}
		
		/**
		 * previous active invluding listItem
		 * @param	listItem previous to which active is looked for (including listItem)
		 * @return previous (including listItem) active item
		 */
		internal function prevActive( listItem : ListItem ) : ListItem {
			var ret : ListItem = listItem;
			while ( ret && !ret.isActive ) {
				ret = ret.prev;
			}
			return ret;
		}
		
		
		
		/* INTERFACE vm.miix.grit.collection.ISet */
		
		/**
		 * iterator of mutable collection may produce unexpected results if items added / removed during iterations
		 * @inheritDoc
		 */
		override public function get iterator() : IIterator {
			return new IteratorList( this );
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mutator() : IMutator {
			return new MutatorList( this );
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get first() : Object {
			if ( _first ) return _first.item;
			else return null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get last() : Object {
			if ( _last ) return _last.item;
			else return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function add( item : Object ) : ITriggered {
			return putBefore( item, _first );
		}
		
		/**
		 * @inheritDoc
		 */
		public function push( item : Object ) : ITriggered {
			return putBefore( item, null );
		}
		
		/**
		 * @inheritDoc
		 */
		public function accept() : Object {
			var rem : ListItem = nextActive( _first );
			if ( rem ) {
				removeItem( rem );
				return rem.item;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function pop() : Object {
			var rem : ListItem = prevActive( _last );
			if ( rem ) {
				removeItem( rem );
				return rem.item;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function clear() : void {
			_addStack.splice( 0, _addStack.length );
			// remove items
			var item : ListItem = _first;
			while ( item ) {
				item.state = ListItem.STATE_REMOVING;
				item = item.next;
			}
			normalize();
			_size = 0;
		}
		
		/**
		 * return number of active items in the list
		 * @inheritDoc
		 */		
		override public function get size() : int { return _size; }
		
		/**
		 * @inheritDoc
		 */		
		public function lock() : void {
			_locking ++;
		}
		
		/**
		 * @inheritDoc
		 */		
		public function unlock() : void {
			if ( _locking > 0 ) _locking --;
			normalize();
		}
		
		/**
		 * returns iterator from copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function cycled( nextCycle : Function = null ) : IIterator {
			return clone().cycled( nextCycle );
		}
		
		/**
		 * returns iterator from copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function repeated( nextCycle : Function = null ) : IIterator {
			return clone().repeated( nextCycle );
		}
		
		/**
		 * returns copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function get reversed() : IIterable {
			return clone().reversed;
		}
		
		/**
		 * returns copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function chain( other : IIterable ) : IIterable {
			return clone().chain( other );
		}
		
		/**
		 * returns copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function filter( filtering : Function ) : IIterable {
			return clone().filter( filtering );
		}
		
		/**
		 * returns copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function map( mapping : Function ) : IIterable {
			return cloneWith( mapping );
		}
		
		/**
		 * returns copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function range( from : int, to : int ) : IIterable {
			return clone().range( from, to );
		};
		
		/**
		 * returns copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function skip( skipped : int ) : IIterable {
			return clone().skip( skipped );
		}
		
		/**
		 * returns copied immutable collection
		 * <p><i>eager</i></p>
		 * @inheritDoc
		 */
		override public function take( taken : int ) : IIterable {
			return clone().take( taken );
		}
		
		
	}

}