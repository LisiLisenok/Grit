package vm.miix.grit.wire 
{
	import vm.miix.grit.promise.IPromise;
	
	/**
	 * manages tasks within some context
	 * @author Lis
	 */
	internal interface ITaskManager 
	{
		
		/**
		 * deploy external task
		 * @param	command command with details
		 */
		function deployExternal( command : Command ) : void;
		
		/**
		 * undeploy external task
		 * @param	command command with details
		 */
		function undeployExternal( command : Command ) : void;
		
		/**
		 * deploy new task.
		 * When deploying new instance of the task is created.
		 * Task must implement <code>ITask</code>.
		 * @param	qualifiedClassName full name of class to be instantiated as deployed task.
		 * The class must implement <code>ITask</code>
		 * @param param param send to task on running
		 * @return <code>promise</code>, which is resolved with <code>IRegistration</code>,
		 * when task is successfully deployed or with error reason if some error has been occured
		 * @see vm.miix.grit.wire.ITask
		 * @see vm.miix.grit.wire.IRegistration
		 * @see vm.miix.grit.wire.IContext
		 * @see flash.utils.getQualifiedClassName
		 */
		function deploy( qualifiedClassName : String, param : * = undefined ) : IPromise;
		
		
	}
	
}