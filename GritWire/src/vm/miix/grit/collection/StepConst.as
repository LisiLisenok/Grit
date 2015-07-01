package vm.miix.grit.collection 
{
	/**
	 * constant step, can be used within <code>Interpolator</code>
	 * @see vm.miix.grit.collection.Interpolator
	 * @author Lis
	 */
	public class StepConst implements IStep 
	{
		
		private var _step : Number;
		
		public function StepConst( step : Number ) {
			_step = step;
		}
		
		/* INTERFACE vm.miix.grit.collection.IStep */
		
		/**
		 * @inheritDoc
		 */
		public function step( time : Number ) : Number {
			return _step;
		}
		
	}

}