package vm.miix.grit.wire 
{
	import vm.miix.grit.promise.IPromise;
	
	/**
	 * manage connections
	 * @author Lis
	 */
	internal interface IConnectionManager 
	{
		
		/**
		 * connect to external server
		 * @param	command command with details
		 */
		function connectExternal( command : Command ) : void;
		
		/**
		 * establish connection to external server
		 * @param	command command with details
		 */
		function connectServerExternal( command : Command ) : void;
		
		/**
		 * register external server
		 * @param	command command with details
		 */
		function registerExternal( command : Command ) : void;
		
		/**
		 * unregister external server
		 * @param	command command with details
		 */
		function unregisterExternal( command : Command ) : void;
	
		/**
		 * send message to server or client
		 * @param	command command with details
		 */
		function messageExternal( command : Command ) : void;
		
		/**
		 * notify server or client about an error
		 * @param	command command with details
		 */
		function errorClientExternal( command : Command ) : void;
		
		/**
		 * server connection error
		 * @param	command command with details
		 */
		function errorGritExternal( command : Command ) : void;
		
		/**
		 * complete connection
		 * @param	command command with details
		 */
		function completeExternal( command : Command ) : void;
		
		/**
		 * send message to external server or client
		 * @param	command command with details
		 */
		function messageServer( command : Command ) : void ;
		
		/**
		 * notify external server or client about an error
		 * @param	command command with details
		 */
		function errorServer( command : Command ) : void;
		
		
		
		/**
		 * register server which listens to address <code>address</code>.
		 * When new connection is established <code>onConnected</code> is called
		 * @param	descriptor server descriptor, which is server address, server type and connection attributes
		 * @param	onConnected callback called when new connection is established
		 * <listing version="3.0"> function onConnected( socket : Messenger ) : void; </listing>
		 * @return <code>promise</code>, which is resolved with <code>IRegistration</code>,
		 * when server is successfully registered or with error reason if some error has been occured.
		 * If this registration is canceled, all currently opened connections are closed.
		 * @see vm.miix.grit.wire.ServerDescriptor
		 * @see vm.miix.grit.wire.IRegistration
		 * @see vm.miix.grit.wire.IContext
		 * @see vm.miix.grit.emitter.Messenger
		 */
		function registerServer( descriptor : ServerDescriptor, onConnected : Function ) : IPromise;
		
		/**
		 * connect to a server with address <code>address</code>.
		 * Server must be registered using <code>registerServer</code> before connecting to it
		 * @param	address server address to be connected to
		 * @return <code>promise</code>, which resolved with <code>Messenger</code> when connection is successfully  established
		 * or with error reason if some error has been occured.
		 * To close connection call <code>Messenger.publisher.complete()</code>.
		 * @see vm.miix.grit.emitter.Messenger
		 * @see vm.miix.grit.wire.IContext
		 */
		function connect( address : Address ) : IPromise;
		
		
	}
	
}