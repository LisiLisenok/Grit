package vm.miix.grit.task.image 
{
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathWinding;
	import flash.display.GraphicsSolidFill;
	import flash.display.IGraphicsData;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	/**
	 * contains static methods to read / write graphics data into <code>ByteArray</code>.
	 * supports:
		 * <ul>
		 * <code>GraphicsSolidFill</code>
		 * <code>GraphicsEndFill</code>
		 * <code>GraphicsPath</code>
		 * </ul>
	 * @see flash.utils.ByteArray
	 * @see flash.display.IGraphicsData
	 * @author Lis
	 */
	public class GraphicsIO 
	{
		
		// grapics data types
		private static const GRAPHICS_EMPTY : int =		0;
		private static const GRAPHICS_SOLID : int =		1;
		private static const GRAPHICS_END : int =		2;
		private static const GRAPHICS_PATH : int =		3;
		
		
		/**
		 * store vector of vector into a one vector.
		 * @param	items items to be stored into vector
		 * @return vector contains the same graphics data as <code>items</code>
		 */
		public static function graphicItemsToVector( items : Vector.<Vector.<IGraphicsData>> ) : Vector.<IGraphicsData> {
			var ret : Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			for each ( var item : Vector.<IGraphicsData> in items ) {
				for each ( var grData : IGraphicsData in item ) {
					if ( grData is GraphicsSolidFill || grData is GraphicsEndFill || grData is GraphicsPath ) {
						ret.push( grData );
					}
				}
			}
			return ret;
		}
		
		
		/**
		 * store graphics data into output stream
		 * @param	data data to be stored
		 * @param	output stream to be stored in
		 */
		public static function writeGraphicData( data : Vector.<IGraphicsData>, output : IDataOutput ) : void {
			output.writeInt( data.length );
			for each ( var grData : IGraphicsData in data ) {
				if ( grData is GraphicsSolidFill ) {
					output.writeByte( GRAPHICS_SOLID );
					var grSolid : GraphicsSolidFill = grData as GraphicsSolidFill;
					output.writeUnsignedInt( grSolid.color );
					output.writeDouble( grSolid.alpha );
				}
				else if ( grData is GraphicsEndFill ) {
					output.writeByte( GRAPHICS_END );
				}
				else if ( grData is GraphicsPath ) {
					output.writeByte( GRAPHICS_PATH );
					var grPath : GraphicsPath = grData as GraphicsPath;
					output.writeObject( grPath.commands );
					output.writeObject( grPath.data );
					if ( grPath.winding == GraphicsPathWinding.EVEN_ODD ) output.writeByte( 0 );
					else output.writeByte( 1 );
				}
				else output.writeByte( GRAPHICS_EMPTY );
			}
		}
		
		
		/**
		 * read graphics data from input stream
		 * @param	input stream to be read from
		 * @return read graphics data
		 */
		public static function readGraphicData( input : IDataInput ) : Vector.<IGraphicsData> {
			var items : Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			try {
				var size : int = input.readInt();
				for ( var i : int = 0; i < size; i ++ ) {
					var type : int = input.readByte();
					switch ( type ) {
							
						case GRAPHICS_SOLID:
							items.push( new GraphicsSolidFill( input.readUnsignedInt(), input.readDouble() ) );
							break;
							
						case GRAPHICS_END:
							items.push( new GraphicsEndFill() );
							break;
							
						case GRAPHICS_PATH:
							var grPath : GraphicsPath = new GraphicsPath( Vector.<int>( input.readObject() ),
									Vector.<Number>( input.readObject() ) );
							if ( input.readByte() == 0 ) grPath.winding = GraphicsPathWinding.EVEN_ODD;
							else grPath.winding = GraphicsPathWinding.NON_ZERO;
							items.push( grPath );
							break;
					}
				}
			}
			catch ( err : Error ) {
				items.splice( 0, items.length );
			}
			return items;
		}
		
		
		/**
		 * store vector of vector as a one vector (to be read using <code>readGraphicData</code>)
		 * @param	items items to be stored
		 * @param	output stream to be stored in
		 * @see #readGraphicData
		 */
		[inline] public static function writeGraphicItemsAsVector( items : Vector.<Vector.<IGraphicsData>>, output : IDataOutput ) : void {
			writeGraphicData( graphicItemsToVector( items ), output );
		}
		
		
		/**
		 * write graphics data to output stream
		 * @param	items items to be written
		 * @param	output output stream
		 */
		public static function writeGraphicItems( items : Vector.<Vector.<IGraphicsData>>, output : IDataOutput ) : void {
			output.writeInt( items.length );
			for each ( var item : Vector.<IGraphicsData> in items ) {
				output.writeInt( item.length );
				for each ( var grData : IGraphicsData in item ) {
					if ( grData is GraphicsSolidFill ) {
						output.writeByte( GRAPHICS_SOLID );
						var grSolid : GraphicsSolidFill = grData as GraphicsSolidFill;
						output.writeUnsignedInt( grSolid.color );
						output.writeDouble( grSolid.alpha );
					}
					else if ( grData is GraphicsEndFill ) {
						output.writeByte( GRAPHICS_END );
					}
					else if ( grData is GraphicsPath ) {
						output.writeByte( GRAPHICS_PATH );
						var grPath : GraphicsPath = grData as GraphicsPath;
						output.writeObject( grPath.commands );
						output.writeObject( grPath.data );
						if ( grPath.winding == GraphicsPathWinding.EVEN_ODD ) output.writeByte( 0 );
						else output.writeByte( 1 );
					}
					else output.writeByte( GRAPHICS_EMPTY );
				}
			}
		}
		
		/**
		 * read graphics data from input stream
		 * @param	input stream to be read from
		 * @return graphics data
		 */
		public static function readGraphicItems( input : IDataInput ) : Vector.<Vector.<IGraphicsData>> {
			var items : Vector.<Vector.<IGraphicsData>> = new Vector.<Vector.<IGraphicsData>>();
			try {
				var size : int = input.readInt();
				for ( var i : int = 0; i < size; i ++ ) {
					var item : Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
					var grSize : int = input.readInt();
					for ( var j : int = 0; j < grSize; j ++ ) {
						var type : int = input.readByte();
						switch ( type ) {
							
							case GRAPHICS_SOLID:
								item.push( new GraphicsSolidFill( input.readUnsignedInt(), input.readDouble() ) );
								break;
							
							case GRAPHICS_END:
								item.push( new GraphicsEndFill() );
								break;
							
							case GRAPHICS_PATH:
								var grPath : GraphicsPath = new GraphicsPath( Vector.<int>( input.readObject() ),
									Vector.<Number>( input.readObject() ) );
								if ( input.readByte() == 0 ) grPath.winding = GraphicsPathWinding.EVEN_ODD;
								else grPath.winding = GraphicsPathWinding.NON_ZERO;
								item.push( grPath );
								break;
						}
					}
					if ( item.length > 0 ) items.push( item );
				}
			}
			catch ( err : Error ) {
				items.splice( 0, items.length );
			}
			return items;
		}

		
		
		
		public function GraphicsIO() {
			
		}
		
	}

}