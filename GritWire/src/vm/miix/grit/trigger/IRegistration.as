package vm.miix.grit.trigger 
{
	
	/**
	 * registration interface - allows registration canceling
	 * @author Lis
	 */
	public interface IRegistration 
	{
		/**
		 * cancel this registration
		 */
		function cancel() : void;
	}
	
}