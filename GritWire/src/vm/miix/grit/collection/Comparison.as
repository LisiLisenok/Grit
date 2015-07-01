package vm.miix.grit.collection 
{
	/**
	 * comparison static functions.
	 * <p> utility with static functions can be used in sorting and within maps
		<ul>
		<li><code>uintIncreasing</code> - uint by increasing</li>
		<li><code>uintDecreasing</code> - uint by decreasing</li>
		<li><code>intIncreasing</code> - int by increasing</li>
		<li><code>intDecreasing</code> - int by decreasing</li>
		<li><code>numberIncreasing</code> - Number by increasing</li>
		<li><code>numberDecreasing</code> - Number by decreasing</li>
		<li><code>stringIncreasing</code> - String by increasing</li>
		<li><code>stringDecreasing</code> - String by decreasing</li>
		</ul></p>
	 * @see vm.miix.grit.collection.IIterable#sort
	 * @see vm.miix.grit.collection.Map
	 * @author Lis
	 */
	public class Comparison 
	{
		
		public function Comparison() 
		{
			
		}
		
		/**
		 * compare two uint by increasing
		 * @param	first compare item
		 * @param	second compare item
		 * @return -1 if smaller, +1 if larger or 0 if equal
		 */
		public static function uintIncreasing( first : uint, second : uint ) : Number {
			return first - second;
		}
		
		/**
		 * compare two uint by decreasing
		 * @param	first compare item
		 * @param	second compare item
		 * @return -1 if smaller, +1 if larger or 0 if equal
		 */
		public static function uintDecreasing( first : uint, second : uint ) : Number {
			return second - first;
		}
		
		
		/**
		 * compare two int by increasing
		 * @param	first compare item
		 * @param	second compare item
		 * @return -1 if smaller, +1 if larger or 0 if equal
		 */
		public static function intIncreasing( first : int, second : int ) : Number {
			return  first - second;
		}
		
		/**
		 * compare two int by decreasing
		 * @param	first compare item
		 * @param	second compare item
		 * @return -1 if smaller, +1 if larger or 0 if equal
		 */
		public static function intDecreasing( first : int, second : int ) : Number {
			return  second - first;
		}
	
		
		/**
		 * compare two Number by increasing
		 * @param	first compare item
		 * @param	second compare item
		 * @return -1 if smaller, +1 if larger or 0 if equal
		 */
		public static function numberIncreasing( first : Number, second : Number ) : Number {
			return  first - second;
		}
		
		/**
		 * compare two Number by decreasing
		 * @param	first compare item
		 * @param	second compare item
		 * @return -1 if smaller, +1 if larger or 0 if equal
		 */
		public static function numberDecreasing( first : Number, second : Number ) : Number {
			return  second - first;
		}
		
		
		/**
		 * compare two String by increasing
		 * @param	first compare item
		 * @param	second compare item
		 * @return -1 if smaller, +1 if larger or 0 if equal
		 */
		public static function stringIncreasing( first : String, second : String ) : Number {
			return first.localeCompare( second );
		}
		
		/**
		 * compare two String by increasing
		 * @param	first compare item
		 * @param	second compare item
		 * @return -1 if smaller, +1 if larger or 0 if equal
		 */
		public static function stringDecreasing( first : String, second : String ) : Number {
			return second.localeCompare( first );
		}
		
	}

}