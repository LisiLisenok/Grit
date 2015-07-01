package vm.miix.grit.emitter 
{
	/**
	 * proxy publisher
	 * @author Lis
	 */
	internal class PublisherProxy implements IPublisher 
	{
		
		private var publisher : IPublisher;
		
		public function PublisherProxy( publisher : IPublisher ) {
			this.publisher = publisher;
		}

		
		/* INTERFACE vm.miix.grit.emitter.IPublisher */
		
		/**
		 * @inheritDoc
		 */
		public function publish( value : * ) : void { publisher.publish( value ); }
		
		/**
		 * @inheritDoc
		 */
		public function complete() : void { publisher.complete(); }
		
		/**
		 * @inheritDoc
		 */
		public function error( reason : * ) : void { publisher.error( reason ); }
		
	}

}