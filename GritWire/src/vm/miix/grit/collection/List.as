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
		internal var first : ListItem = null;
		/**
		 * last item in the list
		 */
		internal var last : ListItem = null;
		
		private var addStack : Vector.<ListItem> = new Vector.<ListItem>();
		
		/**
		 * number of items in the list
		 */
		internal var _size : int = 0;
		
		/**
		 * if == 0 then uncloked, if > 0 then locked
		 */
		private var locking : uint = 0;
		
		public function List() {
			super();
		}
		
		
		public function get isLocked() : Boolean { return locking > 0; }
		
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
					first = listItem;
					listItem.prev = null;
					if ( last == null ) last = listItem;
				}
			}
			else {
				if ( last ) {
					listItem.prev = last;
					last.next = listItem;
					last = listItem;
				}
				else {
					listItem.prev = null;
					first = listItem;
					last = listItem;
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
			else addStack.push( listItem );
			return itemTriggered( listItem );
		}
		
		/**
		 * remove item if unlocked
		 * @param	listItem item to be removed
		 */
		internal function removeItem( listItem : ListItem ) : void {
			listItem.inLife = false;
			_size --;
			if ( !isLocked ) {
				var prev : ListItem = listItem.prev;
				if ( prev ) {
					prev.next = listItem.next;
					if ( listItem.next ) listItem.next.prev = prev;
					else last = prev;
					listItem.prev = null;
				}
				else {
					first = listItem.next;
					if ( first ) first.prev = null;
					else last = null;
					listItem.next = null;
				}
			}
		}
		
		/**
		 * add items from stack and remove canceled items
		 */
		private function normalize() : void {
			if ( !isLocked ) {
				// add items
				for ( var i : int = 0; i < addStack.length; i ++ ) {
					putListItem( addStack[i], addStack[i].next );
				}
				addStack.splice( 0, addStack.length );
				// remove items
				var item : ListItem = first;
				while ( item ) {
					var tmp : ListItem = item.next;
					if ( !item.inLife ) removeItem( item );
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
						listItem.active = true;
						_size ++;
					}
				},
				function () : void {
					if ( listItem ) {
						listItem.active = false;
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
		public function add( item : Object ) : ITriggered {
			return putBefore( item, first );
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
			var rem : ListItem = nextActive( first );
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
			var rem : ListItem = prevActive( last );
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
			addStack.splice( 0, addStack.length );
			// remove items
			var item : ListItem = first;
			while ( item ) {
				item.inLife = false;
				item = item.next;
			}
			normalize();
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
			locking ++;
		}
		
		/**
		 * @inheritDoc
		 */		
		public function unlock() : void {
			if ( locking > 0 ) locking --;
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