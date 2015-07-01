package vm.miix.grit.wire 
{
	import vm.miix.grit.emitter.Messenger;
	
	/**
	 * exchange messages with external thread
	 * @author Lis
	 */
	internal interface IMessageExchanger 
	{
		
		/**
		 * resends message from server to client when emitted
		 * @param	address server address
		 * @param	id connection id
		 * @param	messenger messenger to be listened / published
		 * @param	isFromServer true if resends from server and false otherwise
		 * @param	isExternal true if resends message as SERVER
		 */
		function resendExternal( address : Address, id : uint, messenger : Messenger,
				isFromServer : Boolean, isExternal : Boolean ) : void;
		
		
		/**
		 * send command to external thread
		 * @param	command command to be send
		 */
		function sendCommand( command : Command ) : void;
		
	}
	
}