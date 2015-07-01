package vm.miix.grit.wire 
{
	import vm.miix.grit.emitter.IPublisher;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.trigger.IRegistration;
	
	/**
	 * represents a server
	 * @author Lis
	 */
	internal interface IServer extends IRegistration
	{
		/**
		 * establish connection with server
		 * @param	socket is <code>IPublisher</code> to send to socket
		 * @return <code>promise</code>, which resolved with <code>Connection</code> when connection is successfully  established
		 * or with error reason if some error has been occured
		 * @see vm.miix.grit.emitter.IPublisher
		 * @see vm.miix.grit.wire.Connection
		 */
		function connect() : IPromise;
		
		/**
		 * client socket publisher of connection with id <code>id</code>
		 * @param	id
		 * @return client publisher of connection with id <code>id</code>
		 */
		function clientSocket( id : uint ) : IPublisher;
		
		/**
		 * server socket publisher of connection with id <code>id</code>
		 * @param	id
		 * @return server publisher of connection with id <code>id</code>
		 */
		function serverSocket( id : uint ) : IPublisher;
		
	}
	
}