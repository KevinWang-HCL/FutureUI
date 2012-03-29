package widgets
{
	import assets.embedded.Sounds;
	import assets.skins.skinButtonNav;
	
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	
	public class wNavigationButton extends Button
	{
		private var _clickHandler:Function;
		
		public function wNavigationButton(id:String, label:String, icon:*, clickHandler:Function)
		{
			super();
			this.id = id;
			this.label = label;
			if(icon)
				this.setStyle("icon", icon);
			this.setStyle("skinClass", skinButtonNav);
			this.addEventListener(MouseEvent.CLICK, onClick);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_clickHandler = clickHandler;
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			Sounds.soundClick();
		}
		
		private function onClick(event:MouseEvent):void
		{
			if(_clickHandler != null)
				_clickHandler(event);
		}
		
	}
}