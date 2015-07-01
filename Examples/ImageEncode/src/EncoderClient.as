package  
{
	import flash.display.BitmapData;
	import vm.miix.grit.promise.IPromise;
	
	/**
	 * asynchronous encoding using <code>EncoderBitmapClient</code>
	 * @author Lis
	 */
	public class EncoderClient implements IImageEncoder
	{
		
		/**
		 * encoding type
		 */
		private var type : uint;
		
		/**
		 * client used to encode
		 */
		private var encoder : EncoderImageClient;
		
		
		/**
		 * creates new image encoder client
		 * @param	encoder bitmap encoder used within this image encoder (to send commands to task).
		 * It is recommended to use only one encoder within all EncoderImageClient's to quaranty that all encodings
		 * doesn't clear shared bytes filled by currently processed one
		 * @param	type encoding type - a one from listed in <code>vm.miix.grit.task.image.ImageEncodeCommand</code>
		 * @see vm.miix.grit.task.image.ImageEncodeCommand
		 */
		public function EncoderClient( encoder : EncoderImageClient, type : uint ) {
			this.encoder = encoder;
			this.type = type;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function encode( bit : BitmapData ) : IPromise {
			return encoder.encodeBitmap( bit, type );
		}
		
	}

}