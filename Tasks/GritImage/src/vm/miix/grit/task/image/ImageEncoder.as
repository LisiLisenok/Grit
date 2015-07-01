package vm.miix.grit.task.image 
{
	import flash.display.BitmapData;
	import flash.display.IGraphicsData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.geom.Rectangle;
	import vm.miix.grit.emitter.Messenger;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.trigger.IRegistration;
	import vm.miix.grit.wire.Address;
	import vm.miix.grit.wire.IContext;
	import vm.miix.grit.wire.ISharedBytes;
	import vm.miix.grit.wire.ITask;
	import vm.miix.grit.wire.ServerDescriptor;
	import vm.miix.grit.wire.ServerTypes;
	
	/**
	 * encode images task.
	 * Register server with name <code>ImageEncodeCommand.SERVER</code>.
	 * Listen commands <code>ImageEncodeCommand</code>.
	 * Receives bitmap data bytes using shared bytes specified in <code>ImageEncodeCommand.sharedName</code>.
	 * Encode this to type specified in <code>ImageEncodeCommand.type</code> and sends back using the same shred bytes.
	 * @see vm.miix.grit.wire.IContext#createSharedBytes
	 * @see vm.miix.grit.wire.IContext#checkInSharedBytes
	 * @see vm.miix.grit.wire.ISharedBytes
	 * @see vm.miix.grit.task.image.ImageEncodeCommand
	 * 
	 * @author Lis
	 */
	public class ImageEncoder implements ITask 
	{
		
		// context task is run on
		private var context : IContext;
		
		
		public function ImageEncoder() {
			
		}
		
		
		private function readBitmap( command : ImageEncodeCommand, shared : ISharedBytes ) : BitmapData {
			var bit : BitmapData = new BitmapData( command.sizeX, command.sizeY );
			shared.position = 0;
			var rect : Rectangle = new Rectangle( 0, 0, command.sizeX, command.sizeY );
			bit.setPixels( rect, shared.byteArray );
			shared.clear();
			return bit;
		}
		
		/**
		 * client is connected
		 * @param	socket socket to receive / send data to client
		 */
		private function onConnected( socket : Messenger ) : void {
			socket.emitter.subscribe (
				function ( command : ImageEncodeCommand ) : void {
					context.checkInSharedBytes( command.sharedName ).onCompleted (
						function ( shared : ISharedBytes ) : void {
							var bErrorFlag : Boolean = true;
							try {
								
								switch ( command.type ) {
									
									case ImageEncodeCommand.ENCODE_JPG:
										shared.writeBytes( readBitmap( command, shared )
												.encode( new Rectangle( 0, 0, command.sizeX, command.sizeY ),
														 new JPEGEncoderOptions( 100 ) ) );
										bErrorFlag = false;
										break;
									
									case ImageEncodeCommand.ENCODE_PNG:
										shared.writeBytes( readBitmap( command, shared )
												.encode( new Rectangle( 0, 0, command.sizeX, command.sizeY ),
														 new PNGEncoderOptions() ) );
										bErrorFlag = false;
										break;
									
									case ImageEncodeCommand.ENCODE_GIF:
										var bit : BitmapData = readBitmap( command, shared );
										var encoder : AnimatedGIFEncoder = new AnimatedGIFEncoder();
										encoder.start( shared );
										encoder.setDelay( 0 );
										encoder.addFrame( bit );
										encoder.finish();
										bErrorFlag = false;
										break;
										
									case ImageEncodeCommand.ENCODE_SVG:
										var paintItems : Vector.<IGraphicsData> = GraphicsIO.readGraphicData( shared );
										shared.clear();
										var svg : GraphicsSVG = new GraphicsSVG();
										svg.offset( command.sizeX, command.sizeY );
										svg.drawGraphicsData( paintItems );
										shared.writeUTFBytes( svg.finalizeDraw().toXMLString() );
										bErrorFlag = false;
										break;
								}
							}
							catch ( err : Error ) {
								shared.clear();
							}
							shared.position = 0;
							shared.checkOut();
							if ( bErrorFlag ) socket.publisher.error( ImageEncodeCommand.INCORRECT_TYPE );
							else socket.publisher.publish( command );
							
						}
					)
				}
			);
		}
		
		
		/* INTERFACE vm.miix.grit.wire.ITask */
		
		/**
		 * @inheritDoc
		 * register server with name <code>ImageCommand.SERVER</code>
		 */
		public function run( context : IContext, registration : IRegistration, param : * ) : IPromise {
			this.context = context;
			return context.registerServer( new ServerDescriptor( new Address( ImageEncodeCommand.SERVER ),
					ServerTypes.INTERNAL ), onConnected );
		}
		
	}

}