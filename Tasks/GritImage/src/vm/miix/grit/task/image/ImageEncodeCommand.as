package vm.miix.grit.task.image 
{
	/**
	 * command sent to image task.
	 * To be registerred using <code>flash.net.registerClassAlias</code>
	 * @see flash.net.registerClassAlias
	 * @author Lis
	 */
	public class ImageEncodeCommand 
	{	
		
		/**
		 * encode to jpg
		 */
		public static const ENCODE_JPG : uint = 1;
		
		/**
		 * encode to png
		 */
		public static const ENCODE_PNG : uint = 2;
		
		/**
		 * encode to gif
		 */
		public static const ENCODE_GIF : uint = 3;
		
		/**
		 * encode to gif
		 */
		public static const ENCODE_SVG : uint = 4;
		
		
		/**
		 * name of server to connect to encode images
		 */
		public static const SERVER : String = "miixImageEncoding";
		
		
		/**
		 * encoding type is not supported
		 */
		public static const INCORRECT_TYPE : String = "miixImageIncorrectType";
		
		
		/**
		 * encode type.
		 * Identifies format to be encoded to:
		 * @see #ENCODE_JPG
		 * @see #ENCODE_PNG
		 * @see #ENCODE_GIF
		 */
		public var type : uint;
		
		/**
		 * name of shared property
		 * @see vm.miix.grit.wire.IContext#createSharedBytes
		 * @see vm.miix.grit.wire.IContext#checkInSharedBytes
		 * @see vm.miix.grit.wire.ISharedBytes
		 */
		public var sharedName : String;
		
		/**
		 * bitmap width or x-offset if svg
		 */
		public var sizeX : int;
		
		/**
		 * bitmap height or y-offset if svg
		 */
		public var sizeY : int;
		
		
		public function ImageEncodeCommand() {
			
		}
		
	}

}