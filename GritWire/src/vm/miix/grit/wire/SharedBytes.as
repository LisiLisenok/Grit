package vm.miix.grit.wire 
{
	import flash.utils.ByteArray;
	
	/**
	 * shared bytes implementation
	 * @author Lis
	 */
	internal final class SharedBytes implements ISharedBytes 
	{
		
		private var _byteArray : ByteArray;
		private var doCheckOut : Function;
		
		
		public function SharedBytes( byteArray : ByteArray, doCheckOut : Function ) {
			this._byteArray = byteArray;
			this.doCheckOut = doCheckOut;
		}
		
		
		
		/* INTERFACE vm.miix.grit.wire.ISharedBytes */
		
		/**
		 * @inheritDoc
		 */
		public function get position() : uint {
			return byteArray.position;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set position( value : uint ) : void {
			byteArray.position = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function clear() :void {
			byteArray.clear();
		}
		
		/**
		 * @inheritDoc
		 */
		public function checkOut() : void {
			_byteArray = null;
			if ( doCheckOut != null ) {
				var tmpCheckOut : Function = doCheckOut;
				doCheckOut = null;
				tmpCheckOut();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get byteArray() : ByteArray { return _byteArray; }
		
		
		/* INTERFACE flash.utils.IDataInput */
		
		/**
		 * @inheritDoc
		 */
		public function readBytes( bytes : ByteArray, offset : uint = 0, length : uint = 0 ) : void {
			return byteArray.readBytes( bytes, offset, length );
		}
		
		/**
		 * @inheritDoc
		 */
		public function readBoolean() : Boolean {
			return byteArray.readBoolean();
		}
		
		/**
		 * @inheritDoc
		 */
		public function readByte() : int {
			return byteArray.readByte();
		}
		
		/**
		 * @inheritDoc
		 */
		public function readUnsignedByte() : uint {
			return byteArray.readUnsignedByte();
		}
		
		/**
		 * @inheritDoc
		 */
		public function readShort() : int {
			return byteArray.readShort();
		}
		
		/**
		 * @inheritDoc
		 */
		public function readUnsignedShort() : uint {
			return byteArray.readUnsignedShort();
		}
		
		/**
		 * @inheritDoc
		 */
		public function readInt() : int {
			return byteArray.readInt();
		}
		
		/**
		 * @inheritDoc
		 */
		public function readUnsignedInt() : uint {
			return byteArray.readUnsignedInt();
		}
		
		/**
		 * @inheritDoc
		 */
		public function readFloat() : Number {
			return byteArray.readFloat();
		}
		
		/**
		 * @inheritDoc
		 */
		public function readDouble() : Number {
			return byteArray.readDouble();
		}
		
		/**
		 * @inheritDoc
		 */
		public function readMultiByte( length : uint, charSet : String ) : String {
			return byteArray.readMultiByte( length, charSet );
		}
		
		/**
		 * @inheritDoc
		 */
		public function readUTF() : String {
			return byteArray.readUTF();
		}
		
		/**
		 * @inheritDoc
		 */
		public function readUTFBytes( length : uint ) : String {
			return byteArray.readUTFBytes( length );
		}
		
		/**
		 * @inheritDoc
		 */
		public function get bytesAvailable() : uint {
			return byteArray.bytesAvailable;
		}
		
		/**
		 * @inheritDoc
		 */
		public function readObject() : * {
			return byteArray.readObject();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get objectEncoding() : uint { return byteArray.objectEncoding; }
		
		/**
		 * @inheritDoc
		 */
		public function set objectEncoding( value : uint ) : void { byteArray.objectEncoding = value; }
		
		/**
		 * @inheritDoc
		 */
		public function get endian() : String { return byteArray.endian; }
		
		/**
		 * @inheritDoc
		 */
		public function set endian( value : String ) : void { byteArray.endian = value; }
		
		
		
		/* INTERFACE flash.utils.IDataOutput */
		
		/**
		 * @inheritDoc
		 */
		public function writeBytes( bytes : ByteArray, offset : uint = 0, length : uint = 0 ) : void {
			byteArray.writeBytes( bytes, offset, length );
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeBoolean( value : Boolean ) : void {
			byteArray.writeBoolean( value );
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeByte( value : int ) : void {
			byteArray.writeByte( value );
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeShort( value : int ) : void {
			byteArray.writeShort( value );
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeInt( value : int ) : void {
			byteArray.writeInt( value );
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeUnsignedInt( value : uint ) : void {
			byteArray.writeUnsignedInt( value );
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeFloat( value : Number ) : void {
			byteArray.writeFloat( value );
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeDouble( value : Number ) : void {
			byteArray.writeDouble( value );
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeMultiByte( value : String, charSet : String ) : void {
			byteArray.writeMultiByte( value, charSet );
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeUTF( value : String ) : void {
			byteArray.writeUTF( value );
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeUTFBytes( value : String ) : void {
			byteArray.writeUTFBytes( value );
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeObject( object : * ) : void {
			byteArray.writeObject( object );
		}
		
	}

}