package vm.miix.grit.emitter 
{
	import vm.miix.grit.trigger.ITriggered;
	/**
	 * emitter proxy
	 * @author Lis
	 */
	internal class EmitterProxy implements IEmitter 
	{
		
		private var emitter : IEmitter;
		
		public function EmitterProxy( emitter : IEmitter ) {
			this.emitter = emitter;
		}
		
		
		/* INTERFACE vm.miix.grit.emitter.IEmitter */
		
		/**
		 * @inheritDoc
		 */
		public function subscribe( onEmit : Function, onComplete : Function = null, onError : Function = null ) : ITriggered {
			return emitter.subscribe( onEmit, onComplete, onError );
		}
		
		/**
		 * @inheritDoc
		 */
		public function map( mapping : Function ) : IEmitter { return emitter.map( mapping ); }
		
		/**
		 * @inheritDoc
		 */
		public function filter( filtering : Function ) : IEmitter { return emitter.filter( filtering ); }
		
		/**
		 * @inheritDoc
		 */
		public function cancel() : void { emitter.cancel(); }
		
		/**
		 * @inheritDoc
		 */
		public function activate() : void { emitter.activate(); }
		
		/**
		 * @inheritDoc
		 */
		public function deactivate() : void { emitter.deactivate(); }
		
	}

}