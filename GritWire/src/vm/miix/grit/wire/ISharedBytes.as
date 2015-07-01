package vm.miix.grit.wire 
{
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	/**
	 * shared bytes - like <code>ByteArray</code> but contains <code>checkOut</code> capability
	 * <ul>
	 * <li>read / write interfacies</li>
	 * <li>read / write position</li>
	 * <li>check out</li>
	 * </ul>
	 * @author Lis
	 */
	public interface ISharedBytes extends IDataInput, IDataOutput
	{
		/**
		 * current read / write position
		 */
		function get position() : uint;
		function set position( pos : uint ) : void;
		
		/**
		 * remove all bytes
		 */
		function clear() : void;
		
		/**
		 * check out this shared bytes.
		 * Next check in is to be done after check out.
		 * After check out any read / write operations on this shared bytes are forbidden.
		 */
		function checkOut() : void;
		
		/**
		 * underlying bytearray
		 */
		function get byteArray() : ByteArray;
		
	}
	
}