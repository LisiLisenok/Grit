package  
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import vm.miix.grit.promise.IPromise;
	
	/**
	 * encode image
	 * @author Lis
	 */
	public interface IImageEncoder 
	{
		/**
		 * encode image
		 * @param	bitmap to be encoded
		 * @return <code>promise</code> resolved with byte array with encoded image bytes
		 */
		function encode( bit : BitmapData ) : IPromise;
	}
	
}