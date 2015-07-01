package vm.miix.grit.emitter 
{
	import vm.miix.grit.collection.IIterator;
	import vm.miix.grit.collection.List;
	import vm.miix.grit.trigger.ITriggered;
	
	/**
	 * combination of several publishers.
	 * published, completes or errors on all
	 * @author Lis
	 */
	public class PublisherList implements IPublisher 
	{
		
		
		private var publishers : List = new List;
		
		
		public function PublisherList() {
			
		}
		
		
		public function addPublisher( publisher : IPublisher ) : ITriggered {
			return publishers.add( publisher );
		}
		
		
		
		/* INTERFACE vm.miix.grit.emitter.IPublisher */
			
		/**
		 * @inheritDoc
		 */
		public function publish( value : * ) : void {
			publishers.lock();
			var iter : IIterator = publishers.iterator;
			while ( iter.hasNext() ) {
				var publisher : IPublisher = iter.next() as IPublisher;
				if ( publisher ) publisher.publish( value );
			}
			publishers.unlock();
		}
			
		/**
		 * @inheritDoc
		 */
		public function complete() : void {
			publishers.lock();
			var iter : IIterator = publishers.iterator;
			while ( iter.hasNext() ) {
				var publisher : IPublisher = iter.next() as IPublisher;
				if ( publisher ) publisher.complete();
			}
			publishers.unlock();
			publishers.clear();
		}
			
		/**
		 * @inheritDoc
		 */
		public function error( reason : * ) : void {
			publishers.lock();
			var iter : IIterator = publishers.iterator;
			while ( iter.hasNext() ) {
				var publisher : IPublisher = iter.next() as IPublisher;
				if ( publisher ) publisher.error( reason );
			}
			publishers.unlock();
		}
		
	}

}