package vm.miix.grit.promise
{
	/**
	 * provides an instance of the <code>promise</code> and manages its lifecycle.
	 * Contains <code>promise</code> and <code>resolver</code>, which
	 * provides operations to force <code>promise</code> transition to a resolved or rejected state.
	 * @author Lis
	 * @example
		<listing version="3.0">
			var deferred : Deferred = new Deferred();
			return deferred.promise;
			---
			deferred.resolve( value );
		</listing>
		@see vm.miix.grit.promise.IPromise
		@see vm.miix.grit.promise.IResolver
	 */
	public class Deferred implements IPromise, IResolver 
	{
		
		private var _resolver : IResolver;
		
		public function Deferred() {
			_resolver = new Resolver();
		}
		
		
		/**
		 * object with only <code>IResolver</code> interface
		 */
		public function get resolver() : IResolver { return _resolver; }
		
		
		/* INTERFACE vm.miix.grit.promise.IResolver */
		
		/**
		 * @inheritDoc
		 */
		public function get promise() : IPromise { return _resolver.promise; }
		
		/**
		 * @inheritDoc
		 */
		public function resolve( valueOrPromise : * ) : void { _resolver.resolve( valueOrPromise ); }
		
		/**
		 * @inheritDoc
		 */
		public function reject( reason : * ) : void { _resolver.reject( reason ); }
		
		/**
		 * @inheritDoc
		 */
		public function compose( promise : IPromise ) : IPromise { return _resolver.compose( promise ); }
		
		/**
		 * @inheritDoc
		 */
		public function map( mapping : Function ) : IPromise { return _resolver.map( mapping ); }
		
		/**
		 * @inheritDoc
		 */
		public function and( promise : IPromise, combine : Function ) : IPromise {
			return _resolver.and( promise, combine );
		}

		/**
		 * String representation of the deferred
		 * @return String containg information about this deferred
		 */
		public function toString() : String {
			return "deferred containing " + String( resolver );
		}
		
		/* INTERFACE vm.miix.grit.promise.IPromise */
		
		/**
		 * @inheritDoc
		 */
		public function onCompleted( onFulfilled : Function, onRejected : Function = null ) : IPromise {
			return promise.onCompleted( onFulfilled, onRejected );
		}
		
	}

}