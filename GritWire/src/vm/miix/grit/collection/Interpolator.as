package vm.miix.grit.collection 
{
	/**
	 * interpolates objects with argument
	 * @author Lis
	 */
	public class Interpolator extends IterableBase 
	{
		
		
		public static function interpolateNumber( left : Number, right : Number, time : Number ) : Number {
			return left * ( 1 - time ) + right * time;
		}
		
		
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
		 * creates new <code>Interpolator</code>
		 * @param	step step to calculate next / previous value
		 * @param	time times
		 * @param	values values corresponds to times, must be the same size (if shorter or longer values or times are truncated)
		 * @param	interpolate function to interpolate objects. Takes left, right objects and coefficient from 0 to 1,
		 * corresponds to interpolated object value
		 * Must return new object corresponds third argument (from 0 to 1). If this argument (time) is 0 must return left,
		 * if 1 must return right
		 * <listing>function interpolate( left : Object, right : Object, time : Number ) : Object </listing>
		 */
		public function Interpolator( step : IStep, time : Vector.<Number>,
				values : Vector.<Object>, interpolate : Function = null )
		{
			super();
			_step = step;
			if ( interpolate == null ) _interpolate = interpolateNumber;
			else _interpolate = interpolate;
			var size : int = time.length;
			if ( size > values.length ) size = values.length;
			for ( var i : int = 0; i < size; i ++ ) {
				_time.push( time[i] );
				_values.push( values[i] );
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get iterator() : IIterator {
			return new IteratorInterpolate( _step, _time, _values, _interpolate );
		}
		
		
	}

}