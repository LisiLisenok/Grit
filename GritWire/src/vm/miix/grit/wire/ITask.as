package vm.miix.grit.wire 
{
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.trigger.IRegistration;
	
	/**
	 * task runnable on a context
	 * @author Lis
	 */
	public interface ITask 
	{
		/**
		 * run task on context <code>context</code>.
		 * When task is completed all servers, connections and shared bytes opened within this task are closed
		 * @param	context context task is to be run
		 * @param	registration <code>IRegistration</code> to complete this task
		 * @param	param param send to task
		 * @return	promise, which must be resolvedwhen task is started, or rejected if some errors.
		 * Using this promise task can take some time to starting (register servers or extablish connections).
		 * Can return null, which means the task is started immediately
		 */
		function run( context : IContext, registration : IRegistration, param : * ) : IPromise;
	}
	
}