package gritTest 
{
	import flash.geom.Point;
	
	/**
	 * cube definition.
	 * sends to / from secondary task as data exchange
	 * @author Lis
	 */
	public class Cube 
	{
		// shape index
		public var index : int;
		
		// x-coordinate
		public var x : Number;
		
		// y-coordinate
		public var y : Number;
		
		
		public function Cube( index : int = 0, x : Number = 0, y : Number = 0 ) {
			this.index = index;
			this.x = x;
			this.y = y;
		}
		
		public function clone() : Cube {
			return new Cube( index, x, y );
		}
		
	}

}