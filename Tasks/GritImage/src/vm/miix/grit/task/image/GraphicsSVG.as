package vm.miix.grit.task.image 
{
	import flash.display.GradientType;
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsGradientFill;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	import flash.utils.getQualifiedClassName;
	import vm.miix.grit.collection.Comparison;
	import vm.miix.grit.collection.FunctionMapSet;
	
	/**
	 * generates svg from graphics commands.
	 * <ul>
	 * <li>call <code>clear()</code> to start new draw (called from constructor)</li>
	 * <li>call <code>offset()</code> if some offset to be added to coordinates</li>
	 * <li>call <code>drawGraphicsData()</code> to draw graphics data into svg</li>
	 * <li>call <code>finalizeDraw()</code> to complete drawing</li>
	 * </ul>
	 * @author Lis
	 */
	public class GraphicsSVG
	{
		private static const s : Namespace = new Namespace( "s", "http://www.w3.org/2000/svg" );
		private static const xlink : Namespace = new Namespace( "xlink", "http://www.w3.org/1999/xlink" );
		
		private static const COMMAND_MOVE : String = "M";
		private static const COMMAND_LINE : String = "L";
		private static const COMMAND_CURVE : String = "Q";

		
		private var svg : XML;
		private var path : XML;
		private var lastGradientID : uint = 0;
		
		private var currentDrawCommand : String = "";
		private var pathData : String;
		
		private var offsetX : Number;
		private var offsetY : Number;
		
		private var drawers : FunctionMapSet = new FunctionMapSet( Comparison.stringIncreasing );
		
		
		public function GraphicsSVG() {
			drawers.add( getQualifiedClassName( GraphicsSolidFill ), drawSolidFill );
			drawers.add( getQualifiedClassName( GraphicsGradientFill ), drawGradientFill );
			drawers.add( getQualifiedClassName( GraphicsEndFill ), drawEndFill );
			drawers.add( getQualifiedClassName( GraphicsStroke ), drawStroke );
			drawers.add( getQualifiedClassName( GraphicsPath ), drawPath );
			
			clear();
		}
		
		
		
		private function finalizePath() : void {
			if( path && pathData != "" ) {
				path.@d = pathData;
				svg.s::g.appendChild( path );
			}
			path = <path />;
			pathData = "";
			currentDrawCommand = "";
		}

		
		private function populateGradientElement( gradient : XML, type : String, colors : Array, alphas : Array,
				ratios : Array, matrix : Matrix, spreadMethod : String, interpolationMethod : String,
				focalPointRatio : Number ) : void
		{
			gradient.@gradientUnits = "objectBoundingBox";
			if( type == GradientType.LINEAR ) {
				gradient.@x1 = "0%";
				gradient.@x2 = "100%";
			}
			else {
				gradient.@r = "100%";
				gradient.@cx = 0;
				gradient.@cy = 0;
				if( focalPointRatio != 0 ) {
					gradient.@fx = ( 100 * focalPointRatio ).toString() + "%";
					gradient.@fy = 0;
				}
			}
			if( spreadMethod != SpreadMethod.PAD ) { gradient.@spreadMethod = spreadMethod; }
			switch( spreadMethod ) {
				case SpreadMethod.PAD: gradient.@spreadMethod = "pad"; break;
				case SpreadMethod.REFLECT: gradient.@spreadMethod = "reflect"; break;
				case SpreadMethod.REPEAT: gradient.@spreadMethod = "repeat"; break;
			}
			if( interpolationMethod == InterpolationMethod.LINEAR_RGB ) { gradient.@["color-interpolation"] = "linearRGB"; }
			if( matrix ) {
				var gradientValues : Array = [1, matrix.c, matrix.b, 1, matrix.tx, matrix.ty];
				gradient.@gradientTransform = "matrix(" + gradientValues.join(",") + ")";
			}
			for( var i : uint = 0; i < colors.length; i++ ) {
				var gradientEntry : XML = <stop offset={ratios[i] / 255} />
				var color : uint = colors[i] as uint;
				if( color != 0 ) { gradientEntry.@["stop-color"] = rgbToString( color ); }
				if( alphas[i] != 1 ) { gradientEntry.@["stop-opacity"] = roundPixels( alphas[i] ); }
				gradient.appendChild( gradientEntry );
			}
		}
		
		
		/* drwing API */
		
		[inline] private static function roundPixels( pos : Number ) : Number {
			var nPos : int = pos * 100;
			return nPos / 100;
		}
		
		private static function rgbToString( color : uint ) : String {
			
			// red
			var red : uint = ( color >> 16 ) & 0xFF;
			var strRed : String = red.toString( 16 );
			var nLen : int = strRed.length;
			if ( nLen == 1 ) strRed = "0" + strRed;
			
			// green
			var green : uint = ( color >> 8 ) & 0xFF;
			var strGreen : String = green.toString( 16 );
			nLen = strGreen.length;
			if ( nLen == 1 ) strGreen = "0" + strGreen;
			
			// blue
			var blue : uint = color & 0xFF;
			var strBlue : String = blue.toString( 16 );
			nLen = strBlue.length;
			if ( nLen == 1 ) strBlue = "0" + strBlue;
			
			return "#" + strRed + strGreen + strBlue;
		}
		
		
		private function moveTo( x : Number, y : Number ) : void {
			currentDrawCommand = "";
			pathData += COMMAND_MOVE + roundPixels( x + offsetX ) + " " + roundPixels( y + offsetY ) + " ";
		}
		
		private function lineTo( x : Number, y : Number) : void {
			if( currentDrawCommand != COMMAND_LINE ) {
				currentDrawCommand = COMMAND_LINE;
				pathData += COMMAND_LINE;
			}
			pathData += roundPixels( x + offsetX ) + " " + roundPixels( y + offsetY ) + " ";
		}
		
		private function curveTo( controlX : Number, controlY : Number, anchorX : Number, anchorY : Number ) : void {
			if( currentDrawCommand != COMMAND_CURVE ) {
				currentDrawCommand = COMMAND_CURVE;
				pathData += COMMAND_CURVE;
			}
			pathData += 
				roundPixels( controlX + offsetX ) + " " + 
				roundPixels( controlY + offsetY ) + " " + 
				roundPixels( anchorX + offsetX ) + " " + 
				roundPixels( anchorY + offsetY ) + " ";
		}
		
		private function drawSolidFill( fill : GraphicsSolidFill ) : void {
			finalizePath();
			path.@stroke = "none";
			path.@fill = rgbToString( fill.color );
			if ( fill.alpha != 1 ) { path.@["fill-opacity"] = roundPixels( fill.alpha ); }
			path.@["fill-rule"] = "nonzero";
		}
		
		private function drawGradientFill( fill : GraphicsGradientFill ) : void {
			finalizePath();
			var gradient : XML = ( fill.type == GradientType.LINEAR ) ? <linearGradient /> : <radialGradient />;
			populateGradientElement( gradient, fill.type, fill.colors, fill.alphas, fill.ratios,
					fill.matrix, fill.spreadMethod, fill.interpolationMethod, fill.focalPointRatio );
			var id : int = lastGradientID ++;
			gradient.@id = "gradient" + id;
			path.@stroke = "none";
			path.@fill = "url(#gradient" + id + ")";
			path.@["fill-rule"] = "nonzero";
			svg.s::defs.appendChild( gradient );
		}
		
		private function drawEndFill( fill : GraphicsEndFill ) : void {
			finalizePath();
		}
		
		private function drawStroke( stroke : GraphicsStroke ) : void {
			finalizePath();
			if ( stroke.fill is GraphicsSolidFill ) {
				path.@fill = "none";
				path.@["stroke-width"] = isNaN( stroke.thickness ) ? 1 : roundPixels( stroke.thickness );
				var fill : GraphicsSolidFill = stroke.fill as GraphicsSolidFill;
				path.@stroke = rgbToString( fill.color );
				if( fill.alpha != 1 ) { path.@["stroke-opacity"] = roundPixels( fill.alpha ); }
				path.@["stroke-linecap"] = "round";
				path.@["stroke-linejoin"] = "round";
			}
			else if ( stroke.fill is GraphicsGradientFill ) {
				path.@fill = "none";
				path.@["stroke-width"] = isNaN( stroke.thickness ) ? 1 : roundPixels( stroke.thickness );
				var fillGradient : GraphicsGradientFill = stroke.fill as GraphicsGradientFill;
				var gradient : XML = ( fillGradient.type == GradientType.LINEAR ) ? <linearGradient /> : <radialGradient />;
				populateGradientElement( gradient, fillGradient.type, fillGradient.colors, fillGradient.alphas,
						fillGradient.ratios, fillGradient.matrix, fillGradient.spreadMethod,
						fillGradient.interpolationMethod, fillGradient.focalPointRatio );
				var id : int = lastGradientID ++;
				gradient.@id = "gradient" + id;
				path.@stroke = "url(#gradient" + id + ")";
				svg.s::defs.appendChild( gradient );
			}
			
		}
		
		private function drawPath( path : GraphicsPath ) : void {
			var dataIndex : int = 0;
			for each ( var command : int in path.commands ) {
				switch ( command ) {
					case GraphicsPathCommand.MOVE_TO:
						moveTo( path.data[dataIndex ++], path.data[dataIndex ++] );
						break;
					
					case GraphicsPathCommand.WIDE_MOVE_TO:
						moveTo( path.data[dataIndex ++], path.data[dataIndex ++] );
						dataIndex += 2;
						break;
						
					case GraphicsPathCommand.LINE_TO:
						lineTo( path.data[dataIndex ++], path.data[dataIndex ++] );
						break;
						
					case GraphicsPathCommand.WIDE_LINE_TO:
						lineTo( path.data[dataIndex ++], path.data[dataIndex ++] );
						dataIndex += 2;
						break;
						
					case GraphicsPathCommand.CURVE_TO:
						curveTo( path.data[dataIndex ++], path.data[dataIndex ++],
								path.data[dataIndex ++], path.data[dataIndex ++] );
						break;
						
					case GraphicsPathCommand.CUBIC_CURVE_TO:
						// cubic curve is not supported
						dataIndex += 6;
						break;
				}
			}
		}
		
		
		
		/**
		 * apply offset, so all graphics data will be shifted on offset
		 * @param	x offset by x-coordinate
		 * @param	y offset by y-coordinate
		 */
		public function offset( x : Number = 0, y : Number = 0 ) : void {
			offsetX = x;
			offsetY = y;
		}
		
		/**
		 * finalizes drawing operations and returns XML with svg data
		 * @return XML with svg data
		 * @see #drawGraphicsData
		 */
		public function finalizeDraw() : XML {
			finalizePath();
			return svg;
		}
		
		
		/* INTERFACE vm.miix.app.paint.tool.IGraphics */
		
		/**
		 * @inheritDoc
		 * generates svg xml data from graphics data.
		 * supports following data:
			 * <ul>
			 * <li><code>GraphicsSolidFill</code></li>
			 * <li><code>GraphicsGradientFill</code></li>
			 * <li><code>GraphicsEndFill</code></li>
			 * <li><code>GraphicsStroke</code></li>
			 * <li><code>GraphicsPath</code> with following commands:
				 * <ul>
				 * <li><code>GraphicsPathCommand.MOVE_TO</code></li>
				 * <li><code>GraphicsPathCommand.LINE_TO</code></li>
				 * <li><code>GraphicsPathCommand.CURVE_TO</code></li>
				 * </ul>
			 * </li>
			 * </ul>
		 * @see flash.display.IGraphicsData
		 * @see flash.display.GraphicsSolidFill
		 * @see flash.display.GraphicsGradientFill
		 * @see flash.display.GraphicsEndFill
		 * @see flash.display.GraphicsStroke
		 * @see flash.display.GraphicsPath
		 * @see flash.display.GraphicsPathCommand
		 */
		public function drawGraphicsData( data : Vector.<IGraphicsData> ) : void {
			for each ( var gr : IGraphicsData in data ) {
				drawers.invoke( getQualifiedClassName( gr ), gr );
			}
		}
		
		/**
		 * @inheritDoc
		 * starts new svg drawing
		 */
		public function clear() : void {
			svg = <svg xmlns={s.uri} xmlns:xlink={xlink.uri}><defs /><g /></svg>;
		}
		
	}

}