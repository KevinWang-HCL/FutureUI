package ImagePlugins.CropPlugin
{
	import MimicPlugin.ImageEditUIComponent;
	
	import flash.display.BitmapData;
	
	import mx.events.FlexEvent;
	
	import spark.primitives.BitmapImage;
	
	/*public class CropHandle extends BitmapImage implements ImageEditUIComponent
	{
		private var _nx:Number, _ny:Number;
		private var _ox:Number, _oy:Number;
		
		public function CropHandle(nx:Number, ny:Number, imgSrc:BitmapData)
		{
			super();
			_nx = nx;
			_ny = ny;
			_ox = 0.0;
			_oy = 0.0;
			this.source = imgSrc;
			//This is fucking awful. When the module is first made active, the image sources 
			//aren't ready, therefore when handleZoom is called, the handles aren't centred.
			//This centres the handles automagically when the images are ready. Not a nice way
			//to do it though.
			addEventListener(FlexEvent.READY, function(evt:FlexEvent):void
			{
				evt.target.x -= imgSrc.width / 2.0;
				evt.target.y -= imgSrc.height / 2.0;
			});
		}
		
		public function get offsetX():Number
		{
			return _ox;
		}
		
		public function set offsetX(value:Number):void
		{
			_ox = value;
		}
		
		public function get offsetY():Number
		{
			return _oy;
		}
		
		public function set offsetY(value:Number):void
		{
			_oy = value;	
		}
		
		public function get normalisedX():Number
		{
			return _nx + _ox;
		}
		
		public function get normalisedY():Number
		{
			return _ny + _oy;
		}
		
		public function get centred():Boolean
		{
			return true;
		}
		
		public override function toString():String
		{
			return "[CropHandle: " + ", " + x + ", " + y + ", " + width + ", " + height + ", " + normalisedX + ", " + normalisedY + "]";
		}
	}*/
}