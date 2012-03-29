package xerox
{
	// Import class
	// from http://www.xllusion.net/ed/2008/01/21/as3-custom-event-for-passing-unlimited-parameters/
	// dynamic event type that can pass unlimited parameters
	import flash.events.Event;
	// EventType
	public class XRX_EventType extends Event {
		// Properties
		public var arg:*;
		// Constructor
		public function XRX_EventType(type:String, bubbles:Boolean = false, cancelable:Boolean = false, ... a:*) {
			super(type, bubbles, cancelable);
			arg = a;
		}
		// Override clone
		override public function clone():Event{
			return new XRX_EventType(type, bubbles, cancelable, arg);
		};
	}

}