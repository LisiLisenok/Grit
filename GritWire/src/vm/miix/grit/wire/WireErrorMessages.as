package vm.miix.grit.wire 
{
	/**
	 * error messages
	 * @author Lis
	 */
	internal class WireErrorMessages extends Error 
	{
		
		internal static const CONSTANTS_INSTANTIATION : String = "don't instantiate class with constants description";
		
		internal static const SERVER_UNTYPED : String = "incorrect server type at address";
		
		internal static const SERVER_NOTFOUND : String = "can't connect to";
		
		internal static const SERVER_EXISTS : String = "server has been registered early";
		
		internal static const GRITWIRE_NOTSTARTED : String = "GritWire hasn't been started";
		
		internal static const TASK_COMPLETED : String = "task has been completed";
		
		internal static const TASK_NOTRUNNABLE : String = "task must satisfy ITask interface";
		
		internal static const SHARED_NOTEXISTS : String = "shared property doesn't exist";
		
		internal static const SHARED_ALREADYEXISTS : String = "shared property has been already creted";
		
		internal static const SHARED_REMOVEDBYOWNER : String = "shared property has been removed by owner";
		
		
		
		public function WireErrorMessages() {
		}
		
		
		internal static function withAddress( message : String, address : Address ) : String { return message + " " + String( address ); }
		
	}

}