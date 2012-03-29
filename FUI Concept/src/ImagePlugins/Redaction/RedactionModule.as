package ImagePlugins.Redaction
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEffect;
	import MimicPlugin.ImageModuleHost;
	
	import flash.geom.Point;
	
	import integration.SettingsMap;
	
	import mimicViewComponent.ImageMouseEvent;
	
	public class RedactionModule implements ImageEditModule
	{
		private static const DEFAULT_REDACTION_WEIGHTING:Number = 10;
		public static const PLACE_DISABLED:int = 0, PLACE_LINE:int = 1, PLACE_RECT:int = 2;
		
		public static const WHITE:uint = 0xFFFFFF, BLACK:uint = 0x0;
		
		private var currRedactionId:uint;
		private var moduleHost:ImageModuleHost;
		public var _placeMode:int, redactionStarted:Boolean;
		public var prevPos:Point;
		public var startPoint:Point;
		public var currEffect:RedactionEffect;
		private var placedRedactions:Vector.<RedactionEffect>;
		private var redoRedactionList:Vector.<RedactionEffect>;
		private var _weighting:Number;
		private var _colour:uint;
		
		public function RedactionModule(host:ImageModuleHost)
		{
			moduleHost = host;
			placedRedactions = new Vector.<RedactionEffect>();
			redoRedactionList = new Vector.<RedactionEffect>();
			_placeMode = 0;
			redactionStarted = false;
			prevPos = new Point();
			startPoint = new Point();
			_weighting = DEFAULT_REDACTION_WEIGHTING;
			_colour = BLACK;
			currRedactionId = 0;
		}
		
		public function madeActive(host:ImageModuleHost):void
		{
			
		}
		
		public function madeInactive(host:ImageModuleHost):void
		{
			
		}
		
		public function handleMouseDown(evt:ImageMouseEvent):void
		{
			if(_placeMode > 0)
			{
				redactionStarted = true;
				prevPos.x = evt.scaledImageCoord.x;
				prevPos.y = evt.scaledImageCoord.y;
				startPoint.x = evt.scaledImageCoord.x;
				startPoint.y = evt.scaledImageCoord.y;
				
				currEffect = new RedactionEffect(currRedactionId, startPoint, _weighting, _placeMode, this);
				currEffect.setProperty(RedactionEffect.COLOUR_PROPERTY, _colour);
				moduleHost.applyImageEffect(currEffect);
				moduleHost.panningEnabled = false;
				moduleHost.zoomEnabled = false;
				currRedactionId++;
			}
		}
		
		public function handleMouseMove(evt:ImageMouseEvent):void
		{
			if(_placeMode > 0 && redactionStarted)
			{
				currEffect.setEndPoint(evt.scaledImageCoord.x, evt.scaledImageCoord.y);
				prevPos.x = evt.scaledImageCoord.x;
				prevPos.y = evt.scaledImageCoord.y;	
			}
		}
		
		public function handleMouseUp(evt:ImageMouseEvent):void
		{
			if(_placeMode > 0 && redactionStarted)
			{
				redactionStarted = false;
				placedRedactions.push(currEffect);
				moduleHost.panningEnabled = true;
				moduleHost.zoomEnabled = true;
			}
		}
		
		public function handleDoubleClick(evt:ImageMouseEvent):void
		{
			
		}
		
		public function handleZoomed(host:ImageModuleHost):void
		{
			
		}
		
		public function notifyEffectRemoved(effect:ImageEffect):void
		{
		}
		
		public function applyOutputSettings(settings:SettingsMap):void
		{
			
		}
		
		public function undoEffect():void 
		{
			if(placedRedactions.length > 0)
			{
				var removed:RedactionEffect = placedRedactions.pop();
				moduleHost.removeImageEffect(removed);
				redoRedactionList.push(removed);
			}
		}
		
		public function redoEffect():void
		{
			if(redoRedactionList.length > 0)
			{
				var readded:RedactionEffect = redoRedactionList.pop();
				moduleHost.applyImageEffect(readded);
				placedRedactions.push(readded);
			}
		}
		
		public function clearAllEffects():void
		{
			while(placedRedactions.length > 0)
				undoEffect();
		}
		
		public function get placeMode():int
		{
			return _placeMode;
		}
		
		public function set placeMode(value:int):void
		{
			_placeMode = value;
		}
		
		public function hasActiveEffects():Boolean
		{
			return placedRedactions.length > 0;	
		}
		
		public function createImageEffect():ImageEffect
		{
			return null;
		}
		
		public function get weighting():Number
		{
			return _weighting;
		}
		
		public function set weighting(value:Number):void
		{
			_weighting = value;
		}
		
		public function get colour():uint
		{
			return _colour;
		}
		
		public function set colour(value:uint):void
		{
			_colour = value;
		}
		
		public function reset():void
		{
			for each(var r:RedactionEffect in placedRedactions)
			{
				moduleHost.removeImageEffect(r);
			}
			
			placedRedactions = new Vector.<RedactionEffect>();
		}
	}
}