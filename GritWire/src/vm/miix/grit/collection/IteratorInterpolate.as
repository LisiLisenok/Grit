package vm.miix.grit.collection 
{
	/**
	 * iterator used to interpolate iterations
	 * @author Lis
	 */
	internal class IteratorInterpolate implements IIterator 
	{
		
		/**
		 * step to calculate next value at
		 */
		private var _step : IStep;
		
		/**
		 * time
		 */
		private var _time : Vector.<Number> = new Vector.<Number>();
		
		/**
		 * values corresponds to time
		 */
		private var _values : Vector.<Object> = new Vector.<Object>();
		
		/**
		 * interpolation function
		 * <listing>function interpolate( left : Object, right : Object, time : Number ) : Object </listing>
		 */
		private var _interpolate : Function;
		
		
		/**
		 * current time value
		 */
		private var _currentTime : Number;
		
		
		public function IteratorInterpolate( step : IStep, time : Vector.<Number>,
				values : Vector.<Object>, interpolate : Function )
		{
			_step = step;
			_interpolate = interpolate;
			_time = time;
			_values = values;
			flipStart();
		}
		
		/**
		 * next index related to specified time (greater or equal to 1 and less than maximum)
		 * @return next index or -1
		 */
		private function nextIndex( time : Number ) : int {
			for ( var i : int = 1; i < _time.length; i ++ ) {
				if ( _time[i] >= time ) return i;
			}
			return -1;
		}
		
		/**
		 * previous index related to specified time (greater or equal to zero and less than maximum - 1)
		 * @return previous index or -1
		 */
		private function previousIndex( time : Number ) : int {
			for ( var i : int = _time.length - 2; i > -1; i -- ) {
				if ( _time[i] <= time ) return i;
			}
			return -1;
		}
		
		/**
		 * interpolate data using index in _time and _values arrays
		 * @param	index index used for interpolation
		 * @return interpolated data
		 */
		private function interpolateWithIndex( index : int ) : Object {
			var param : Number = _time[index] - _time[index - 1];
			if ( param != 0 ) param = ( _currentTime - _time[index - 1] ) / param;
			else param = 1;
			return _interpolate( _values[index - 1], _values[index], param );
		}
		
		/* INTERFACE vm.miix.grit.collection.IIterator */
		
		/**
		 * @inheritDoc
		 */
		public function hasNext() : Boolean {
			return nextIndex( _currentTime ) > -1;
		}
		
		/**
		 * @inheritDoc
		 */
		public function next() : Object {
			var nIndex : int = nextIndex( _currentTime );
			if ( nIndex > -1 ) {
				var ret : Object = interpolateWithIndex( nIndex );
				_currentTime += _step.step( _currentTime );
				return ret;
			}
			else return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasPrevious() : Boolean {
			return previousIndex( _currentTime ) > -1;
		}
		
		/**
		 * @inheritDoc
		 */
		public function previous() : Object {
			var nIndex : int = previousIndex( _currentTime );
			if ( nIndex > -1 ) {
				var ret : Object = interpolateWithIndex( nIndex + 1 );
				_currentTime -= _step.step( _currentTime );
				return ret;
			}
			else return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function item() : Object {
			var nIndex : int = nextIndex( _currentTime );
			if ( nIndex > -1 ) return interpolateWithIndex( nIndex );
			else return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function flipStart() : void {
			if ( _time.length > 0 ) _currentTime = _time[0];
			else _currentTime = 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public function flipEnd() : void {
			if ( _time.length > 0 ) _currentTime = _time[_time.length - 1];
			else _currentTime = 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone() : IIterator {
			return new IteratorInterpolate( _step, _time, _values, _interpolate );
		}
		
	}

}