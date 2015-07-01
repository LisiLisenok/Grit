package vm.miix.grit.emitter 
{
	import vm.miix.grit.trigger.ITriggered;
	import vm.miix.grit.trigger.Triggered;
	/**
	 * promise - emits only once.
	 * If subscribed after emision (resolving) responds immediately
	 * @author Lis
	 */
	internal class PromisedEmitter extends Emitter 
	{
		
		private var bResolved : Boolean = false;
		private var bError : Boolean = false;
		private var bCanceled : Boolean = false;
		
		private var valOrError : * = null;
		
		public function PromisedEmitter( attendant : ITriggered = null ) {
			super( attendant );
			subscribe( onEmit, null, onError );
		}
		
		private function onEmit( val : * ) : void {
			bResolved = true;
			valOrError = val;
		}
		
		private function onError( reason : * ) : void {
			bResolved = true;
			bError = true;
			valOrError = reason;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override internal function emit( valOrEmitter : * ) : void {
			if ( !bResolved ) {
				super.emit( valOrEmitter );
				if ( bResolved ) complete();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override internal function error( reason : * ) : void {
			if ( !bResolved ) {
				super.error( reason );
				if ( bResolved ) complete();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override internal function complete() : void {
			if ( !bResolved ) {
				bCanceled = true;
				bResolved = true;
			}
			super.complete();
		}

		
		
		/**
		 * @inheritDoc
		 */
		override public function subscribe( onEmit : Function, onComplete : Function = null,
			onError : Function = null ) : ITriggered
		{
			if ( bResolved ) {
				if ( bError ) {
					if ( onError != null ) onError( valOrError );
				}
				else if ( !bCanceled ) {
					if ( onEmit != null ) onEmit( valOrError );
				}
				if ( onComplete != null ) onComplete();
				return new Triggered();
			}
			else return super.subscribe( onEmit, onComplete, onError );
		}
		
	}

}