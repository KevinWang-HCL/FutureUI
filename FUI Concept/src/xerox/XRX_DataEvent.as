// ActionScript file
package xerox
{
	// a custom event that carries data, for example XML received from a socket, for use by the main application
	import flash.events.*;
	
	public class XRX_DataEvent extends Event
	{
		public static const EVENT_OCCURRED: String = "event occurred";
		public static const SERVER_EVENT_OCCURRED: String = "server event occurred";
		
		public var data:Object;
		
		public function XRX_DataEvent(type:String, customData:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.data = customData;
		}
		
		override public function clone():Event
		{
			return new XRX_DataEvent (type, data, bubbles, cancelable);
		}
		
	}
}