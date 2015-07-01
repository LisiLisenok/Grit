package vm.miix.grit.wire 
{
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	/**
	 * context commands:
		 * connect to server
		 * register / unregister server
		 * deploy / undeploy task
	 * @author Lis
	 */
	internal class Command implements IExternalizable 
	{
		
		internal static const NOTHING : String = "nothing";
		
		// new connection
		internal static const CONNECT : String = "connect";
		internal static const CONNECT_SERVER : String = "connectServer";
		
		// register / unregister server
		internal static const REGISTER_SERVER : String = "registerServer";
		internal static const UNREGISTER_SERVER : String = "unregisterServer";
		
		// deploy / undeploy task
		internal static const DEPLOY_TASK : String = "deployTask";
		internal static const UNDEPLOY_TASK : String = "undeployTask";
		
		// messaging - message / error/ complete (close) connection
		internal static const MESSAGE : String = "message";
		internal static const ERROR_GRIT : String = "errorGrit";
		internal static const ERROR_CLIENT : String = "errorClient";
		internal static const COMPLETE : String = "complete";
		
		// messaging to / from external server - message / error/ complete (close) connection
		internal static const MESSAGE_SERVER : String = "messageServer";
		internal static const ERROR_SERVER : String = "errorServer";
		
		// shared bytes
		internal static const SHARED_CREATE : String = "sharedCreate";
		internal static const SHARED_REMOVE : String = "sharedRemove";
		internal static const SHARED_CHECKIN : String = "sharedCheckIn";
		internal static const SHARED_CHECKINREJECT : String = "sharedCheckInReject";
		internal static const SHARED_CHECKOUT : String = "sharedCheckOut";
		
		
		
		private var _command : String = NOTHING;
		
		// address message send to / from
		private var _address : Address;
				
		// id of connection
		private var _connectionID : uint;
		
		// true if from server to client and false otherwise
		private var _isFromServer : Boolean;
		
		// message body - must be serializable in AMF3
		private var _body : *;
		
		
		public function Command(
				command : String = NOTHING,
				host : String = "",
				port : uint = 0,
				id : uint = 0,
				isFromServer : Boolean = false,
				body : * = undefined
			)
		{
			_command = command;
			_address = new Address( host, port );
			_connectionID = id;
			_isFromServer = isFromServer;
			_body = body;
		}
		
		
		/**
		 * command id
		 */
		internal function get command() : String { return _command; }
		
		/**
		 * address message send to / from
		 */
		internal function get address() : Address { return _address; }
		
		/**
		 * id of the connection message is for
		 */
		internal function get connectionID() : uint { return _connectionID; }
		
		/**
		 * <code>true</code> if message is from server and <code>false</code> otherwise
		 */
		internal function get isFromServer() : Boolean { return _isFromServer; }
		
		/**
		 * message body
		 */
		internal function get body() : * { return _body; }
		
		
		/* INTERFACE flash.utils.IExternalizable */
		
		/**
		 * @inheritDoc
		 */
		public function readExternal( input : IDataInput ) : void {
			_command = input.readUTF();
			_address = new Address( input.readUTF(), input.readUnsignedInt() );
			_connectionID = input.readUnsignedInt();
			_isFromServer = input.readBoolean();
			_body = input.readObject();
		}
		
		/**
		 * @inheritDoc
		 */
		public function writeExternal( output : IDataOutput ) : void {
			output.writeUTF( command );
			output.writeUTF( address.host );
			output.writeUnsignedInt( address.port );
			output.writeUnsignedInt( connectionID );
			output.writeBoolean( isFromServer );
			output.writeObject( body );
		}
		
	}

}