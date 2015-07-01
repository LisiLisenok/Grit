package vm.miix.grit.trigger 
{
	
	/**
	 * canceling registration
	 * @author Lis
	 */
	public class Registration implements IRegistration 
	{
		// cancel function behind this registration
		private var _cancel : Function;
		
		/**
		 * creates new registration
		 * @param	canceling function called when registration canceled
		 */
		public function Registration( canceling : Function ) {
			_cancel = canceling;
		}
		
		
		/* INTERFACE vm.miix.grit.wire.IRegistration */
		
		/**
		 * @inheritDoc
		 */
		public function cancel() : void {
			if ( _cancel != null ) {
				var tmpCancel : Function = _cancel;
				_cancel = null;
				tmpCancel();
			}
		}
		
	}

}