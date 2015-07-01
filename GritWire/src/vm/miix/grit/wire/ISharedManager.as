package vm.miix.grit.wire 
{
	import vm.miix.grit.promise.IPromise;
	
	/**
	 * manages sharedbytes within a context
	 * @see vm.miix.grit.wire.ISharedBytes
	 * @see vm.miix.grit.wire.IRegistration
	 * @author Lis
	 */
	internal interface ISharedManager 
	{
		
		/**
		 * external thread asks to create shared bytes
		 * @param	command related command
		 */
		function createSharedExternal( command : Command ) : void;
		
		/**
		 * external thread asks to remove shared bytes
		 * @param	command related command
		 */
		function removeSharedExternal( command : Command ) : void;
		
		/**
		 * external thread asks to check in shared bytes
		 * @param	command related command
		 */
		function checkInExternal( command : Command ) : void;
		
		/**
		 * external thread says that some error occured during check in
		 * @param	command related command
		 */
		function checkInRejectExternal( command : Command ) : void;
		
		/**
		 * external thread asks to check out shared bytes
		 * @param	command related command
		 */
		function checkOutExternal( command : Command ) : void;
		
		
		
		/**
		 * create new shared bytes with name <code>name</code>
		 * @param	name name of created shared bytes to reference on
		 * @return promise on <code>IRegistration</code> to remove this shared bytes
		 */
		function createSharedBytes( name : String ) : IPromise;
		
		/**
		 * check in shared bytes with name <code>name</code>.
		 * After check in only recipient has access to the shared bytes.
		 * After read / write operations recipient must call checkOut
		 * @param	name name of shared bytes to be check in
		 * @return promise on <code>ISharedBytes</code>, which will be resolved when all previously check out's
		 * are check in'ed
		 */
		function checkInSharedBytes( name : String ) : IPromise;
		
	}
	
}