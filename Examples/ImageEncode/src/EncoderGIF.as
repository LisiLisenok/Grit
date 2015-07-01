package  
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import vm.miix.grit.promise.Deferred;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.task.image.AnimatedGIFEncoder;
	
	/**
	 * synchromous encoding bitmap data to gif
	 * @author Lis
	 */
	public class EncoderGIF implements IImageEncoder
	{
		
		public function EncoderGIF() {
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function encode( bit : BitmapData ) : IPromise {
			var def : Deferred = new Deferred();
			var encoder : AnimatedGIFEncoder = new AnimatedGIFEncoder();
			var ba : ByteArray = new ByteArray();
			encoder.start( ba );
			encoder.setDelay( 0 );
			encoder.addFrame( bit );
			encoder.finish();
			ba.position = 0;
			def.resolve( ba );
			return def.promise;
		}
		
		
	}

}