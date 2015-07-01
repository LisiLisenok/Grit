package
{
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.registerClassAlias;
	import flash.system.Worker;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import vm.miix.grit.collection.Collection;
	import vm.miix.grit.collection.Comparison;
	import vm.miix.grit.collection.IMap;
	import vm.miix.grit.collection.Map;
	import vm.miix.grit.emitter.Messenger;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.task.image.ImageEncodeCommand;
	import vm.miix.grit.task.image.ImageEncoder;
	import vm.miix.grit.wire.Address;
	import vm.miix.grit.wire.GritTask;
	import vm.miix.grit.wire.GritWire;
	import vm.miix.grit.wire.IContext;
	
	/**
	 * do image encoding in secondary thread
	 * @author Lis
	 */
	public class ImageEncodeExample extends Sprite 
	{
		
		private static const strLoadImage : String = "load image to be encoded";
		private static const strImageLoaded : String = "select encoding type";
		private static const strImageLoadingError : String = "error during loading";
		private static const strDoLoad : String = "image loading";
		private static const strWaitLoading : String = "wait before current loading completes";
		private static const strDoEncode : String = "image encoding";
		
		
		// grit context depending on worker
		private var wireContext : IContext;
		
		// loader with image to be encoded
		private var loader : Loader;
		
		// below line with prompt text
		private var prompt : TextField;
		
		// prompt head - shows if encoding is performed using secondary thread
		private var promptHead : String;
		
		// file reference
		private var file : FileReference;
		
		// file filtering
		private var fileFilter : FileFilter = new FileFilter( "images", "*.jpg;*.gif;*.png" )
		
		// opened file name
		private var strFile : String;
		
		// encoding eextension
		private var strEncodeExtension : String;
		
		
		public function ImageEncodeExample() {
			
			registerClassAlias( "vm.miix.grit.task.image.ImageEncodeCommand", ImageEncodeCommand );
			
			// run grit
			if ( Worker.current.isPrimordial ) {
				if ( stage ) init();
				else addEventListener( Event.ADDED_TO_STAGE, init );
			}
			else {
				// secondary thread - just create grit task and store reference on it
				wireContext = new GritTask();
			}
		}
		
		private function init( e : Event = null ) : void {
			removeEventListener( Event.ADDED_TO_STAGE, init );
			// entry point
			
			if ( Worker.isSupported ) {
				// start grit
				var wire : GritWire = new GritWire();
				wireContext = wire;
				wire.start( loaderInfo.bytes ).onCompleted( started, appCreationError );
			}
			else {
				// workers are not supported - use synchronous encoding
				setupUI( encodersMap() );
			}
			
		}
		
		
		// setup user interface
		// encoders contains encoders to perform encodings whne corresponding button has been clicked
		// buttons: "load", "jpg", "png" and "gif"
		// prompt line
		private function setupUI( encoders : IMap ) : void {
			
			var formatText : TextFormat = new TextFormat();
			formatText.font = "Tahoma";
			formatText.size = 18;
			formatText.align = TextFormatAlign.CENTER;
			formatText.leftMargin = 2;
			formatText.rightMargin = 2;
			formatText.color = 0x000000;

			var button : SimpleButton = new SimpleButton();
			var textField : TextField = new TextField();
			textField.defaultTextFormat = formatText;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.text = "load";
			button.upState = textField;
			button.hitTestState = textField;
			textField = new TextField();
			textField.defaultTextFormat = formatText;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.background = true;
			textField.backgroundColor = 0xEEEE00;
			textField.text = "load";
			button.downState = textField;
			button.overState = textField;
			button.x = 10;
			button.y = 5;
			addChild( button );
			button.addEventListener( MouseEvent.CLICK, loadNewImage );

			button = new SimpleButton();
			textField = new TextField();
			textField.defaultTextFormat = formatText;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.text = "jpg";
			button.upState = textField;
			button.hitTestState = textField;
			textField = new TextField();
			textField.defaultTextFormat = formatText;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.background = true;
			textField.backgroundColor = 0xEEEE00;
			textField.text = "jpg";
			button.downState = textField;
			button.overState = textField;
			button.x = 580;
			button.y = 5;
			addChild( button );
			button.addEventListener( MouseEvent.CLICK,
				function ( ev : Event ) : void {
					strEncodeExtension = "jpg";
					encodeWith( encoders.byKey( ImageEncodeCommand.ENCODE_JPG ) as IImageEncoder );
				}
			);

			button = new SimpleButton();
			textField = new TextField();
			textField.defaultTextFormat = formatText;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.text = "png";
			button.upState = textField;
			button.hitTestState = textField;
			textField = new TextField();
			textField.defaultTextFormat = formatText;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.background = true;
			textField.backgroundColor = 0xEEEE00;
			textField.text = "png";
			button.downState = textField;
			button.overState = textField;
			button.x = 640;
			button.y = 5;
			addChild( button );
			button.addEventListener( MouseEvent.CLICK,
				function ( ev : Event ) : void {
					strEncodeExtension = "png";
					encodeWith( encoders.byKey( ImageEncodeCommand.ENCODE_PNG ) as IImageEncoder );
				}
			);

			button = new SimpleButton();
			textField = new TextField();
			textField.defaultTextFormat = formatText;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.text = "gif";
			button.upState = textField;
			button.hitTestState = textField;
			textField = new TextField();
			textField.defaultTextFormat = formatText;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.background = true;
			textField.backgroundColor = 0xEEEE00;
			textField.text = "gif";
			button.downState = textField;
			button.overState = textField;
			button.x = 700;
			button.y = 5;
			addChild( button );
			button.addEventListener( MouseEvent.CLICK,
				function ( ev : Event ) : void {
					strEncodeExtension = "gif";
					encodeWith( encoders.byKey( ImageEncodeCommand.ENCODE_GIF ) as IImageEncoder );
				}
			);
			
			prompt = new TextField();
			addChild( prompt );
			formatText = new TextFormat();
			formatText.font = "Tahoma";
			formatText.size = 16;
			formatText.align = TextFormatAlign.CENTER;
			formatText.leftMargin = 2;
			formatText.rightMargin = 2;
			formatText.color = 0x2200DD;
			prompt.defaultTextFormat = formatText;
			prompt.autoSize = TextFieldAutoSize.LEFT;
			prompt.x = 10;
			prompt.y = 600 - prompt.textHeight - 30;
			
			if ( wireContext ) promptHead = "asynchronous encoding with Grit: ";
			else promptHead = "synchronous encoding: ";
			
			setupPromptText();
			
		}
		
		private function setupPromptText() : void {
			if ( loader ) prompt.text = promptHead + strImageLoaded;
			else prompt.text = promptHead + strLoadImage;
		}
		
		// load new image
		private function loadNewImage( e : Event = null ) : void {
			if ( file == null ) {
				file = new FileReference();
				file.addEventListener( Event.SELECT, fileSelected );
				file.addEventListener( Event.CANCEL, fileCancel );
				try {
					if ( !file.browse( [fileFilter] ) ) fileCancel();
				}
				catch ( err : Error ) {
					fileCancel();
				}
			}
			else {
				prompt.text = promptHead + strWaitLoading;
			}
		}
		
		// selection cancel
		private function fileCancel( e : Event = null ) : void {
			if ( file ) {
				file.removeEventListener( Event.SELECT, fileSelected );
				file.removeEventListener( Event.CANCEL, fileCancel );
				file = null;
				setupPromptText();
			}
		}
		
		// file has been selected - load it
		private function fileSelected( e : Event ) : void {
			file.removeEventListener( Event.SELECT, fileSelected );
			file.removeEventListener( Event.CANCEL, fileCancel );
			file.addEventListener( IOErrorEvent.IO_ERROR, fileLoadingError );
			file.addEventListener( SecurityErrorEvent.SECURITY_ERROR, fileLoadingError );
			file.addEventListener( Event.COMPLETE, fileLoaded );
			prompt.text = promptHead + strDoLoad;
			try {
				file.load();
			}
			catch ( err : Error ) {
				fileLoadingError();
			}
		}
		
		// file loading error
		private function fileLoadingError( e : Event = null ) : void {
			if ( file ) {
				file.removeEventListener( IOErrorEvent.IO_ERROR, fileLoadingError );
				file.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, fileLoadingError );
				file.removeEventListener( Event.COMPLETE, fileLoaded );
				file = null;
				prompt.text = promptHead + strImageLoadingError;
			}
		}
		
		// file has been successfully loaded
		private function fileLoaded( e : Event ) : void {
			file.removeEventListener( IOErrorEvent.IO_ERROR, fileLoadingError );
			file.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, fileLoadingError );
			file.removeEventListener( Event.COMPLETE, fileLoaded );
			
			strFile = file.name.substring( 0, file.name.lastIndexOf( "." ) + 1 );
			
			if ( loader ) removeChild( loader );
			loader = new Loader();
			try {
				loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, imageLoadingError );
				loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, imageLoadingError );
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, imageLoaded );
				loader.loadBytes( file.data );
			}
			catch ( err : Error ) {
				imageLoadingError();
			}
		}
		
		// error during image loading
		private function imageLoadingError( ev : Event = null ) : void {
			file = null;
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, imageLoadingError );
			loader.contentLoaderInfo.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, imageLoadingError );
			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, fileLoaded );
			loader = null;
			prompt.text = promptHead + strImageLoadingError;
		}
		
		// image has been loaded
		private function imageLoaded( ev : Event ) : void {
			file = null;
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, imageLoadingError );
			loader.contentLoaderInfo.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, imageLoadingError );
			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, fileLoaded );
			if ( loader.contentLoaderInfo.width > 0 && loader.contentLoaderInfo.height > 0 ) {
				addChild( loader );
				var xScale : Number = 780 / loader.contentLoaderInfo.width;
				var yScale : Number = 520 / loader.contentLoaderInfo.height;
				if ( xScale > yScale ) xScale = yScale;
				loader.width = loader.contentLoaderInfo.width * xScale;
				loader.height = loader.contentLoaderInfo.height * xScale;
				loader.x = 10 + ( 780 - loader.width ) / 2;
				loader.y = 40 + ( 520 - loader.height ) / 2;
			}
			else {
				loader = null;
			}
			setupPromptText();
		}
		
		// extract bitmap data from loaded image
		private function extractBitmap() : BitmapData {
			var bit : BitmapData = null;
			if ( loader && loader.contentLoaderInfo && loader.contentLoaderInfo.content &&
				loader.contentLoaderInfo.width > 0 && loader.contentLoaderInfo.height > 0 )
			{
				bit = new BitmapData( loader.contentLoaderInfo.width, loader.contentLoaderInfo.height );
				try {
					bit.draw( loader.contentLoaderInfo.content );
				}
				catch ( err : Error ) {
					prompt.text = promptHead + err.message;
					bit = null;
				}
			}
			else {
				if ( loader ) {
					if ( contains( loader ) ) removeChild( loader );
					loader = null;
				}
				setupPromptText();
			}
			return bit;
		}
		
		// do encoding with specified encoder
		private function encodeWith( encoder : IImageEncoder ) : void {
			if ( encoder ) {
				prompt.text = promptHead + strDoEncode;
				var bit : BitmapData = extractBitmap();
				if ( bit ) encoder.encode( bit ).onCompleted (
					storeEncoded,
					function ( reason : * ) : void {
						if ( reason ) prompt.text = promptHead + reason.toString();
						else setupPromptText();
					}
				);
			}
			else {
				trace( "no encoder" );
			}
		}
		
		// image has been encoded - store it
		private function storeEncoded( data : ByteArray ) : void {
			if ( file ) {
				prompt.text = promptHead + strWaitLoading;
			}
			else {
				file = new FileReference();
				file.addEventListener( Event.COMPLETE, imageStoringCompletes );
				file.addEventListener( Event.CANCEL, imageStoringCompletes );
				file.addEventListener(IOErrorEvent.IO_ERROR, imageStoringCompletes );
				try {
					file.save( data, strFile + strEncodeExtension );
				}
				catch ( err : Error ) {
					imageStoringCancel();
					prompt.text = promptHead + err.message;
				}
			}
		}
		
		// encoded image has been stored or some eror occured - clear file
		private function imageStoringCancel() : void {
			file.removeEventListener( Event.COMPLETE, imageStoringCompletes );
			file.removeEventListener( Event.CANCEL, imageStoringCompletes );
			file.removeEventListener(IOErrorEvent.IO_ERROR, imageStoringCompletes );
			file = null;
		}
		
		// encoded image has been stored
		private function imageStoringCompletes( e : Event = null ) : void {
			imageStoringCancel();
			setupPromptText();
		}
		
		
		// grit has been started
		private function started( context : IContext ) : void {
			context.deploy( getQualifiedClassName( ImageEncoder ) ).onCompleted ( 
				function ( f : * ) : IPromise {
					// create shared bytes to exchange bitmap data with server
					return context.createSharedBytes( ImageEncodeCommand.SERVER ).onCompleted (
						// connect to server
						function ( val : * ) : IPromise {
							return context.connect( new Address( ImageEncodeCommand.SERVER ) );
						}
					);
				}
			).onCompleted( appReady, appCreationError );
		}
		
		// ready to perform encoding in secondary task
		private function appReady( socket : Messenger ) : void {
			setupUI( gritEncodersMap( socket ) );
		}
		
		// some error has been occured during task deploying or server registration
		// use synchronous encoding
		private function appCreationError( reason : * ) : void {
			trace( "not deployed ", reason );
			wireContext = null;
			setupUI( encodersMap() );
		}
		
		
		// map with encoding types (do synchronous encoding).
		// used if workers are unsupported or if some error has been occured when starting grit
		private function encodersMap() : IMap {
			var keys : Collection = new Collection( [
					ImageEncodeCommand.ENCODE_JPG,
					ImageEncodeCommand.ENCODE_PNG,
					ImageEncodeCommand.ENCODE_GIF
				] );
			
			var encoders : Collection = new Collection( [
					new EncoderBitmap( new JPEGEncoderOptions( 100 ) ),
					new EncoderBitmap( new PNGEncoderOptions() ),
					new EncoderGIF(),
				] );
			
			return new Map( Comparison.stringIncreasing, keys, encoders );
		}
		
		// map with encoding types (do asynchronous encoding)
		// used to query encoding within secondary task
		private function gritEncodersMap( socket : Messenger ) : IMap {
			var encoder : EncoderImageClient = new EncoderImageClient( ImageEncodeCommand.SERVER, wireContext, socket );
			
			var keys : Collection = new Collection( [
					ImageEncodeCommand.ENCODE_JPG,
					ImageEncodeCommand.ENCODE_PNG,
					ImageEncodeCommand.ENCODE_GIF
				] );
			
			var encoders : Collection = new Collection( [
					new EncoderClient( encoder, ImageEncodeCommand.ENCODE_JPG ),
					new EncoderClient( encoder, ImageEncodeCommand.ENCODE_PNG ),
					new EncoderClient( encoder, ImageEncodeCommand.ENCODE_GIF ),
				] );
			
			return new Map( Comparison.stringIncreasing, keys, encoders );
		}
		
		
	}
	
}