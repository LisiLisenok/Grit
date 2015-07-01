package vm.miix.grit.promise 
{
	import vm.miix.grit.emitter.IEmitter;
	import vm.miix.grit.trigger.ITriggered;
	/**
	 * resolver implementation
	 * @author Lis
	 */
	internal class Resolver implements IResolver 
	{
		// promise associated with this resolver
		private var _promise : Promise;
		
		// true if already resolved (or rejected)
		private var bResolved : Boolean = false;
		
		
		public function Resolver() {
			_promise = new Promise( this );
		}
		
		
		/**
		 * resolve with value (can be promise or emitter) whithout checking already resolved flag
		 * @param	value value to be resolved
		 */
		private function resolveWith( value : * ) : void {
			if ( value is IPromise  ) {
				value.onCompleted( resolveWith, rejectWith );
			}
			else if ( value is IEmitter ) {
				var tr : ITriggered = value.subscribe (
					function ( val : * ) : void {
							if ( tr ) {
								var tmpTr : ITriggered = tr;
								tr = null;
								tmpTr.cancel();
								tmpTr = null;
							}
							resolveWith( val );
						},
						function () : void {
							rejectWith( null );
						},
						function ( reason : * ) : void {
							if ( tr ) {
								var tmpTr : ITriggered = tr;
								tr = null;
								tmpTr.cancel();
								tmpTr = null;
							}
							rejectWith( reason );
						}
					);
			}
			else {
				_promise.resolve( value );
			}
		}
		
		/**
		 * reject with reason without checking already resolved flag
		 * @param	reason rejecting reason
		 */
		private function rejectWith( reason : * ) : void {
			_promise.reject( reason );
		}
		
		
		/* INTERFACE vm.miix.grit.promise.IResolver */
		
		/**
		 * @inheritDoc
		 */
		public function get promise() : IPromise { return _promise; }
		
		/**
		 * @inheritDoc
		 */
		public function resolve( value : * ) : void {
			if ( ! bResolved ) {
				bResolved = true;
				resolveWith( value );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function reject( reason : * ) : void {
			if ( ! bResolved ) {
				bResolved = true;
				rejectWith( reason );
			}
		}
		
		public function toString() : String {
			return "resolver for " + String( promise );
		}
		
		
		/* INTERFACE vm.miix.grit.promise.IPromisable */
		
		/**
		 * @inheritDoc
		 */
		public function compose( promise : IPromise ) : IPromise {
			if ( promise != this.promise ) promise.onCompleted( resolve, reject );
			return this.promise;
		}
		
		/**
		 * @inheritDoc
		 */
		public function map( mapping : Function ) : IPromise {
			return promise.onCompleted( mapping );
		}
		
		/**
		 * @inheritDoc
		 */
		public function and( promise : IPromise, combine : Function ) : IPromise {
			var res : Resolver = new Resolver();
			
			var first : * = null;
			var second : * = null;
			var bFilled : Boolean = false;
			var bReject : Boolean = false;
			
			promise.onCompleted (
					function ( value : * ) : void {
						if ( !bReject ) {
							first = value;
							if ( bFilled ) res.resolve( combine( first, second ) );
							else bFilled = true;
						}
					},
					function ( reason : * ) : void {
						if ( !bReject ) {
							bReject = true;
							second = null;
							res.reject( reason );
						}
					}
				);

			this.promise.onCompleted (
					function ( value : * ) : void {
						if ( !bReject ) {
							second = value;
							if ( bFilled ) res.resolve( combine( first, second ) );
							else bFilled = true;
						}
					},
					function ( reason : * ) : void {
						if ( !bReject ) {
							bReject = true;
							first = null;
							res.reject( reason );
						}
					}
				);
			
			return res.promise;
		}
		
	}

}