package events
{
	import flash.events.Event;
	
	public class KeypadEvent extends Event
	{
		public static const KEYPAD_PRESS_EVENT:String = "KeyPadPress";
		public static const KEYPAD_CLOSE_EVENT:String = "KeyPadClose";
		public static const KEYPAD_DELETE_EVENT:String = "KeyPadDelete";
		
		private var keyPressed:String;
		
		public function KeypadEvent(type:String, keyPressed:String = "", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.keyPressed = keyPressed;
		}
		
		public function get KeyPressed():String
		{
			return keyPressed;
		}
		
		public function set KeyPressed(value:String):void
		{
			keyPressed = value;
		}
	}
}