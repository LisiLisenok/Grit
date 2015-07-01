package  
{
	import flash.display.BitmapData;
	import flash.display.IGraphicsData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import vm.miix.grit.collection.List;
	import vm.miix.grit.emitter.Messenger;
	import vm.miix.grit.promise.Deferred;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.task.image.ImageEncodeCommand;
	import vm.miix.grit.wire.IContext;
	import vm.miix.grit.wire.ISharedBytes;
	
	/**
	 * encoding bitmap using server (task)
	 * @author Lis
	 */
	public class EncoderImageClient 
	{
		
		private var sharedName : String;
		private var context : IContext;
		private var socket : Messenger;
		
		// EncodeMessage stack
		private var waiters : List = new List();
		private var current : IEncodeMessage;
		
		
		/**
		 * creates new encoder client
		 * @param	sharedName name of shared bytes used to store bitmap data to be encoded and to receive encoded bytes
		 * @param	context context client run on (to ask shared bytes)
		 * @param	socket socket to exchange data with server
		 * @see vm.miix.grit.wire.ISharedBytes
		 */
		public function EncoderImageClient( sharedName : String, context : IContext, socket : Messenger ) {
			super();
			this.sharedName = sharedName;
			this.context = context;
			this.socket = socket;
			socket.emitter.subscribe( onEncoded, onCompleted, onError );
		}
		
		
		private static function rejectPromise( msg : IEncodeMessage ) : void {
			msg.reject( new Error( "image encoder task has been completed" ) );
		}
		
		
		private function processMessage() : void {
			if ( !current ) {
				current = waiters.accept() as IEncodeMessage;
				if ( current ) context.checkInSharedBytes( sharedName ).onCompleted( sendCurrent );
			}
		}
		
		private function sendCurrent( shared : ISharedBytes ) : void {
			var comm : ImageEncodeCommand = current.fillMessage( shared );
			comm.sharedName = sharedName;
			socket.publisher.publish( comm );
		}
		
		private function completeEncoding( shared : ISharedBytes ) : void {
			if ( current ) {
				shared.position = 0;
				var ba : ByteArray = new ByteArray();
				ba.writeBytes( shared.byteArray );
				shared.clear();
				shared.checkOut();
				current.resolve( ba );
				current = null;
			}
			processMessage();
		}
		
		private function onEncoded( comm : ImageEncodeCommand ) : void {
			context.checkInSharedBytes( sharedName ).onCompleted( completeEncoding, onError );
		}
		
		private function onError( reason : * ) : void {
			if ( current ) {
				current.reject( reason );
				current = null;
			}
			processMessage();
		}
		
		private function onCompleted() : void {
			waiters.lock();
			waiters.forEach( rejectPromise );
			waiters.clear();
			waiters.unlock();
			current = null;
		}
		
		/**
		 * do encoding
		 * @param	bit bitmap to be encoded
		 * @param	type type to be encoded to (one of listed in <code>vm.miix.grit.task.image.ImageEncodeCommand</code>)
		 * @return promise resolved with encoded byte array
		 * @see vm.miix.grit.task.image.ImageEncodeCommand
		 */
		public function encodeBitmap( bit : BitmapData, type : uint ) : IPromise {
			var msg : EncodeMessageBitmap = new EncodeMessageBitmap( bit, type );
			waiters.push( msg );
			processMessage();
			return msg.promise;
		}
		
	}

}