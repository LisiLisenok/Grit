package vm.miix.grit.collection 
{
	
	/**
	 * step used within interpolations.
	 * Allows to modify step from time to time
	 * @author Lis
	 * @see vm.miix.grit.collection.Interpolator
	 */
	public interface IStep 
	{
		/**
		 * calculates step depending on time.
		 * Step is delta added to current value to get next value.
		 * @param	time time to calculate step at
		 * @return step at time <code>time</code>
		 */
		function step( time : Number ) : Number;
	}
	
}