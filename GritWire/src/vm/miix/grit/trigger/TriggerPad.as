package vm.miix.grit.trigger 
{	
	
	/**
	 * trigger with force alarming
	 * @author Lis
	 */
	public class TriggerPad implements ITrigger 
	{
		
		private var _trigger : Trigger = new Trigger();
		
		
		public function TriggerPad() {
			
		}
		
		
		/**
		 * alarm this <code>trigger pad</code>.
		 * All alram listeners will be notified immediately
		 */
		public function alarm() : void { _trigger.alarm(); }
		
		/**
		 * pure <code>trigger</code> interface without alarm forcing possibility
		 * @return trigger alarms the same time as this
		 */
		public function trigger() : ITrigger { return _trigger; }
		
		/**
		 * string representation of the <code>trigger</code>
		 * @return string representation of the <code>trigger</code>
		 */
		public function toString() : String { return _trigger.toString(); }
		
		
		/* INTERFACE vm.miix.grit.trigger.ITrigger */
		
		/**
		 * @inheritDoc
		 */
		public function subscribe( onAlarm : Function, onComplete : Function = null ) : ITriggered {
			return _trigger.subscribe( onAlarm, onComplete );
		}
		
		/**
		 * @inheritDoc
		 */
		public function cancel() : void { _trigger.cancel(); }
		
		/**
		 * @inheritDoc
		 */
		public function activate() : void { _trigger.activate(); }
		
		/**
		 * @inheritDoc
		 */
		public function deactivate() : void { _trigger.deactivate(); }
		
	}

}