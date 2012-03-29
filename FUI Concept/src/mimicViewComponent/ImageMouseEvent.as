package mimicViewComponent
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class ImageMouseEvent extends MouseEvent
	{
		private var _scaledImageCoord:Point;
		private var _stageX:Number;
		private var _stageY:Number;
		
		public function ImageMouseEvent(me:MouseEvent)
		{
			super(me.type, me.bubbles, me.cancelable, me.localX, me.localY, 
					me.relatedObject, me.ctrlKey, me.altKey, me.shiftKey, 
					me.buttonDown, me.delta, me.commandKey, me.controlKey, 
					me.clickCount);
			this._stageX = me.stageX;
			this._stageY = me.stageY;
			_scaledImageCoord = new Point();
		}
		
		public function get scaledImageCoord():Point
		{
			return _scaledImageCoord;
		}
		
		public function set scaledImageCoord(value:Point):void
		{
			this._scaledImageCoord = value;
		}
		
		public override function get stageX():Number
		{
			return _stageX;
		}
		
		public override function get stageY():Number
		{
			return _stageY;
		}
	}
}