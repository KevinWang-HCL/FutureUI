package ImagePlugins.CropPlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEffect;
	import MimicPlugin.ImageModuleHost;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mimicViewComponent.EditImage;
	
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.primitives.Line;
	import spark.primitives.Rect;
	
	public class CropEffect implements ImageEffect
	{
		public static const CROP_LEFT:String = "cropLeft";
		public static const CROP_RIGHT:String = "cropRight";
		public static const CROP_TOP:String = "cropTop";
		public static const CROP_BOTTOM:String = "cropBottom";
		
		private static const EDIT_FILL:SolidColor = new SolidColor(0, 0.6);
		private static const DISPLAY_FILL:SolidColor = new SolidColor(0xFFFFFF, 1.0);
		
		private var _imgWidth:Number, _imgHeight:Number;
		public var _creator:CropModule;
		private var _leftCrop:Number, _rightCrop:Number, _topCrop:Number, _bottomCrop:Number;
		private var _displayRects:Array;
		
		private var _outlineRectThick:Rect;
		private var _outlineRectThin:Rect;
		private var _gridLines:Vector.<Line>;
		private var _cornerRects:Vector.<Rect>;
		
		private var _added:Boolean;
		
		public function CropEffect()
		{
			_leftCrop = 0; _rightCrop = 0;
			_topCrop = 0; _bottomCrop = 0;
			
			_displayRects = new Array();
				
			var left:Rect = new Rect();
				left.fill = new SolidColor(0, 0.7);
			_displayRects[CROP_LEFT] = left;
				
			var right:Rect = new Rect();
				right.fill = new SolidColor(0, 0.7);
			_displayRects[CROP_RIGHT] = right;
			
			var top:Rect = new Rect();
				top.fill = new SolidColor(0, 0.7);
			_displayRects[CROP_TOP] = top;
			
			var bottom:Rect = new Rect();
				bottom.fill = new SolidColor(0, 0.7);
			_displayRects[CROP_BOTTOM] = bottom;
			
			_outlineRectThick = new Rect();
			_outlineRectThick.stroke = new SolidColorStroke(0xFFFFFF, 3, 0.6);
			
			_outlineRectThin = new Rect();
			_outlineRectThin.stroke = new SolidColorStroke(0x0, 1, 0.6);
			
			_gridLines = new Vector.<Line>();
			// 4 grid lines, each made up of a white 'thick' line, and a black 'thin' line.
			// This is used to create the impression of complex stroking with the outline rectangles.
			/*for(var i:int = 0; i < 8; i++) 
			{
				_gridLines[i] = new Line();
				
				if(i % 2 == 0)
				{
					//Weighting will be different for either horizontal of vertical lines,
					//but set both values here so they do not need to be re-initialised later on.
					_gridLines[i].stroke = new SolidColorStroke(0xFFFFFF, 6, 0.6);
				}
				else
				{
					_gridLines[i].stroke = new SolidColorStroke(0x0, 2, 0.6);
				}
			}*/
			
			for(var i:int = 0; i < 4; i++)
			{
				_gridLines[i] = new Line();
				_gridLines[i].stroke = new SolidColorStroke(0xFFFFFF, 6, 0.6);
			}
			for(var j:int = 4; j < 8; j++)
			{
				_gridLines[j] = new Line();
				_gridLines[j].stroke = new SolidColorStroke(0x0, 2, 0.6);
			}
			
			_cornerRects = new Vector.<Rect>();
			
			for(var i:int = 0; i < 8; i++)
			{
				_cornerRects[i] = new Rect();
				_cornerRects[i].fill = new SolidColor(0x0, 0.9);
				
				if(i % 2 == 0)
				{
					_cornerRects[i].width = (CropModule.LINE_PRESS_TOLERANCE / 2.0) + (CropModule.LINE_PRESS_TOLERANCE / 6.0);
					_cornerRects[i].height = CropModule.LINE_PRESS_TOLERANCE / 6.0;
				}
				else
				{
					_cornerRects[i].width = CropModule.LINE_PRESS_TOLERANCE / 6.0;
					_cornerRects[i].height = (CropModule.LINE_PRESS_TOLERANCE / 2.0 ) + (CropModule.LINE_PRESS_TOLERANCE / 6.0);
				}
			}
			
			_added = false;
		}
		
		public function changeDisplayRects(imgWidth:Number, imgHeight:Number):void
		{
			_imgWidth = imgWidth;
			_imgHeight = imgHeight;
			
			(_displayRects[CROP_LEFT] as Rect).height = imgHeight;
			(_displayRects[CROP_RIGHT] as Rect).height = imgHeight;
			
			(_displayRects[CROP_TOP] as Rect).width = imgWidth - _leftCrop - _rightCrop;
			(_displayRects[CROP_BOTTOM] as Rect).width = imgWidth - _leftCrop - _rightCrop;
			updateDisplayGrid(imgWidth, imgHeight);
			
		}
		
		public function updateDisplayGrid(imgWidth:Number, imgHeight:Number):void
		{
			_outlineRectThick.x = _displayRects[CROP_LEFT].width;
			_outlineRectThick.y = _displayRects[CROP_TOP].height;
			_outlineRectThick.width = _imgWidth - _outlineRectThick.x - _displayRects[CROP_RIGHT].width;
			_outlineRectThick.height = _imgHeight - _outlineRectThick.y - _displayRects[CROP_BOTTOM].height;
			
			_outlineRectThin.x = _displayRects[CROP_LEFT].width;
			_outlineRectThin.y = _displayRects[CROP_TOP].height;
			_outlineRectThin.width = _imgWidth - _outlineRectThin.x - _displayRects[CROP_RIGHT].width;
			_outlineRectThin.height = _imgHeight - _outlineRectThin.y - _displayRects[CROP_BOTTOM].height;
			
			//Position and size the horizontal and vertical grid lines
			var thirdWidth:Number = (_imgWidth - _displayRects[CROP_LEFT].width - _displayRects[CROP_RIGHT].width) / 3.0;
			var thirdHeight:Number = (_imgHeight - _displayRects[CROP_TOP].height - _displayRects[CROP_BOTTOM].height) / 3.0;
			//Horizontal top
			_gridLines[0].x = _displayRects[CROP_LEFT].width + 1;
			_gridLines[0].y = _displayRects[CROP_TOP].height + thirdHeight;
			_gridLines[0].width = thirdWidth * 3 - 1;
			_gridLines[4].x = _displayRects[CROP_LEFT].width + 1;
			_gridLines[4].y = _displayRects[CROP_TOP].height + thirdHeight;
			_gridLines[4].width = thirdWidth * 3 - 1;
			
			//Horizontal bottom
			_gridLines[1].x = _displayRects[CROP_LEFT].width + 1;
			_gridLines[1].y = _displayRects[CROP_TOP].height + thirdHeight * 2;
			_gridLines[1].width = thirdWidth * 3 - 1;
			_gridLines[5].x = _displayRects[CROP_LEFT].width + 1;
			_gridLines[5].y = _displayRects[CROP_TOP].height + thirdHeight * 2;
			_gridLines[5].width = thirdWidth * 3 - 1;
			
			//Vertical left
			_gridLines[2].y = _displayRects[CROP_TOP].height + 1;
			_gridLines[2].x = _displayRects[CROP_LEFT].width + thirdWidth;
			_gridLines[2].height = thirdHeight * 3 - 1;
			_gridLines[6].y = _displayRects[CROP_TOP].height + 1;
			_gridLines[6].x = _displayRects[CROP_LEFT].width + thirdWidth;
			_gridLines[6].height = thirdHeight * 3 - 1;
			
			//Vertical right
			_gridLines[3].y = _displayRects[CROP_TOP].height + 1;
			_gridLines[3].x = _displayRects[CROP_LEFT].width + thirdWidth * 2;
			_gridLines[3].height = thirdHeight * 3 - 1;
			_gridLines[7].y = _displayRects[CROP_TOP].height + 1;
			_gridLines[7].x = _displayRects[CROP_LEFT].width + thirdWidth * 2;
			_gridLines[7].height = thirdHeight * 3 - 1;
			
			
			var outlineRectScaled:Rectangle = new Rectangle(_outlineRectThick.x * _creator.host.currentZoom,
															_outlineRectThick.y * _creator.host.currentZoom,
															_outlineRectThick.width * _creator.host.currentZoom,
															_outlineRectThick.height * _creator.host.currentZoom); 
			//Position the rectangles that make up the corner cropping 'graphics'
			//Top left
			_cornerRects[0].x = outlineRectScaled.x - (CropModule.LINE_PRESS_TOLERANCE / 6.0);
			_cornerRects[0].y = outlineRectScaled.y - (CropModule.LINE_PRESS_TOLERANCE / 6.0);
			_cornerRects[1].x = outlineRectScaled.x - (CropModule.LINE_PRESS_TOLERANCE / 6.0);
			_cornerRects[1].y = outlineRectScaled.y - (CropModule.LINE_PRESS_TOLERANCE / 6.0);
			
			//Top right
			_cornerRects[2].x = outlineRectScaled.x + outlineRectScaled.width - (CropModule.LINE_PRESS_TOLERANCE / 2.0);
			_cornerRects[2].y = outlineRectScaled.y - (CropModule.LINE_PRESS_TOLERANCE / 6.0);
			_cornerRects[3].x = outlineRectScaled.x + outlineRectScaled.width;
			_cornerRects[3].y = outlineRectScaled.y - (CropModule.LINE_PRESS_TOLERANCE / 6.0);
			
			//Bottom left
			_cornerRects[4].x = outlineRectScaled.x - (CropModule.LINE_PRESS_TOLERANCE / 6.0);
			_cornerRects[4].y = outlineRectScaled.y + outlineRectScaled.height;
			_cornerRects[5].x = outlineRectScaled.x - (CropModule.LINE_PRESS_TOLERANCE / 6.0);
			_cornerRects[5].y = outlineRectScaled.y + outlineRectScaled.height - (CropModule.LINE_PRESS_TOLERANCE / 2.0);
			
			//Bottom right
			_cornerRects[6].x = outlineRectScaled.x + outlineRectScaled.width - (CropModule.LINE_PRESS_TOLERANCE / 2.0);
			_cornerRects[6].y = outlineRectScaled.y + outlineRectScaled.height;
			_cornerRects[7].x = outlineRectScaled.x + outlineRectScaled.width;
			_cornerRects[7].y = outlineRectScaled.y + outlineRectScaled.height - (CropModule.LINE_PRESS_TOLERANCE / 2.0);
		}
		
		public function setActive(val:Boolean, host:ImageModuleHost):void
		{
			
		}
		
		public function setProperty(propName:String, value:*):void
		{
			if(propName == CROP_LEFT)
			{
				_leftCrop = value;
				_displayRects[CROP_LEFT].width = value;
				
				_displayRects[CROP_TOP].x = value;
				_displayRects[CROP_TOP].width = _imgWidth - _displayRects[CROP_LEFT].width - _displayRects[CROP_RIGHT].width;
				_displayRects[CROP_BOTTOM].x = value;
				_displayRects[CROP_BOTTOM].width = _imgWidth - _displayRects[CROP_LEFT].width - _displayRects[CROP_RIGHT].width;
				updateDisplayGrid(_imgWidth, _imgHeight);
				_creator.host.notifyImageEffectChanged(this);
			}
			else if(propName == CROP_RIGHT)
			{
				_rightCrop = value;
				_displayRects[CROP_RIGHT].width = value;
				_displayRects[CROP_RIGHT].x = _imgWidth - value;
				
				_displayRects[CROP_TOP].width = _imgWidth - _displayRects[CROP_LEFT].width - _displayRects[CROP_RIGHT].width;
				_displayRects[CROP_BOTTOM].width = _imgWidth - _displayRects[CROP_LEFT].width - _displayRects[CROP_RIGHT].width;
				updateDisplayGrid(_imgWidth, _imgHeight);
				_creator.host.notifyImageEffectChanged(this);
			}
			else if(propName == CROP_TOP)
			{
				_topCrop = value;
				_displayRects[CROP_TOP].height = value;		
				updateDisplayGrid(_imgWidth, _imgHeight);
				_creator.host.notifyImageEffectChanged(this);	
			}
			else if(propName == CROP_BOTTOM)
			{
				_bottomCrop = value;
				_displayRects[CROP_BOTTOM].height = value;
				_displayRects[CROP_BOTTOM].y = _imgHeight - value;
				updateDisplayGrid(_imgWidth, _imgHeight);
				_creator.host.notifyImageEffectChanged(this);
			}
		}
		
		public function showOnImage(image:EditImage):void
		{
			for each(var rect:Rect in _displayRects)
			{
				rect.fill = EDIT_FILL;
			}
			
			if(!_added)
			{
				image.effectOverlay.addElement(_displayRects[CROP_LEFT]);
				image.effectOverlay.addElement(_displayRects[CROP_RIGHT]);
				image.effectOverlay.addElement(_displayRects[CROP_TOP]);
				image.effectOverlay.addElement(_displayRects[CROP_BOTTOM]);
				_added = true;
			}
			
			image.effectOverlay.addElement(_outlineRectThick);
			
			for each(var l:Line in _gridLines)
				image.effectOverlay.addElement(l);
				
			image.effectOverlay.addElement(_outlineRectThin);
			
			for each(var r:Rect in _cornerRects)
				image.uiOverlay.addElement(r);
		}
		
		public function removeFromImage(image:EditImage):void
		{
			for each(var rect:Rect in _displayRects)
			{
				rect.fill = DISPLAY_FILL;
			}
			
			image.effectOverlay.removeElement(_outlineRectThick);
			for each(var l:Line in _gridLines)
				image.effectOverlay.removeElement(l);
			image.effectOverlay.removeElement(_outlineRectThin);
			for each(var r:Rect in _cornerRects)
				image.uiOverlay.removeElement(r);
			/*image.effectOverlay.removeElement(_displayRects[CROP_LEFT]);
			image.effectOverlay.removeElement(_displayRects[CROP_RIGHT]);
			image.effectOverlay.removeElement(_displayRects[CROP_TOP]);
			image.effectOverlay.removeElement(_displayRects[CROP_BOTTOM]);*/
		}
	
		public function applyToBitmapData(data:BitmapData):void
		{
			var srcRect:Rectangle = new Rectangle(_leftCrop, _topCrop, 
													data.width - leftCrop - _rightCrop,
													data.height - _bottomCrop - topCrop);
			var destPoint:Point = new Point(_leftCrop, _topCrop);
			
			//Create a blank bitmap and copy target pixels into the new bitmap
			var newBitmap:BitmapData = new BitmapData(data.width, data.height, false, 0xFFFFFF);
			newBitmap.copyPixels(data, srcRect, destPoint);
			
			//Copy the new bitmap data back to apply it.
			data.copyPixels(newBitmap, data.rect, new Point());
							
		}
		
		public function isAfterEffect():Boolean
		{
			return true;
		}
		
		public function getClassification():String
		{
			return "crop";
		}
		
		public function get parentModule():ImageEditModule
		{
			return _creator;
		}
		
		public function set parentModule(value:ImageEditModule):void
		{
			this._creator = value as CropModule;
		}

		public function get leftCrop():Number
		{
			return _leftCrop;
		}

		public function set leftCrop(value:Number):void
		{
			_leftCrop = value;
		}

		public function get rightCrop():Number
		{
			return _rightCrop;
		}

		public function set rightCrop(value:Number):void
		{
			_rightCrop = value;
		}

		public function get topCrop():Number
		{
			return _topCrop;
		}

		public function set topCrop(value:Number):void
		{
			_topCrop = value;
		}

		public function get bottomCrop():Number
		{
			return _bottomCrop;
		}

		public function set bottomCrop(value:Number):void
		{
			_bottomCrop = value;
		}


	}
}