package vm.miix.grit.wire 
{
	import vm.miix.grit.promise.IPromise;
	
	/**
	 * grit context, tasks is run on.
	 * <p>
	 * <ul>
	 * <li> registering servers within grit</li>
	 * <li> connecting to registered servers </li>
	 * <li> deploying tasks in thread separated from main </li>
	 * <li> shared bytes management </li>
	 * </ul>
	 * </p>
	 * @author Lis
	 */
	public interface IContext 
	{
		
		/**
		 * register server which listens to address <code>address</code>.
		 * When new connection is established <code>onConnected</code> is called
		 * @param	descriptor server descriptor, which is server address, server type and connection attributes
		 * @param	onConnected callback called when new connection is established
		 * <listing version="3.0"> function onConnected( socket : Messenger ) : void; </listing>
		 * @return <code>promise</code>, which is resolved with <code>IRegistration</code>,
		 * when server is successfully registered or with error reason if some error has been occured.
		 * If this registration is canceled, all connections related to this server are closed.
		 * @see vm.miix.grit.wire.ServerDescriptor
		 * @see vm.miix.grit.wire.IRegistration
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
		 */
		function connect( address : Address ) : IPromise;
		
		
		/**
		 * deploy new task.
		 * <p>When deploying new instance of the task is created</p>
		 * <p>Task must implement <code>ITask</code></p>
		 * <p>When task is completed all servers, connections and shared bytes opened within this task are closed</p>
		 * <p>While all tasks deployed from this task continue to work</p>
		 * @param	qualifiedClassName full name of class to be instantiated as deployed task.
		 * The class must implement <code>ITask</code>
		 * @param param param send to task on running
		 * @return <code>promise</code>, which is resolved with <code>IRegistration</code>,
		 * when task is successfully deployed or with error reason if some error has been occured
		 * @see vm.miix.grit.wire.ITask
		 * @see vm.miix.grit.wire.IRegistration
		 * @see flash.utils.getQualifiedClassName
		 */
		function deploy( qualifiedClassName : String, param : * = undefined ) : IPromise;
		
		
		/**
		 * create new shared bytes with name <code>name</code>
		 * @param	name name of created shared bytes to reference on
		 * @return promise on <code>IRegistration</code> to remove this shared bytes
		 * @see vm.miix.grit.wire.ISharedBytes
		 * @see vm.miix.grit.wire.IRegistration
		 */
		function createSharedBytes( name : String ) : IPromise;
		
		/**
		 * check in shared bytes with name <code>name</code>.
		 * After check in only recipient has access to the shared bytes.
		 * After read / write operations recipient must call <code>ISharedBytes.checkOut()</code>
		 * @param	name name of shared bytes to be check in
		 * @return promise on <code>ISharedBytes</code>, which will be resolved when all previously check out's
		 * are check in'ed
		 * @see vm.miix.grit.wire.ISharedBytes
		 * @see vm.miix.grit.wire.ISharedBytes#checkOut()
		 */
		function checkInSharedBytes( name : String ) : IPromise;
		
	}
	
}