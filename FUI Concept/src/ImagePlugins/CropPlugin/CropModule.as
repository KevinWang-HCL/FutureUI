package ImagePlugins.CropPlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEditSettings;
	import MimicPlugin.ImageEffect;
	import MimicPlugin.ImageModuleHost;
	
	import assets.embedded.Widget_Images;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import integration.ApplicationSettings;
	import integration.SettingsMap;
	
	import mimicViewComponent.ImageMouseEvent;
	import mimicViewComponent.ImageRectangle;
	
	import mx.graphics.SolidColor;
	
	import spark.primitives.Rect;
	
	public class CropModule implements ImageEditModule
	{
		private static const LEFT_HANDLE:int = 0, RIGHT_HANDLE:int = 1,
							 TOP_HANDLE:int = 2, BOTTOM_HANDLE:int = 3,
							 TOP_LEFT_HANDLE:int = 4, TOP_RIGHT_HANDLE:int = 5,
							 BOTTOM_LEFT_HANDLE:int = 6, BOTTOM_RIGHT_HANDLE:int = 7;
		public static const LINE_PRESS_TOLERANCE:int = 58; //px 
		
		public var host:ImageModuleHost;
		
		private var effect:CropEffect;
		
		private var cropping:Boolean;
		private var cropHandles:Vector.<Rectangle>;
		private var currHandle:int;
		private var imageWidth:Number, imageHeight:Number;
		private var prevPos:Point;
		
		public function CropModule(host:ImageModuleHost)
		{
			this.host = host;
			effect = new CropEffect();
			effect._creator = this;
			cropHandles = new Vector.<Rectangle>();
			var th:* = new Widget_Images.thumbHorizontalClass();
			var tv:* = new Widget_Images.thumbVerticalClass();
			
			for(var i:int = 0; i <= BOTTOM_RIGHT_HANDLE; i++)
				cropHandles[i] = new Rectangle();
			
			cropping = false;
			currHandle = -1;
			
			prevPos = new Point();
			createImageEffect();
		}
		
		private function initialiseCropHandleBounds(imageBounds:Rectangle):void
		{
			var toleranceX:Number = LINE_PRESS_TOLERANCE / (imageBounds.width * host.currentZoom);
			var toleranceY:Number = LINE_PRESS_TOLERANCE / (imageBounds.height * host.currentZoom);
			
			cropHandles[LEFT_HANDLE].width = toleranceX;
			cropHandles[LEFT_HANDLE].height = 1.0 - toleranceY;
			cropHandles[LEFT_HANDLE].y = toleranceY / 2.0;
			
			cropHandles[RIGHT_HANDLE].width = toleranceX;
			cropHandles[RIGHT_HANDLE].height = 1.0 - toleranceY;
			cropHandles[RIGHT_HANDLE].y = toleranceY / 2.0;
			
			cropHandles[TOP_HANDLE].height = toleranceY;
			cropHandles[TOP_HANDLE].width = 1.0 - toleranceX;
			cropHandles[TOP_HANDLE].x = toleranceX / 2.0;
			
			cropHandles[BOTTOM_HANDLE].height = toleranceY;
			cropHandles[BOTTOM_HANDLE].width = 1.0 - toleranceX;
			cropHandles[BOTTOM_HANDLE].x = toleranceX / 2.0;
			
			cropHandles[TOP_LEFT_HANDLE].width = toleranceX;
			cropHandles[TOP_LEFT_HANDLE].height = toleranceY;
			cropHandles[TOP_LEFT_HANDLE].x = -(toleranceX/2.0);
			cropHandles[TOP_LEFT_HANDLE].y = -(toleranceY/2.0);
			
			cropHandles[TOP_RIGHT_HANDLE].width = toleranceX;
			cropHandles[TOP_RIGHT_HANDLE].height = toleranceY;
			cropHandles[TOP_RIGHT_HANDLE].x = 1.0 - (toleranceX/2.0);
			cropHandles[TOP_RIGHT_HANDLE].y = -(toleranceY/2.0);
			
			cropHandles[BOTTOM_LEFT_HANDLE].width = toleranceX;
			cropHandles[BOTTOM_LEFT_HANDLE].height = toleranceY;
			cropHandles[BOTTOM_LEFT_HANDLE].x = -(toleranceX/2.0);
			cropHandles[BOTTOM_LEFT_HANDLE].y = 1.0 - (toleranceY/2.0);
			
			cropHandles[BOTTOM_RIGHT_HANDLE].width = toleranceX;
			cropHandles[BOTTOM_RIGHT_HANDLE].height = toleranceY;
			cropHandles[BOTTOM_RIGHT_HANDLE].x = 1.0 - (toleranceX/2.0);
			cropHandles[BOTTOM_RIGHT_HANDLE].y = 1.0 - (toleranceY/2.0);
		}
		
		public function madeActive(host:ImageModuleHost):void
		{
			host.resetZoomEnabled = false;
			host.applyImageEffect(effect);
			var imgBounds:Rectangle = host.imageBounds;
			initialiseCropHandleBounds(imgBounds);
			setCropMargin(CropEffect.CROP_LEFT, effect.leftCrop);
			setCropMargin(CropEffect.CROP_RIGHT, effect.rightCrop);
			setCropMargin(CropEffect.CROP_TOP, effect.topCrop);
			setCropMargin(CropEffect.CROP_BOTTOM, effect.bottomCrop);
			
			effect.showOnImage(host.image);
			effect.changeDisplayRects(imgBounds.width, imgBounds.height);
			handleZoomed(host);
		}
		
		public function madeInactive(host:ImageModuleHost):void
		{
			effect.removeFromImage(host.image);
			effect.setActive(false, host);
			host.panningEnabled = true;
			host.resetZoomEnabled = true;
		}
		
		public function handleMouseDown(evt:ImageMouseEvent):void
		{
			var normalisedCoord:Point = new Point(evt.scaledImageCoord.x / host.imageBounds.width,
													evt.scaledImageCoord.y / host.imageBounds.height);
			for(var i:int = 0; i <= BOTTOM_RIGHT_HANDLE; i++)
			{
				if(normalisedCoord.x >= cropHandles[i].x 
					&& normalisedCoord.x <= cropHandles[i].x + cropHandles[i].width
					&& normalisedCoord.y >= cropHandles[i].y
					&& normalisedCoord.y <= cropHandles[i].y + cropHandles[i].height)
				{
					cropping = true;
					currHandle = i;
					prevPos.x = evt.scaledImageCoord.x;
					prevPos.y = evt.scaledImageCoord.y;
					host.panningEnabled = false;
					break;
				}
			}
		}
		
		public function handleMouseMove(evt:ImageMouseEvent):void
		{
			if(cropping)
			{
				var imgBounds:Rectangle = host.imageBounds;
				var dx:Number = evt.scaledImageCoord.x - prevPos.x;
				var dy:Number = evt.scaledImageCoord.y - prevPos.y;
				var diff:Number;
				
				onCropHandleMoved(currHandle, dx, dy, imgBounds);
				
				prevPos.x = evt.scaledImageCoord.x;
				prevPos.y = evt.scaledImageCoord.y;
			}
		}
		
		private function onCropHandleMoved(handle:int, cursorDx:Number, cursorDy:Number, imageBounds:Rectangle):void
		{
			switch(handle)
			{
				case LEFT_HANDLE:
					var newLeft:Number = effect.leftCrop + cursorDx;
					if(newLeft >= 0 && newLeft < imageBounds.width - effect.rightCrop)
						setCropMargin(CropEffect.CROP_LEFT, newLeft);
					break;
				
				case RIGHT_HANDLE:
					var newRight:Number = effect.rightCrop - cursorDx;
					if(newRight >= 0 && imageBounds.width - newRight > effect.leftCrop)
						setCropMargin(CropEffect.CROP_RIGHT, newRight);
					break;
				
				case TOP_HANDLE:
					var newTop:Number = effect.topCrop + cursorDy;
					if(newTop >= 0 && newTop < imageBounds.height - effect.bottomCrop)
						setCropMargin(CropEffect.CROP_TOP, newTop);
					break;
				
				case BOTTOM_HANDLE:
					var newBottom:Number = effect.bottomCrop - cursorDy;
					if(newBottom >= 0 && imageBounds.height - newBottom > effect.topCrop)
						setCropMargin(CropEffect.CROP_BOTTOM, newBottom);
					break;
				
				case TOP_LEFT_HANDLE:
					var newLeft:Number = effect.leftCrop + cursorDx;
					var newTop:Number = effect.topCrop + cursorDy;
					if(newLeft >= 0 && newLeft < imageBounds.width - effect.rightCrop)
						setCropMargin(CropEffect.CROP_LEFT, newLeft);
					if(newTop >= 0 && newTop < imageBounds.height - effect.bottomCrop)
						setCropMargin(CropEffect.CROP_TOP, newTop);
					break;
				
				case TOP_RIGHT_HANDLE:
					var newRight:Number = effect.rightCrop - cursorDx;
					var newTop:Number = effect.topCrop + cursorDy;
					if(newRight >= 0 && imageBounds.width - newRight > effect.leftCrop)
						setCropMargin(CropEffect.CROP_RIGHT, newRight);
					if(newTop >= 0 && newTop < imageBounds.height - effect.bottomCrop)
						setCropMargin(CropEffect.CROP_TOP, newTop);
					break;
				
				case BOTTOM_LEFT_HANDLE:
					var newLeft:Number = effect.leftCrop + cursorDx;
					var	newBottom:Number = effect.bottomCrop - cursorDy;
					if(newLeft >= 0 && newLeft < imageBounds.width - effect.rightCrop)
						setCropMargin(CropEffect.CROP_LEFT, newLeft);
					if(newBottom >= 0 && imageBounds.height - newBottom > effect.topCrop)
						setCropMargin(CropEffect.CROP_BOTTOM, newBottom);
					break;
				
				case BOTTOM_RIGHT_HANDLE:
					var newRight:Number = effect.rightCrop - cursorDx;
					var newBottom:Number = effect.bottomCrop - cursorDy;
					if(newRight >= 0 && imageBounds.width - newRight > effect.leftCrop)
						setCropMargin(CropEffect.CROP_RIGHT, newRight);
					if(newBottom >= 0 && imageBounds.height - newBottom > effect.topCrop)
						setCropMargin(CropEffect.CROP_BOTTOM, newBottom);
					break;
				
			};
		}
		
		public function setCropMargin(margin:String, value:Number):void
		{
			effect.setProperty(margin, value);
			var newPos:Number;
			switch(margin)
			{
				case CropEffect.CROP_LEFT:
					newPos = value / host.imageBounds.width;
					var newWidthL:Number = 1.0 - (newPos + effect.rightCrop / host.imageBounds.width)- cropHandles[LEFT_HANDLE].width;
					
					cropHandles[TOP_HANDLE].width = newWidthL;
					cropHandles[TOP_HANDLE].x = newPos + (cropHandles[TOP_LEFT_HANDLE].width/2.0);
					
					cropHandles[BOTTOM_HANDLE].width = newWidthL;
					cropHandles[BOTTOM_HANDLE].x = newPos + (cropHandles[BOTTOM_LEFT_HANDLE].width / 2.0);
					
					cropHandles[LEFT_HANDLE].x = newPos - (cropHandles[LEFT_HANDLE].width / 2.0);
					cropHandles[TOP_LEFT_HANDLE].x = newPos - (cropHandles[TOP_LEFT_HANDLE].width / 2.0);
					cropHandles[BOTTOM_LEFT_HANDLE].x = newPos - (cropHandles[BOTTOM_LEFT_HANDLE].width / 2.0);
					break;
				case CropEffect.CROP_RIGHT:
					newPos = 1.0 - (value / host.imageBounds.width);
					var newWidthR:Number = newPos - (effect.leftCrop / host.imageBounds.width) - cropHandles[LEFT_HANDLE].width;
					
					cropHandles[TOP_HANDLE].width = newWidthR;
					
					cropHandles[BOTTOM_HANDLE].width = newWidthR;
					
					cropHandles[RIGHT_HANDLE].x = newPos - (cropHandles[RIGHT_HANDLE].width / 2.0);
					
					cropHandles[TOP_RIGHT_HANDLE].x = newPos - (cropHandles[TOP_RIGHT_HANDLE].width / 2.0);
					cropHandles[BOTTOM_RIGHT_HANDLE].x = newPos - (cropHandles[BOTTOM_RIGHT_HANDLE].width / 2.0);
					break;
				case CropEffect.CROP_TOP:
					newPos = value / host.imageBounds.height;
					var newHeightT:Number = 1.0 - (newPos + effect.bottomCrop / host.imageBounds.height) - cropHandles[TOP_HANDLE].height;
					
					cropHandles[RIGHT_HANDLE].height = newHeightT;
					cropHandles[RIGHT_HANDLE].y = newPos + (cropHandles[TOP_RIGHT_HANDLE].height / 2.0);
					
					cropHandles[LEFT_HANDLE].height = newHeightT;
					cropHandles[LEFT_HANDLE].y = newPos + (cropHandles[TOP_LEFT_HANDLE].height / 2.0);
					
					cropHandles[TOP_HANDLE].y = newPos - (cropHandles[TOP_HANDLE].height / 2.0);
					
					cropHandles[TOP_LEFT_HANDLE].y = newPos - (cropHandles[TOP_LEFT_HANDLE].height / 2.0);
					cropHandles[TOP_RIGHT_HANDLE].y = newPos - (cropHandles[TOP_RIGHT_HANDLE].height / 2.0);
					break;
				case CropEffect.CROP_BOTTOM:
					newPos = 1.0 - (value / host.imageBounds.height);
					var newHeightB:Number = newPos - (effect.topCrop / host.imageBounds.height) - cropHandles[TOP_HANDLE].height;
					
					cropHandles[RIGHT_HANDLE].height = newHeightB;
					cropHandles[LEFT_HANDLE].height = newHeightB;
					cropHandles[BOTTOM_HANDLE].y = newPos - (cropHandles[BOTTOM_HANDLE].height / 2.0);
					cropHandles[BOTTOM_LEFT_HANDLE].y = newPos - (cropHandles[BOTTOM_LEFT_HANDLE].height / 2.0);
					cropHandles[BOTTOM_RIGHT_HANDLE].y = newPos - (cropHandles[BOTTOM_RIGHT_HANDLE].height / 2.0);
					break;
				
			}
		}
		
		public function handleMouseUp(evt:ImageMouseEvent):void
		{
			if(cropping)
			{
				cropping = false;
				currHandle = -1;
				host.panningEnabled = true;
			}
		}
		
		public function handleDoubleClick(evt:ImageMouseEvent):void
		{
			var normalisedCoord:Point = new Point(evt.scaledImageCoord.x / host.imageBounds.width,
				evt.scaledImageCoord.y / host.imageBounds.height);
			var elementDoubleClicked:Boolean = false;
			for(var i:int = 0; i <= BOTTOM_RIGHT_HANDLE; i++)
			{
				if(normalisedCoord.x >= cropHandles[i].x 
				   && normalisedCoord.x <= cropHandles[i].x + cropHandles[i].width
				   && normalisedCoord.y >= cropHandles[i].y
				   && normalisedCoord.y <= cropHandles[i].y + cropHandles[i].height)
				{
					switch(i)
					{
						case LEFT_HANDLE:
							setCropMargin(CropEffect.CROP_LEFT, 0);
							break;
						case RIGHT_HANDLE:
							setCropMargin(CropEffect.CROP_RIGHT, 0);
							break;
						case TOP_HANDLE:
							setCropMargin(CropEffect.CROP_TOP, 0);
							break;
						case BOTTOM_HANDLE:
							setCropMargin(CropEffect.CROP_BOTTOM, 0);
							break;
						case TOP_LEFT_HANDLE:
							setCropMargin(CropEffect.CROP_TOP, 0);
							setCropMargin(CropEffect.CROP_LEFT, 0);
							break;
						case TOP_RIGHT_HANDLE:
							setCropMargin(CropEffect.CROP_TOP, 0);
							setCropMargin(CropEffect.CROP_RIGHT, 0);
							break;
						case BOTTOM_LEFT_HANDLE:
							setCropMargin(CropEffect.CROP_BOTTOM, 0);
							setCropMargin(CropEffect.CROP_LEFT, 0);
							break;
						case BOTTOM_RIGHT_HANDLE:
							setCropMargin(CropEffect.CROP_BOTTOM, 0);
							setCropMargin(CropEffect.CROP_RIGHT, 0);
							break;
					}
					elementDoubleClicked = true;
					break;
				}
			}
			
			//If an element has been double clicked we don't want to reset the zoom,
			//and vice versa.
			host.resetZoomEnabled = !elementDoubleClicked;
		}
		
		public function handleZoomed(host:ImageModuleHost):void
		{
			for(var i:int = 0; i <= BOTTOM_RIGHT_HANDLE; i++)
				handleCropHandleZoomed(i, host);
			
			effect.updateDisplayGrid(host.imageBounds.width, host.imageBounds.height);
		}
		
		private function handleCropHandleZoomed(index:int, host:ImageModuleHost):void
		{
			if(index != TOP_HANDLE && index != BOTTOM_HANDLE)
			{
				cropHandles[index].x += cropHandles[index].width / 2.0;
				cropHandles[index].width = LINE_PRESS_TOLERANCE / (host.imageBounds.width * host.currentZoom);
				cropHandles[index].x -= cropHandles[index].width / 2.0;
			}
			if(index != RIGHT_HANDLE && index != LEFT_HANDLE)
			{
				cropHandles[index].y += cropHandles[index].height / 2.0;
				cropHandles[index].height = LINE_PRESS_TOLERANCE / (host.imageBounds.height * host.currentZoom);
				cropHandles[index].y -= cropHandles[index].height / 2.0;
			}
		}
		
		public function applyOutputSettings(settings:SettingsMap):void
		{
			var dpi:Number = ApplicationSettings.get().get(ApplicationSettings.PRESCAN_DPI)
			var leftInches:Number = effect.leftCrop / dpi;
			var rightInches:Number = effect.rightCrop / dpi;
			var topInches:Number = effect.topCrop / dpi;
			var bottomInches:Number = effect.bottomCrop / dpi;
			settings.set(ImageEditSettings.SETTING_EDGE_CROP, [topInches, rightInches, bottomInches, leftInches]);
		}
		
		public function notifyEffectRemoved(effect:ImageEffect):void
		{
			
		}
		
		public function hasActiveEffects():Boolean
		{
			return effect.bottomCrop != 0 || effect.topCrop != 0 || effect.leftCrop != 0 || effect.rightCrop != 0;	
		}
		
		public function createImageEffect():ImageEffect
		{
			return effect;
		}
		
		public function reset():void
		{
			setCropMargin(CropEffect.CROP_LEFT, 0);
			setCropMargin(CropEffect.CROP_RIGHT, 0);
			setCropMargin(CropEffect.CROP_TOP, 0);
			setCropMargin(CropEffect.CROP_BOTTOM, 0);
		}
	}
}