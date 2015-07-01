package vm.miix.grit.emitter 
{
	import vm.miix.grit.collection.FunctionList;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.trigger.ITriggered;
	import vm.miix.grit.trigger.Triggered;
	
	/**
	 * base emitter
	 * @author Lis
	 */
	internal class Emitter implements IEmitter 
	{
		
		// functions storages
		private var _emits : FunctionList = new FunctionList();
		private var _completes : FunctionList = new FunctionList();
		private var _errors : FunctionList = new FunctionList();
		
		// active flag
		private var bActive : Boolean = true;
		
		// completed flag
		private var bCompleted : Boolean = false;
		
		// attendant triggered
		private var _attendant : ITriggered;
		
		
		public function toString() : String {
			var str : String = "emitter: ";
			if ( bCompleted ) {
				str += "completed";
			}
			else {
				if ( bActive ) str += "active, ";
				else str += "inactive, ";
				if ( _emits.isLocked ) str += "locked emit, ";
				else str += "unlocked emit, ";
				str += "subscribers onEmit: " + String( _emits.size ) + ", ";
				str += "subscribers onComplete: " + String( _completes.size ) + ", ";
				str += "subscribers onError: " + String( _errors.size );
			}
			return str;
		}
		
		public function Emitter( attendant : ITriggered = null ) {
			_attendant = attendant;
		}
		
		internal function get isCompleted() : Boolean { return bCompleted; }
		
		/**
		 * emit value or emitter
		 * @param	value value to be emitted, if emitter - emits all values from this
		 */
		internal function emit( value : * ) : void {
			if ( ! bCompleted ) {
				if ( value is IEmitter  ) {
					var regHere : ITriggered;
					var reg : ITriggered = value.subscribe (
						emit,
						regHere.cancel,
						error
					);
					// cancel when compeltes this
					regHere = _completes.add( reg.cancel );
				}
				else if ( value is IPromise ) {
					value.onCompleted( emit, error );
				}
				else if ( bActive ) {
					_emits.invokeWith( value );
				}
			}
			value = null;
		}
		
		/**
		 * completes emission
		 */
		internal function complete() : void {
			if ( ! bCompleted ) {
				bCompleted = true;
				if ( _attendant ) {
					var tmp : ITriggered = _attendant;
					_attendant = null;
					tmp.cancel();
				}
			
				// remove all observers
				_emits.clear();
				_errors.clear();

				// completes
				_completes.invoke();
				_completes.clear();
			}
		}
		
		/**
		 * emit an error
		 */
		internal function error( reason : * ) : void {
			if ( bActive && ! bCompleted ) _errors.invokeWith( reason );
			reason = null;
		}
		
		
		/* INTERFACE vm.miix.grit.emitter.IEmitter */
		
		/**
		 * @inheritDoc
		 */
		public function subscribe( onEmit : Function, onComplete : Function = null, onError : Function = null ) : ITriggered {
			
			if ( bCompleted ) {
				if ( onComplete != null ) onComplete();
				return new Triggered();
			}
			else {
				var regEmit : ITriggered;
				if ( onEmit != null ) regEmit = _emits.add( onEmit );
			
				var regComplete : ITriggered;
				if ( onComplete != null ) regComplete = _completes.add( onComplete );
			
				var regError : ITriggered;
				if ( onError != null ) regError = _errors.add( onError );
			
				return new Triggered(
					function () : void {
						if ( regEmit ) {
							var tmpReg : ITriggered = regEmit;
							regEmit = null;
							tmpReg.cancel();
						}
						if ( regComplete ) {
							tmpReg = regComplete;
							regComplete = null;
							tmpReg.cancel();
						}
						if ( regError ) {
							tmpReg = regError;
							regError = null;
							tmpReg.cancel();
						}
					},
				
					function () : void {
						if ( regEmit ) regEmit.activate();
						if ( regError ) regError.activate();
					},
				
					function () : void {
						if ( regEmit ) regEmit.deactivate();
						if ( regError ) regError.deactivate();
					}
				);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function map( mapping : Function ) : IEmitter {
			var e : Emitter = new Emitter();
			
			if ( !bCompleted ) {
				subscribe(
					function ( value : * ) : void {
						var ret : * ;
						try {
							ret = mapping( value );
						}
						catch ( err : Error ) {
							e.error( err );
							return;
						}
						e.emit( ret );
						ret = null;
					},
					e.complete,
					e.error
				);
			}
			else e.cancel();
			
			return e;
		}
		
		/**
		 * @inheritDoc
		 */
		public function filter( filtering : Function ) : IEmitter {
			var e : Emitter = new Emitter();
			
			if ( !bCompleted ) {
				subscribe(
					function ( value : * ) : void {
						var b : Boolean;
						try {
							b = filtering( value );
						}
						catch ( err : Error ) {
							e.error( err );
							return;
						}
						if ( b ) e.emit( value );
					},
					e.complete,
					e.error
				);
			}
			else e.cancel();
			
			return e;
		}
		
		
		
		/* INTERFACE vm.miix.grit.emitter.ITriggered */
		
		/**
		 * @inheritDoc
		 */
		public function deactivate() : void {
			if ( bActive && !bCompleted ) {
				bActive = false;
				if ( _attendant ) _attendant.deactivate();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function activate() : void {
			if ( !bActive && !bCompleted ) {
				bActive = true;
				if ( _attendant ) _attendant.activate();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function cancel() : void {
			complete();
		}
		
	}

}