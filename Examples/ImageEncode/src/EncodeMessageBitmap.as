package  
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import vm.miix.grit.promise.Deferred;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.wire.ISharedBytes;
	import vm.miix.grit.task.image.ImageEncodeCommand;
	
	/**
	 * fill message to encode bitmap
	 * @author Lis
	 */
	public class EncodeMessageBitmap implements IEncodeMessage 
	{
		
		private var bitmap : BitmapData;
		private var type : uint;
		
		private var deferred : Deferred = new Deferred();
		
		
		/**
		 * creates new bitmap encoding message
		 * @param	bitmap bitmap to be encoded
		 * @param	type type to be encoded to (one of listed in <code>vm.miix.grit.task.image.ImageEncodeCommand</code>)
		 * @see vm.miix.grit.task.image.ImageEncodeCommand
		 */
		public function EncodeMessageBitmap( bitmap : BitmapData, type : uint ) {
			this.bitmap = bitmap;
			this.type = type;
		}
		
		
		/* INTERFACE vm.miix.app.paint.encoder.IEncodeMessage */
		
		/**
		 * @inheritDoc
		 */
		public function fillMessage( shared : ISharedBytes ) : ImageEncodeCommand {
			shared.clear();
			bitmap.copyPixelsToByteArray( new Rectangle( 0, 0, bitmap.width, bitmap.height ), shared.byteArray );
			shared.checkOut();
			var comm : ImageEncodeCommand = new ImageEncodeCommand();
			comm.type = type;
			comm.sizeX = bitmap.width;
			comm.sizeY = bitmap.height;
			return comm;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get promise() : IPromise {
			return deferred.promise;
		}
		
		/**
		 * @inheritDoc
		 */
		public function resolve( data : ByteArray ) : void {
			deferred.resolve( data );
		}
		
		/**
		 * @inheritDoc
		 */
		public function reject( reason : * ) : void {
			deferred.reject( reason );
		}
		
	}

}