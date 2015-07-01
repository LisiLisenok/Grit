package vm.miix.grit.trigger 
{
	
	/**
	 * list of triggered - triggers all from the list
	 * @author Lis
	 */
	public class TriggeredList implements ITriggered
	{
		
		private var _triggers : Vector.<ITriggered> = new Vector.<ITriggered>();
		
		private var bActive : Boolean = true;
		private var bCanceled : Boolean = false;
		
		
		public function TriggeredList() {
			
		}
		
		
		private function findTrigger( trigger : ITriggered ) : int {
			for ( var i : int = 0; i < _triggers.length; i ++ ) {
				if ( _triggers[i] == trigger ) {
					return i;
				}
			}
			return -1;
		}
		
		
		/**
		 * true if no triggers has been added
		 */
		public function get empty() : Boolean { return _triggers.length == 0; }
		
		/**
		 * add triggered to the list
		 * @param	trigger item to be added
		 */
		public function addTrigger( trigger : ITriggered ) : void {
			if ( findTrigger( trigger ) < 0 ) _triggers.push( trigger );
		}
		
		/**
		 * remove trigger from the list
		 * @param	trigger item to be removed
		 */
		public function removeTrigger( trigger : ITriggered ) : void {
			var i : int = findTrigger( trigger );
			if ( i > -1 ) _triggers.splice( i, 1 );
		}
		
		
		/* INTERFACE vm.miix.grit.collection.ITriggered */
		
		/**
		 * @inheritDoc
		 */
		public function deactivate() : void {
			if ( bActive && !bCanceled ) {
				bActive = false;
				for each ( var trig : ITriggered in _triggers ) {
					trig.deactivate();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function activate() : void {
			if ( !bActive && !bCanceled ) {
				bActive = true;
				for each ( var trig : ITriggered in _triggers ) {
					trig.activate();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function cancel() : void {
			if ( !bCanceled ) {
				bCanceled = true;
				for each ( var trig : ITriggered in _triggers ) {
					trig.cancel();
				}
				_triggers.splice( 0, _triggers.length );
			}
		}
		
	}

}