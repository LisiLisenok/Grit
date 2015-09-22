package vm.miix.grit.promise 
{
	import vm.miix.grit.promise.IOperation;
	import vm.miix.grit.promise.IPromise;
	
	/**
	 * base operation
	 * @author Lis
	 */
	public class Operation implements IOperation 
	{
		
		private var _promise : IPromise;
		private var _cancel : Function;
		
		
		/**
		 * creates operation
		 * @param	promise promise returned by operation
		 * @param	canceling function without arguments called if canceled:
		 * <listing>function canceling() : void</listing>
		 */
		public function Operation( promise : IPromise, canceling : Function ) {
			_promise = promise;
			_cancel = canceling;
		}
		
		
		/* INTERFACE vm.miix.grit.wire.IOperation */		
		
		/**
		 * @inheritDoc
		 */
		public function cancel() : void {
			if ( _cancel != null ) _cancel();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get promise() : IPromise {
			return _promise;
		}
		
		/**
		 * @inheritDoc
		 */
		public function onCompleted( onFulfilled : Function, onRejected : Function = null ) : IPromise {
			return promise.onCompleted( onFulfilled, onRejected );
		}
		
		/**
		 * @inheritDoc
		 */
		public function compose( another : IPromise ) : IPromise { return promise.compose( another ); }
		
		/**
		 * @inheritDoc
		 */
		public function map( mapping : Function ) : IPromise { return promise.map( mapping ); }
		
		/**
		 * @inheritDoc
		 */
		public function and( another : IPromise, combine : Function ) : IPromise {
			return promise.and( another, combine );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onOperationCompleted( onFulfilled : Function, onRejected : Function = null ) : IOperation {
			return new Operation( promise.onCompleted( onFulfilled, onRejected ), _cancel );
		}

		
	}

}