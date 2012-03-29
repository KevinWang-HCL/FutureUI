package events
{
	import flash.events.Event;
	
	public class KeypadCloseEvent extends Event
	{
		public function KeypadCloseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}