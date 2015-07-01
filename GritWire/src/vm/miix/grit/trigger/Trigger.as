package vm.miix.grit.trigger 
{
	import vm.miix.grit.collection.FunctionList;
	
	/**
	 * base implementation of <code>trigger</code>.
	 * @author Lis
	 */
	internal class Trigger implements ITrigger 
	{
		
		// functions storages
		private var _alarm : FunctionList = new FunctionList();
		private var _completes : FunctionList = new FunctionList();
		
		// active flag
		private var bActive : Boolean = true;
		
		// completed flag
		private var bCompleted : Boolean = false;
		
		
		public function Trigger() {	
		}
		
		
		internal function get isCompleted() : Boolean { return bCompleted; }
		
		/**
		 * string representation of the <code>trigger</code>
		 * @return string representation of the <code>trigger</code>
		 */
		public function toString() : String {
			var str : String = "trigger: ";
			if ( bCompleted ) {
				str += "completed";
			}
			else {
				if ( bActive ) str += "active, ";
				else str += "inactive, ";
				str += "subscribers onAlarm: " + String( _alarm.size ) + ", ";
				str += "subscribers onComplete: " + String( _completes.size );
			}
			return str;
		}
		
		/**
		 * alarm this <code>trigger</code>.
		 * All alram listeners will be notified immediately
		 */
		internal function alarm() : void {
			if ( bActive && ! bCompleted ) _alarm.invoke();
		}
		
		
		
		/* INTERFACE vm.miix.grit.trigger.ITrigger */
		
		/**
		 * @inheritDoc
		 */
		public function subscribe( onAlarm : Function, onComplete : Function = null ) : ITriggered {
			if ( !bCompleted ) {
				var regAlarm : ITriggered;
				if ( onAlarm != null ) regAlarm = _alarm.push( onAlarm );
			
				var regComplete : ITriggered;
				if ( onComplete != null ) regComplete = _completes.push( onComplete );
			
				return new Triggered(
					function () : void {
						if ( regAlarm ) {
							regAlarm.cancel();
							regAlarm = null;
						}
						if ( regComplete ) {
							regComplete.cancel();
							regComplete = null;
						}
					},
					function () : void { if ( regAlarm ) regAlarm.activate(); },
					function () : void { if ( regAlarm ) regAlarm.deactivate(); }
				);
			}
			else {
				return new Triggered();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function deactivate() : void { bActive = false; }
		
		/**
		 * @inheritDoc
		 */
		public function activate() : void { bActive = true; }
		
		/**
		 * @inheritDoc
		 */
		public function cancel() : void {
			if ( ! bCompleted ) {
				bCompleted = true;
				// remove all observers
				_alarm.clear();
				// completes
				_completes.invoke();
				_completes.clear();
			}
		}
		
	}

}