package vm.miix.grit.wire 
{
	import vm.miix.grit.trigger.IRegistration;
	import vm.miix.grit.trigger.ITriggered;
	/**
	 * wraps another registration + cancel triggered
	 * @author Lis
	 */
	internal class RegistrationWrapper implements IRegistration 
	{
		
		/**
		 * registration to be canceled with this registration
		 */
		private var registration : IRegistration;
		
		/**
		 * triggered to be canceled when cancel this registration
		 */
		internal var triggered : ITriggered;
		
		
		public function RegistrationWrapper( registration : IRegistration ) {
			this.registration = registration;
		}
		
		
		/* INTERFACE vm.miix.grit.wire.IRegistration */
		
		/**
		 * @inheritDoc
		 */
		public function cancel() : void {
			if ( triggered ) {
				var tmpTrig : ITriggered = triggered;
				triggered = null;
				tmpTrig.cancel();
				tmpTrig = null;
			}
			if ( registration ) {
				var tmpReg : IRegistration = registration;
				registration = null;
				tmpReg.cancel();
				tmpReg = null;
			}
		}
		
	}

}