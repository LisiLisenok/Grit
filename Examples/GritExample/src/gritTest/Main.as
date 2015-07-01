package gritTest
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.registerClassAlias;
	import flash.system.Worker;
	import flash.utils.getQualifiedClassName;
	import vm.miix.grit.emitter.EmitterFactory;
	import vm.miix.grit.emitter.IEmitter;
	import vm.miix.grit.emitter.Messenger;
	import vm.miix.grit.wire.Address;
	import vm.miix.grit.wire.GritTask;
	import vm.miix.grit.wire.GritWire;
	import vm.miix.grit.wire.IContext;
	
	
	/**
	 * example of Grit.
	 * Randomly moving shapes. Position of sprites is calculated in secondary thread.
	 * Only one shape is moved as new frame entered.
	 * @author Lis
	 */
	public class Main extends Sprite 
	{
		
		// grit context
		private var wireContext : IContext;
		
		// shapes to be moved
		private var cubes : Vector.<Shape> = new Vector.<Shape>();
		
		// emits with ENTER_FRAME event (to perform shapes position update)
		private var emitter : IEmitter;
		
		
		public function Main() {
			
			// register class with data to be send from / to secondary context
			registerClassAlias( "gritTest.Cube", Cube );
			
			// run grit
			if ( Worker.current.isPrimordial ) {
				if ( stage ) init();
				else addEventListener( Event.ADDED_TO_STAGE, init );
			}
			else {
				// secondary thread - just create grit task and store reference on it
				wireContext = new GritTask();
			}
			
		}
		
		private function init( e : Event = null ) : void {
			
			removeEventListener( Event.ADDED_TO_STAGE, init );
			// entry point
			
			// create shapes
			setupCubes();
			
			// fill full view area
			graphics.beginFill( 0xDDDDDD );
			graphics.drawRect( 0, 0, 800, 600 );
			graphics.endFill();
			
			// start / stop moving when clicked
			stage.addEventListener( MouseEvent.CLICK, onClick );
			
			// start moving
			emitter = EmitterFactory.fromEvents( this, Event.ENTER_FRAME );
			
			// start grit
			var wire : GritWire = new GritWire();
			wireContext = wire;
			wire.start( loaderInfo.bytes ).onCompleted (
				started,
				function ( reason : * ) : void { trace( reason ); }
			);
			
		}
		
		// start / stop moving with click
		private function onClick( e : Event = null ) : void {
			if ( emitter ) {
				// stop moving
				emitter.cancel();
				emitter = null;
			}
			else {
				// start moving
				emitter = EmitterFactory.fromEvents( this, Event.ENTER_FRAME );
				wireContext.connect( new Address( PositionUpdater.updateServer + String( 0.25 ) ) ).onCompleted( updateServer );
				wireContext.connect( new Address( PositionUpdater.updateServer + String( 0.75 ) ) ).onCompleted( updateServer );
			}
		}
		
		// creates shapes to be moved
		private function setupCubes() : void {
			for ( var i : int = 0; i < 20; i ++ ) {
				var s : Shape = new Shape();
				addChild( s );
				var j : int = i % 3;
				var color : int = ( ( ( i * 10 + j * 40 ) * 2 ) << 16 ) | ( ( i * 5 ) << 8 ) | i * 10 + j * 30;
				s.graphics.beginFill( color );
				if ( j == 2 ) s.graphics.drawRect( 0, 0, 20 + i, 20 + i );
				else if ( j == 1 ) s.graphics.drawCircle( 10 + i / 2, 10 + i / 2, 10 + i / 2 );
				else s.graphics.drawRoundRect( 0, 0, 20 + i, 20 + i, 5, 5 );
				s.graphics.endFill();
				s.y = i * ( 20 + i ) + 5;
				s.x = i * ( 30 + i ) + 5;
				cubes[i] = s;
			}
		}
		
		// do moving
		private function updateCube( cube : Cube ) : void {
			cubes[cube.index].x = cube.x;
			cubes[cube.index].y = cube.y;
		}
		
		// listen position updating and move shapes
		private function updateServer( messenger : Messenger ) : void {
			var index : int = 0;
			emitter.subscribe( calcCube, messenger.publisher.complete );
			messenger.emitter.subscribe( updateCube );
			
						
			function calcCube( val : * ) : void {
				// ask secondary task to update position
				messenger.publisher.publish( new Cube( index, cubes[index].x, cubes[index].y ) );
				index ++;
				if ( index > 19 ) index = 0;
			}
			
		}
		
		// grit has been started
		private function started( context : IContext ) : void {
			// deploy tasks calculating shapes position with 2 different params (0.25 and 0.75)
			context.deploy( getQualifiedClassName( PositionUpdater ), 0.25 ).onCompleted(
				function ( val : * ) : void {
					context.connect( new Address( PositionUpdater.updateServer + String( 0.25 ) ) ).onCompleted( updateServer,
						function ( reason : * ) : void { trace( "not connected: ", reason ); } );
				}
			);
			context.deploy( getQualifiedClassName( PositionUpdater ), 0.75 ).onCompleted(
				function ( val : * ) : void {
					context.connect( new Address( PositionUpdater.updateServer + String( 0.75 ) ) ).onCompleted( updateServer,
						function ( reason : * ) : void { trace( "not connected: ", reason ); } );
				}
			);
		}
		
	}
	
}