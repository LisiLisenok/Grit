package vm.miix.grit.emitter 
{
	/**
	 * messenger, contains both <code>publisher</code> and <code>emitter</code>
	 * @see vm.miix.grit.emitter.IEmitter
	 * @see vm.miix.grit.emitter.IPublisher
	 * @author Lis
	 */
	public final class Messenger 
	{
		
		private var _publisher : IPublisher;
		private var _emitter : IEmitter;
		
		public function Messenger( publisher : IPublisher, emitter : IEmitter ) {
			_publisher = publisher;
			_emitter = emitter
		}
		
		/**
		 * String representation of the messenger
		 * @return String containg information about this messenger
		 */
		public function toString() : String {
			return "messenger containing " + String( _publisher );
		}
		
		/**
		 * publisher behind this messenger
		 */
		public function get publisher() : IPublisher { return _publisher; }
		
		/**
		 * emitter behind this messenger
		 */
		public function get emitter() : IEmitter { return _emitter; }
		
	}

}