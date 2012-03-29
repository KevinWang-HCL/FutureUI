package mimicViewComponent
{
	import MimicPlugin.ImageEffect;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import integration.ApplicationSettings;
	
	import mx.events.FlexEvent;
	import mx.graphics.BitmapFillMode;
	
	import spark.components.Group;
	import spark.components.SkinnableContainer;
	import spark.layouts.BasicLayout;
	import spark.primitives.BitmapImage;
	
	[Event(name="imageReady", type="flash.events.Event")]
	[Event(name="zoomFactorChanged", type="flash.events.Event")]
	public class EditImage extends SkinnableContainer
	{
		public static const IMAGE_READY:String = "imageReady";
		public static const ZOOM_FACTOR_CHANGED:String = "zoomFactorChanged";
		
		private static const PAN_SPEED:Number = 2.0;
		
		private var _image:BitmapImage;
		private var _originalImageData:BitmapData;
		
		private var _useCachedImageAsSource:Boolean;
		private var _cachedImageData:BitmapData;
		private var _cachedFilterEffects:Array;
		
		private var _originalImageBounds:ImageRectangle; //Uses an image rectangle so it can be bound
		private var _imageEffects:Vector.<ImageEffect>;
		private var _effectLayer:Group;
		private var _uiLayer:Group;
		
		private var _minimumZoom:Number;
		private var _currentZoom:Number;
		private var _maximumZoom:Number;
		private var _fitToZoom:Number;
		
		private var _normalisedOffsetX:Number;
		private var _normalisedOffsetY:Number;
		
		public function EditImage()
		{
			super();
			_imageEffects = new Vector.<ImageEffect>();
			this.setStyle("backgroundAlpha", 0.0);
			_minimumZoom = ImageEditView.MINIMUM_ZOOM_FACTOR;
			_maximumZoom = ImageEditView.MAXIMUM_ZOOM_FACTOR;
			_currentZoom = 1.0;
			this.layout = new BasicLayout();
			this.addEventListener(Event.RESIZE, onResize);
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			_image = new BitmapImage();
			_image.id = "mimicImage";
			_image.fillMode = BitmapFillMode.CLIP;
			_image.smooth = false;
			_image.addEventListener(FlexEvent.READY, onImageReady);
			this.addElement(_image);
			
			_originalImageBounds = new ImageRectangle();
			
			_effectLayer = new Group();
			this.addElement(_effectLayer);
			
			_uiLayer = new Group();
			this.addElement(_uiLayer);
		}
		
		private function onImageReady(evt:FlexEvent):void
		{
			_originalImageData = _image.bitmapData.clone();
			_originalImageBounds.width = _image.bitmapData.width;
			_originalImageBounds.height = _image.bitmapData.height;
			_cachedImageData = _image.bitmapData.clone();
			_image.filters = _cachedFilterEffects;
			//cacheImageWithFilters();
			//Converts the pixel bounds into millimetre dimensions using 
			var dpi:Number = ApplicationSettings.get().get(ApplicationSettings.PRESCAN_DPI);
			
			_effectLayer.width = _originalImageBounds.width;
			_effectLayer.height = _originalImageBounds.height;
			
			_uiLayer.width = _originalImageBounds.width;
			_uiLayer.height = _originalImageBounds.height;

			_image.x = (this.width - _originalImageBounds.width) / 2.0;
			_image.y = (this.height - _originalImageBounds.height) / 2.0;
			
			_normalisedOffsetX = 0.5;
			_normalisedOffsetY = 0.5;
			
			calcFitToZoom();
			
			this.dispatchEvent(new Event(IMAGE_READY));
		}
		
		private function onResize(evt:Event):void
		{
			//var cachedZoom:Number = _currentZoom;
			var oldFitToZoom:Number = _fitToZoom;
			calcFitToZoom();
			
			//if(oldFitToZoom == _currentZoom)
				restoreImagePositionAndScale();
			//restoreImagePositionAndScale();
			//setZoomFactor(cachedZoom);
		}
		
		private function calcFitToZoom():void
		{
			//We want to calculate the zoom factor based off the smallest dimension
			//of space available (probably the height if a resolution of 1024 by 600 
			//is used).
			if(this.width > this.height)
				_fitToZoom = this.height / _originalImageBounds.height;
			else
				_fitToZoom = this.width / _originalImageBounds.width;
			
			_fitToZoom -= 0.045; //Arbitrary small amount to give a bit of a margin around the image and to
								 //account for ui effects such as crop handles. Should really be more calculated.
			_minimumZoom = _fitToZoom;
		}
		
		public function setZoomFactor(zf:Number):void
		{
			if(zf >= _minimumZoom && zf <= _maximumZoom)
			{
				_currentZoom = zf;
				
				_image.scaleX = zf;
				_image.scaleY = zf;
				_effectLayer.scaleX = zf;
				_effectLayer.scaleY = zf;
				_uiLayer.width = _originalImageBounds.width * zf;
				_uiLayer.height = _originalImageBounds.height * zf;
				positionImage();
				this.dispatchEvent(new Event(ZOOM_FACTOR_CHANGED));
			}
		}
		
		public function handleZoomFinished():void
		{
			if(_originalImageBounds.width * _currentZoom < this.width)
				_normalisedOffsetX = 0.5;
			if(_originalImageBounds.height * _currentZoom < (this.height + 58))
				_normalisedOffsetY = 0.5;
			positionImage();	
		}
		
		public function cacheImageWithFilters():void
		{
			_cachedImageData = _originalImageData.clone();
			
			var filters:Array = _useCachedImageAsSource ? _cachedFilterEffects : _image.filters;
			
			if(filters)
			{
				for(var i:int = 0; i < filters.length; i++)
				{
					_cachedImageData.applyFilter(_cachedImageData, _cachedImageData.rect, new Point(), filters[i]);
				}
				if(!_useCachedImageAsSource)
					_cachedFilterEffects = _image.filters;
			}
		}
		
		public function updateCachedImage(updatedFilters:Array):void
		{
			_cachedImageData = _originalImageData.clone();
			for(var i:int = 0; i < updatedFilters.length; i++)
			{
				_cachedImageData.applyFilter(_cachedImageData, _cachedImageData.rect, new Point(), updatedFilters[i]);
			}
			_cachedFilterEffects = updatedFilters;
			_image.removeEventListener(FlexEvent.READY, onImageReady);
			_image.addEventListener(FlexEvent.READY, onCachedImageReady);
			_image.source = _cachedImageData;
		}
		
		public function get useCachedImageAsSource():Boolean
		{
			return _useCachedImageAsSource;
		}
		
		public function set useCachedImageAsSource(value:Boolean):void
		{
			if(_useCachedImageAsSource != value)
			{
				_useCachedImageAsSource = value;
				
				_image.removeEventListener(FlexEvent.READY, onImageReady);
				_image.addEventListener(FlexEvent.READY, onCachedImageReady);
				if(_useCachedImageAsSource)
				{
					_image.source = _cachedImageData;
					_image.filters = null;
				}
				else
				{
					_image.source = _originalImageData;
					_image.filters = _cachedFilterEffects;
				}
			}			
		}
		
		public function onCachedImageReady(evt:FlexEvent):void
		{
			_image.removeEventListener(FlexEvent.READY, onCachedImageReady);
			_image.addEventListener(FlexEvent.READY, onImageReady);
		}
		
		public function get cachedFilters():Array
		{
			return _cachedFilterEffects;
		}
		
		/*
		 * Function that zooms the editing image to the maximum possible size whilst
		 * maintaining its aspect ratio and with none of the image clipped.
		 */
		public function restoreImagePositionAndScale():void
		{
			setZoomFactor(_fitToZoom);
			_normalisedOffsetX = 0.5;
			_normalisedOffsetY = 0.5;
			positionImage();	
			_image.smooth = true;
		}
		
		public function pan(dirX:Number, dirY:Number):void
		{
			if(_currentZoom > _fitToZoom)
			{
				//trace(dirX + ", " + dirY + " : " + scaledPanSpeed + ", " + normalisedDirectionX + ", " + normalisedDirectionY);
				//The image can only pan in the x axis if the current zoomed image is larger than
				//its available screen space.
				if(_originalImageBounds.width * _currentZoom > this.width)
				{
					var normalisedBorderX:Number = (this.width / 2.0 - 45) / (_originalImageBounds.width * _currentZoom);
					//trace("normalised border x: " + normalisedBorderX);
					var normalisedDirectionX:Number = Math.abs(dirX) / (_originalImageBounds.width * _currentZoom);
					if(dirX < 0 && _normalisedOffsetX + normalisedDirectionX <= 1.0 - normalisedBorderX)
						_normalisedOffsetX += normalisedDirectionX;
					else if(dirX > 0 && _normalisedOffsetX - normalisedDirectionX >= normalisedBorderX)
						_normalisedOffsetX -= normalisedDirectionX;
				}
				
				//Like above, the image can only pan along the y axis if it is larger than its available vertical screen
				//space. 
				//Note: The +58 is a hack to account for the navigation bar at the top, as the image should extend through it
				//		it counts towards the vertical screen space of the image.
				if(_originalImageBounds.height * _currentZoom > (this.height + 58))
				{
					var normalisedBorderY:Number = (this.height / 2.0 - 45) / (_originalImageBounds.height * _currentZoom); //(+13 = 58(navbar) - 45(border))
					//trace("normalised border y: " + normalisedBorderY);
					var normalisedDirectionY:Number = Math.abs(dirY) / (_originalImageBounds.height * _currentZoom);
					if(dirY < 0 && _normalisedOffsetY + normalisedDirectionY <= 1.0 - normalisedBorderY)
						_normalisedOffsetY += normalisedDirectionY;
					else if(dirY > 0 && _normalisedOffsetY - normalisedDirectionY >= normalisedBorderY)
						_normalisedOffsetY -= normalisedDirectionY;
				}
			
				//trace(_normalisedOffsetX + " // " + _normalisedOffsetY);
				positionImage();
			}
		}
		
		private function positionImage():void
		{
			var newPosX:Number = (this.width / 2.0) - (_originalImageBounds.width * _currentZoom * _normalisedOffsetX);
			//13 is an arbitrary upward shift to move the image away from the UI at the bottom of the screen.
			var newPosY:Number = (this.height / 2.0) - (_originalImageBounds.height * _currentZoom * _normalisedOffsetY) - 13;
			_image.x = newPosX; _image.y = newPosY;
			_effectLayer.x = newPosX; _effectLayer.y = newPosY;
			_uiLayer.x = newPosX; _uiLayer.y = newPosY;
		}
		
		//Translates stage mouse coordinates to a position within the image.
		public function transformMouseToImageCoordinates(mx:Number, my:Number):Point
		{
			var start:Point = this.localToGlobal(new Point(_image.x, _image.y));
			var coords:Point = new Point(-1, -1);
			
			//Scaling the coordinates up to normal image bounds is necessary due to the scale factor
			//on each layer element scaling them down again afterwards.
			coords.x = ((mx - start.x) / (_originalImageBounds.width * _currentZoom)) * _originalImageBounds.width;
			coords.y = ((my - start.y) / (_originalImageBounds.height * _currentZoom)) * _originalImageBounds.height;
			return coords;
		}
		
		/**
		 * Returns the base bitmap image component. Used to add effects
		 * to the edit image, where the effect is to be added directly to the bitmap
		 * image component (such as ShaderFilters).
		 */
		public function get baseImage():BitmapImage
		{
			return _image;
		}
		
		/**
		 * Returns the overlay group for effects that - for efficiency reasons - should
		 * not be directly applied to the bitmap image until the last moment when the bitmap
		 * data is compiled for the final composite image.
		 */
		public function get effectOverlay():Group
		{
			return _effectLayer;
		}
		
		/**
		 * Returns the group that contains ui effects or indicators. This is used by plugins that
		 * may - for example - require indicators to be displayed on top of the image (such as a 
		 * crop plugin with crop handles displayed on the very top for user interaction).
		 */
		public function get uiOverlay():Group
		{
			return _uiLayer;
		}
		
		public function get originalBounds():ImageRectangle
		{
			return _originalImageBounds;
		}
		
		public function get activeImageEffects():Vector.<ImageEffect>
		{
			return _imageEffects;
		}
		
		public function set imageSource(value:BitmapData):void
		{
			_image.source = value;
		}
		
		public function get currentZoomFactor():Number
		{
			return _currentZoom;
		}
		
		public function set imageSmoothed(value:Boolean):void
		{
			_image.smooth = value;
		}
		
		public function get imageSmoothed():Boolean
		{
			return _image.smooth;
		}
	}
}