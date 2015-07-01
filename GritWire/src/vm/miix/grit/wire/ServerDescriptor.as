package vm.miix.grit.wire 
{
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	/**
	 * description of server.
	 * @see vm.miix.grit.wire.IContext#registerServer
	 * @author Lis
	 */
	public final class ServerDescriptor implements IExternalizable
	{
		
		private var _address : Address;
		private var _type : String;
		private var _params : *;
		
		
		/**
		 * creates new instance of the server descriptor
		 * @param	address server address
		 * @param	type server type
		 * @param	attr additional connection attributes, depends on server <code>type</code>
		 */
		public function ServerDescriptor( address : Address = null, type : String = "", attr : * = undefined ) {
			if ( address ) _address = address.clone();
			_type = type;
			_params = attr;
		}
		
		/**
		 * server address
		 */
		public function get address() : Address { return _address; }
		
		/**
		 * type of the server.
		 * @see vm.miix.grit.wire.ServerTypes
		 */
		public function get type() : String { return _type; }
		
		/**
		 * additional connection attributes.
		 * Depends on server <code>type</code>
		 */
		public function get attributes() : * { return _params; }
		
		
		
		/* INTERFACE flash.utils.IExternalizable */
		
		/**
		 * @inheritDoc
		 */
		public function readExternal( input : IDataInput ) : void {
			_address = new Address( input.readUTF(), input.readUnsignedInt() );
			_type = input.readUTF();
			_params = input.readObject();
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeExternal( output : IDataOutput ) : void {
			if ( _address ) {
				output.writeUTF( _address.host );
				output.writeUnsignedInt( _address.port );
			}
			else {
				output.writeUTF( "" );
				output.writeUnsignedInt( 0 );
			}
			output.writeUTF( _type );
			output.writeObject( _params );
		}
		
	}

}