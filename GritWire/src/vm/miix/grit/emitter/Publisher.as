package vm.miix.grit.emitter 
{
	/**
	 * base publisher
	 * @author Lis
	 */
	internal class Publisher implements IPublisher 
	{
		
		private var _emitter : Emitter;
		
		public function Publisher( emitter : Emitter = null ) {
			if ( emitter ) _emitter = emitter;
			else _emitter = new Emitter();
		}
		
		internal function get emitter() : IEmitter { return _emitter; }
		
		public function toString() : String {
			return "publisher with " + String( emitter );
		}
		
		
		/* INTERFACE vm.miix.grit.emitter.IPublisher */
		
		/**
		 * @inheritDoc
		 */
		public function publish( value : * ) : void {
			if ( _emitter ) _emitter.emit( value );
			value = null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function complete() : void {
			if ( _emitter ) {
				_emitter.complete();
				_emitter = null;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function error( reason : * ) : void {
			if ( _emitter ) _emitter.error( reason );
			reason = null;
		}
		
	}

}