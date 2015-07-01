package gritTest 
{
	import vm.miix.grit.emitter.Messenger;
	import vm.miix.grit.emitter.PublisherList;
	import vm.miix.grit.promise.IPromise;
	import vm.miix.grit.trigger.IRegistration;
	import vm.miix.grit.trigger.ITriggered;
	import vm.miix.grit.wire.Address;
	import vm.miix.grit.wire.IContext;
	import vm.miix.grit.wire.ITask;
	import vm.miix.grit.wire.ServerDescriptor;
	import vm.miix.grit.wire.ServerTypes;
	
	
	/**
	 * task performed onsecondary thread and calculates shapes position
	 * @author Lis
	 */
	public class PositionUpdater implements ITask 
	{
		
		// server name
		public static const updateServer : String = "updateServer";
		
		// send calculated data
		private var publisher : PublisherList = new PublisherList();
		
		
		// internal constants used in position calculations
		private var adding1 : Number = 0;
		private var adding2 : Number = 0;
		
		
		public function PositionUpdater() {
		}
		
		
		// calculate new position
		private function calcCube( cube : Cube ) : void {
			cube.x += 20 * ( Math.random() * adding1 - Math.random() ) * ( Math.random() - Math.random() * adding2 );
			if ( cube.x > 750 ) cube.x = 1500 - cube.x;
			if ( cube.x < 0 ) cube.x = -cube.x;
			cube.y += 20 * ( Math.random() * adding2 - Math.random() ) * ( Math.random() - Math.random() * adding1 );
			if ( cube.y > 550 ) cube.y = 1100 - cube.y;
			if ( cube.y < 0 ) cube.y = -cube.y;
			
			// send calculated data to all listeners
			publisher.publish( cube );
		}
		
		// new connection to the server
		private function onServer( msg : Messenger ) : void {
			var trig : ITriggered = publisher.addPublisher( msg.publisher );
			msg.emitter.subscribe( calcCube, trig.cancel );
		}
		
		
		/* INTERFACE vm.miix.grit.wire.ITask */
		
		/**
		 * @inheritDoc
		 */
		public function run( context : IContext, registration : IRegistration, param : * ) : IPromise {
			
			// initial calculation data
			var adding : Number = param as Number;
			
			adding1 = 2 - adding;
			adding2 = 1 + adding;
			
			// register server to exchange data
			return context.registerServer ( new ServerDescriptor( new Address( updateServer + String( adding ) ),
				ServerTypes.INTERNAL ), onServer );
			
		}
		
	}

}