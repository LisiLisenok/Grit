package  
{
	import flash.utils.ByteArray;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.task.image.ImageEncodeCommand;
	import vm.miix.grit.wire.ISharedBytes;
	
	/**
	 * message sent to encode task
	 * @author Lis
	 */
	public interface IEncodeMessage 
	{
		/**
		 * fill message sent to encode task
		 * @param	shared shared to be filled with encoding data
		 * @param	sharedName name of shared property
		 * @return encode command sent to encoding task
		 */
		function fillMessage( shared : ISharedBytes ) : ImageEncodeCommand;
		
		/**
		 * promise behind this message
		 */
		function get promise() : IPromise;
		
		/**
		 * resolve this message
		 * @param	data encoded data
		 */
		function resolve( data : ByteArray ) : void;
		
		/**
		 * reject this message
		 * @param	reason rejecting reason
		 */
		function reject( reason : * ) : void;
		
	}
	
}