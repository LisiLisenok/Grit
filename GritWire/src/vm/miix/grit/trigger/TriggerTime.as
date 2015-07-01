package vm.miix.grit.trigger 
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * trigger based on timer
	 * @see flash.utils.Timer
	 * @author Lis
	 */
	public class TriggerTime implements ITrigger 
	{
		
		private var timer : Timer;
		private var trigger : Trigger;
		
		
		/**
		 * creates new instance.
		 * Don't started automaticaly, call <code>start</code>
		 * @param	delay time delay in miliseconds
		 * @param	repeatCount number of repeats. If zero, repeats infinitely, if greater than zero repeats reuired times
		 */
		public function TriggerTime( delay : Number, repeatCount : int = 0 ) {
			
			timer = new Timer( delay, repeatCount );
			timer.addEventListener( TimerEvent.TIMER, function ( e : Event ) : void { trigger.alarm() } );
			timer.addEventListener( TimerEvent.TIMER_COMPLETE, function ( e : Event ) : void { cancel(); } );
			
			trigger = new Trigger();
		}
		
		
		/**
		 * start timer
		 */
		public function start() : void {
			if ( timer.running ) cancel();
			if ( !trigger.isCompleted ) timer.start();
		}
		
		
		/* INTERFACE vm.miix.grit.trigger.ITrigger */
		
		/**
		 * @inheritDoc
		 */
		public function subscribe( onAlarm : Function, onComplete : Function = null ) : ITriggered {
			return trigger.subscribe( onAlarm, onComplete );
		}
		
		/**
		 * @inheritDoc
		 */
		public function cancel() : void {
			timer.reset();
			trigger.cancel();
		}
		
		/**
		 * @inheritDoc
		 */
		public function activate() : void {
			if ( !trigger.isCompleted ) {
				trigger.activate();
				timer.start();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function deactivate() : void {
			if ( !trigger.isCompleted ) {
				trigger.deactivate();
				timer.stop();
			}
		}
		
	}

}