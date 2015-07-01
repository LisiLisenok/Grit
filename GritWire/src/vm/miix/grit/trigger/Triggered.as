package vm.miix.grit.trigger 
{
	
	/**
	 * triggered which uses functions provided in constructor
	 * @author Lis
	 */
	public class Triggered implements ITriggered 
	{
		
		private var _cancel : Function;
		private var _activate : Function;
		private var _deactivate : Function;
		
		
		/**
		 * @param	fnCancel function which is called at cancel whithout arguments
		 * @param	activate function which is called at resume whithout arguments
		 * @param	deactivate function which is called at pause whithout arguments
		 */
		public function Triggered( fnCancel : Function = null, fnActivate : Function = null, fnDeactivate : Function = null ) {
			_cancel = fnCancel;
			_activate = fnActivate;
			_deactivate = fnDeactivate;
		}
		
		/**
		 * reset this trigger to zero state
		 */
		private function reset() : void {
			_cancel = null;
			_activate = null;
			_deactivate = null;
		}
		
		
		
		/* INTERFACE vm.miix.grit.collection.ITriggered */
		
		/**
		 * @inheritDoc
		 */
		public function cancel() : void {
			if ( _cancel != null ) {
				var tmp : Function = _cancel;
				reset();
				tmp();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function deactivate() : void {
			if ( _deactivate != null ) _deactivate();
		}
		
		/**
		 * @inheritDoc
		 */
		public function activate() : void {
			if ( _activate != null ) _activate();
		}
		
	}

}