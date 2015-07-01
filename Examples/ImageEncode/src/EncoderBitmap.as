package  
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import vm.miix.grit.promise.Deferred;
	import vm.miix.grit.promise.IPromise;
	
	/**
	 * synchronous encoding bitmap data with specified compressor
	 * (PNGEncoderOptions, JPEGEncoderOptions or JPEGXREncoderOptions).
	 * @author Lis
	 * @see flash.display.BitmapData#encode
	 * @see flash.display.JPEGEncoderOptions
	 * @see flash.display.JPEGXREncoderOptions
	 * @see flash.display.PNGEncoderOptions
	 */
	public class EncoderBitmap implements IImageEncoder 
	{
		
		/**
		 * compressor encoding is to be prefromed
		 */
		private var compressor : Object;
		
		
		/**
		 * creates new encoder
		 * @param	sizeFactor factor size to be scaled on
		 * @param	compressor compression type. Allowable values:
			 * <code>flash.display.PNGEncoderOptions</code>, <code>flash.display.JPEGEncoderOptions</code>
			 * and <code>flash.display.JPEGXREncoderOptions</code>
		 * @see flash.display.JPEGEncoderOptions
		 * @see flash.display.JPEGXREncoderOptions
		 * @see flash.display.PNGEncoderOptions
		 */
		public function EncoderBitmap( compressor : Object ) {
			this.compressor = compressor;
		}
		
		
		/**
		 * do encoding of <code>bit</code> to jpg or png depending on <code>compressor</code> specified in consructor
		 * @param	bit bitmap data to be encoded
		 * @return peomise resolved with encoded <code>ByteArray</code>
		 */
		public function encode( bit : BitmapData ) : IPromise {
			var def : Deferred = new Deferred();
			def.resolve( bit.encode( new Rectangle( 0, 0, bit.width, bit.height ), compressor ) );
			return def.promise;
		}
		
	}

}