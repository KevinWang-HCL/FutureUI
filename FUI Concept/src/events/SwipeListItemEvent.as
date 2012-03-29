package events
{
	import flash.events.Event;
	
	public class SwipeListItemEvent extends Event
	{
		public var itemObj:Object = null;
		
		public function SwipeListItemEvent(type:String, itemObj:Object)
		{
			this.itemObj = itemObj;
			super(type, bubbles, cancelable);
		}
	}
}