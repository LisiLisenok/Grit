package vm.miix.grit.trigger 
{
	
	import vm.miix.grit.trigger.ITriggered;
	
	/**
	 * <code>trigger</code> - periodical alarming.
	 * Subscribers will be notified on two events:
		 <ul>
		 <li>alarm, submited periodicaly depending on concreate <code>trigger</code></li>
		 <li>complete, submited only once, when trigger completes alarming</li>
		 </ul>
	 <p><code>trigger</code> extends <code>ITriggered</code> interface. So, it can be pasued, resumed or canceled</p>
	 * @author Lis
	 */
	public interface ITrigger extends ITriggered
	{
		/**
		 * subscribe on trigger events
		 * @param	onAlarm alarm event listener, without arguments
		 * <listing version="3.0"> function onAlarm() : void; </listing>
		 * @param	onComplete complete event listener, without arguments
		 * <listing version="3.0"> function onComplete() : void; </listing>
		 */
		function subscribe( onAlarm : Function, onComplete : Function = null ) : ITriggered;
	}
	
}