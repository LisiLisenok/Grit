package vm.miix.grit.promise 
{
	import vm.miix.grit.collection.FunctionList;
	
	/**
	 * promise implementation
	 * @author Lis
	 */
	internal class Promise implements IPromise
	{
		
		// promisable to compose with
		private var promisable : IPromisable;
		
		// callbacks
		private var fulfillList : FunctionList = new FunctionList();
		private var rejectList : FunctionList = new FunctionList();
		
		// fullfill
		private var valueOrReason : * = null;
		
		private var bRejected : Boolean = false;
		private var bCompleted : Boolean = false;
		
		public function Promise( promisable : IPromisable ) {
			this.promisable = promisable;
		}
		
		private function clear() : void {
			fulfillList.clear();
			rejectList.clear();
		}
		
		/**
		 * resolve this promise with value value
		 * @param	value resolving value
		 */
		internal function resolve( value : * ) : * {
			bCompleted = true;
			valueOrReason = value;
			fulfillList.invokeWith( value );
			clear();
			return value;
		}
		
		/**
		 * reject this promise with reason reason
		 * @param	reason rejecting reason
		 */
		internal function reject( reason : * ) : * {
			bRejected = true;
			bCompleted = true;
			valueOrReason = reason;
			rejectList.invokeWith( reason );
			clear();
			return reason;
		}
		
		/**
		 * string representation of the promise
		 * @return string represented this promise
		 */
		public function toString() : String {
			var str : String = "promise: ";
			if ( bCompleted ) {
				if ( bRejected ) {
					str += "rejected with ";
				}
				else {
					str += "resolved with ";
				}
				str += String( valueOrReason );
			}
			else {
				str += "not resolved";
			}
			return str;
		}
		
		
		/* INTERFACE vm.miix.grit.promise.IPromise */
		
		/**
		 * @inheritDoc
		 */
		public function get promise() : IPromise { return this; }
		
		/**
		 * @inheritDoc
		 */
		public function onCompleted( onFulfilled : Function, onRejected : Function = null ) : IPromise {
			var resolver : Resolver = new Resolver();
			if ( ! bCompleted ) {
				// not completed - store callbacks
				fulfillList.add( function ( val : * ) : void {
						if ( onFulfilled != null ) resolver.resolve( onFulfilled( val ) );
						else resolver.resolve( val );
					} );
				if ( onRejected != null ) rejectList.add( onRejected );
				rejectList.add( resolver.reject );
			}
			else if ( bRejected ) {
				// rejected
				if ( onRejected != null ) onRejected( valueOrReason );
				resolver.reject( valueOrReason );
			}
			else {
				// resolved
				if ( onFulfilled != null ) resolver.resolve( onFulfilled( valueOrReason ) );
				else resolver.resolve( valueOrReason );
			}
			return resolver.promise;
		}
		
		
		/* INTERFACE vm.miix.grit.promise.IPromisable */
		
		/**
		 * @inheritDoc
		 */
		public function compose( promise : IPromise ) : IPromise { return promisable.compose( promise ); }
		
		/**
		 * @inheritDoc
		 */
		public function map( mapping : Function ) : IPromise { return promisable.map( mapping ); }
		
		/**
		 * @inheritDoc
		 */
		public function and( promise : IPromise, combine : Function ) : IPromise { return promisable.and( promise, combine ); }
		
	}

}