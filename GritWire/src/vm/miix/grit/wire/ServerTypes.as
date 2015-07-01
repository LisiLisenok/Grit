package vm.miix.grit.wire 
{
	/**
	 * static constants with server types.
	 * <p><ul>
	 * <li><code>INTERNAL</code>, which is used to connect within this swf-file</li>
	 * </ul></p>
	 * @author Lis
	 */
	public final class ServerTypes 
	{
		
		public static const INTERNAL : String = "internalServer";
		
		
		public function ServerTypes() {
			throw new Error( WireErrorMessages.CONSTANTS_INSTANTIATION );
		}
		
	}

}