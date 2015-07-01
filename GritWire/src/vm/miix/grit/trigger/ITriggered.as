package vm.miix.grit.trigger 
{
	
	/**
	 * trigerred item.
	 * Can be in one of two states - active or inactive. Inactive item may not take any actions with this or
	 * perform any operations.
	 * Can be canceled. For example, removed from a collection or cancel performing some operation
	 * @author Lis
	 */
	public interface ITriggered 
	{
		/**
		 * cancel this triggered
		 */
		function cancel() : void;
		
		/**
		 * set this triggered into active state
		 */
		function activate() : void;
		
		/**
		 * set this triggered into inactive state
		 */
		function deactivate() : void;
		
	}
	
}