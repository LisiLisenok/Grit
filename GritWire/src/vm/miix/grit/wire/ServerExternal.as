package vm.miix.grit.wire 
{
	/**
	 * external (another thread) server
	 * @author Lis
	 */
	internal class ServerExternal extends ServerBase 
	{
		
		/**
		 * exchnging messages with external thread
		 */
		private var exchanger : IMessageExchanger;
		
		
		public function ServerExternal( address : Address, exchanger : IMessageExchanger ) {
			this.exchanger = exchanger;
			super( address );
		}
		
		
		/**
		 * @inheritDoc
		 */
		override internal function establishConnection( connection : Connection ) : void {
			exchanger.resendExternal( connection.address, connection.id, connection.server, false, true );
			exchanger.sendCommand( new Command( Command.CONNECT_SERVER, connection.address.host, connection.address.port, connection.id, true ) );
		}
		
		
	}

}