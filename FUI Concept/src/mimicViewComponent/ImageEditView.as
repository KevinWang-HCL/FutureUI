package mimicViewComponent
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEffect;
	import MimicPlugin.ImageModuleHost;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.GesturePhase;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.layouts.BasicLayout;
	
	[Event(name="viewReady", type="flash.events.Event")]
	[Bindable]
	public class ImageEditView extends Group implements ImageModuleHost
	{
		public static const VIEW_READY_EVENT:String = "viewReady";

		private static const BORDER_WIDTH:Number = 5;
		public static var MINIMUM_ZOOM_FACTOR:Number = 0.25;
		public static var MAXIMUM_ZOOM_FACTOR:Number = 3.00;
	
		private var _image:EditImage;
		private var _instructionLabel:Label;
		
		private var _prevMouseLocation:Point;
		
		private var _currentBounds:Rectangle;
		private var _viewport:Rectangle;
		private var _zoomPercentage:Number;
		
		private var _pluginList:ImageEditPluginList;
		private var _activeModule:ImageEditModule;
		private var _modules:Vector.<ImageEditModule>;
		private var _activeEffects:Vector.<ImageEffect>;
		
		private var _cachedFinalData:BitmapData;
		private var _imageChanged:Boolean;
		
		private var _zoomActive:Boolean;
		private var _zoomEnabled:Boolean;
		private var _panningEnabled:Boolean;
		private var _touchDown:Boolean;
		private var _resetZoomEnabled:Boolean;
		private var _rotateActive:Boolean = false;
		
		public function ImageEditView()
		{
			this.layout = new BasicLayout();
			
			//this.setStyle("skinClass", ImageEditorSkin);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			this.doubleClickEnabled = true;
			this.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			this.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onZoomHandler);
			//this.addEventListener(TransformGestureEvent.GESTURE_ROTATE, onRotateHandler);
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			this.addEventListener(Event.RESIZE, onResize);
			this.mouseChildren = false;
			_prevMouseLocation = new Point();
			_activeEffects = new Vector.<ImageEffect>();
			_modules = new Vector.<ImageEditModule>();
			
			_currentBounds = new Rectangle();
			_viewport = new Rectangle();
			
			_panningEnabled = true;
			_zoomEnabled = true;
			_zoomActive = false;
			_imageChanged = true;
			_resetZoomEnabled = true;
			_touchDown = false;
			
			_pluginList = new ImageEditPluginList(this);
			//this._activeModule = _pluginList.getPluginAt(0).getEditModule();
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			_image = new EditImage();
			_image.addEventListener(EditImage.IMAGE_READY, imageReady);
			_image.addEventListener(EditImage.ZOOM_FACTOR_CHANGED, onZoomChanged);
			this.addEventListener(MouseEvent.CLICK, onClick);
			this.addElement(_image);	
			
			_instructionLabel = new Label();
			_instructionLabel.visible = false;
			_instructionLabel.text = "Tap to exit";
			_instructionLabel.setStyle("fontSize", 20);
			this.addElement(_instructionLabel);
		}
		
		protected function onCreationComplete(evt:FlexEvent):void
		{
			_image.x = BORDER_WIDTH;
			_image.y = BORDER_WIDTH;
			_image.width = this.width - BORDER_WIDTH * 2.0;
			_image.height = this.height - BORDER_WIDTH * 2.0;
		}
		
		protected function onClick(evt:MouseEvent):void
		{
			if(!_activeModule)
				this.dispatchEvent(new Event(FinishingView.MIMIC_CLICK_EVENT, true));
		}
		
		protected function onResize(evt:Event):void
		{
			_image.width = this.width - BORDER_WIDTH * 2.0;
			_image.height = this.height - BORDER_WIDTH * 2.0;
			createMask();
		}
		
		protected function positionInstructionLabel()
		{
			var zoomedWidth:Number = _image.originalBounds.width * _image.currentZoomFactor;
			var zoomedHeight:Number = _image.originalBounds.height * _image.currentZoomFactor;
			var labelX:Number = (_image.width - _instructionLabel.width) / 2.0;
			var labelY:Number = ((_image.height - zoomedHeight) / 2.0) + zoomedHeight - 1;
			_instructionLabel.x = labelX
			_instructionLabel.y = labelY;
			_instructionLabel.visible = true;
			
		}
		
		protected function onZoomHandler(event:TransformGestureEvent):void
		{
			if(_zoomEnabled && _activeModule)
			{
				if(event.phase == GesturePhase.BEGIN)
				{
					_zoomActive = true;
					_image.imageSmoothed = false;
				}
				else if(event.phase == GesturePhase.UPDATE)
				{
					//trace("ZOOMING..." + event.scaleX + ", " + event.scaleY);
					_image.setZoomFactor( (event.scaleX < 1.0 || event.scaleY < 1.0) ? _image.currentZoomFactor - 0.02 : _image.currentZoomFactor + 0.02 );
				}
				else if(event.phase == GesturePhase.END)
				{
					_image.handleZoomFinished();
					_zoomActive = false;
					_image.imageSmoothed = true;
				}
			}
		}
		
		protected function onRotateHandler(event:TransformGestureEvent):void
		{
			//if(!_zoomActive)
			//{
				if(event.phase == GesturePhase.BEGIN)
				{
					_rotateActive = true;
				}
				else if(event.phase == GesturePhase.UPDATE)
				{
					//trace("ROTATING..." + event.rotation);	
				}
				else if(event.phase == GesturePhase.END)
				{
					_rotateActive = false;
				}
			//}
		}
		
		private function onZoomChanged(event:Event):void
		{
			if(_activeModule)
				_activeModule.handleZoomed(this);
			else
				positionInstructionLabel();
		}
		
		private function createMask():void
		{
			var maskRect:Shape = new Shape();
			var g:Graphics = maskRect.graphics;
			g.beginFill(0xFFFFFF, 1.0);
			//g.drawRect(BORDER_WIDTH, -58 + BORDER_WIDTH, this.width - BORDER_WIDTH * 2.0, this.height - BORDER_WIDTH * 2.0 + 58);
			g.drawRect(0, -58, this.width , this.height + 58);
			g.endFill();
			this.mask = maskRect;
		}
		
		private function imageReady(evt:Event):void
		{
			trace("IMAGE EDIT VIEW IMAGE READY");
			_image.setZoomFactor(MINIMUM_ZOOM_FACTOR);
			createMask();
			//resetState();
			
			this.dispatchEvent(new Event(VIEW_READY_EVENT));
			this.invalidateDisplayList();
		}
		
		public function hasImageEffect(effect:ImageEffect):Boolean
		{
			for each(var eff:ImageEffect in _activeEffects)
			{
				if(eff == effect)
					return true;
			}
			
			return false;
		}
		
		public function applyImageEffect(effect:ImageEffect):void
		{
			var added:Boolean = false;
			
			for(var i:int = 0; i < _activeEffects.length; i++)
			{
				if(_activeEffects[i] == effect)
					return;
				
				if(_activeEffects[i].getClassification() == effect.getClassification())
				{
					//Remove old effect and somehow notify its plugin that it is no longer active. 
					var oldEffect:ImageEffect = _activeEffects[i];
					oldEffect.removeFromImage(_image);
					oldEffect.parentModule.notifyEffectRemoved(oldEffect);
					_activeEffects[i] = effect;
					added = true;
				}
			}
			
			if(!added)
			{
				_activeEffects.push(effect);
			}
			
			effect.showOnImage(_image);
			_imageChanged = true;
		}
		
		public function removeImageEffect(effect:ImageEffect):void
		{
			var index:int = _activeEffects.indexOf(effect);
			_activeEffects.splice(index, 1);
			effect.removeFromImage(_image);
			_imageChanged = true;
		}
		
		public function notifyImageEffectChanged(effect:ImageEffect):void
		{
			_imageChanged = true;
		}
		
		public function addUILayerElement(elem:IVisualElement):void
		{
			_image.uiOverlay.addElement(elem);
		}
		
		public function removeUILayerElement(elem:IVisualElement):void
		{
			_image.uiOverlay.removeElement(elem);	
		}
		
		private function onDoubleClick(evt:MouseEvent):void
		{
			
			//else
			//{
				var ime:ImageMouseEvent = new ImageMouseEvent(evt);
				ime.scaledImageCoord = _image.transformMouseToImageCoordinates(evt.stageX, evt.stageY);
				_activeModule.handleDoubleClick(ime);
			//}
				if(_resetZoomEnabled)
				{
					_image.restoreImagePositionAndScale();
				}
		}
		
		private function onMouseDown(evt:MouseEvent):void
		{
			_touchDown = true;
			if(!_zoomActive)
			{
				var ime:ImageMouseEvent = new ImageMouseEvent(evt);
				ime.scaledImageCoord = _image.transformMouseToImageCoordinates(evt.stageX, evt.stageY);
				
				if(_activeModule)
					_activeModule.handleMouseDown(ime);
				
				_prevMouseLocation.x = evt.stageX;
				_prevMouseLocation.y = evt.stageY;
			}
		}
		
		private function onMouseMove(evt:MouseEvent):void
		{
			if(!_zoomActive && _panningEnabled && _touchDown)
			{
				if(_image.imageSmoothed)
					_image.imageSmoothed = false;
				
				_image.pan(evt.stageX - _prevMouseLocation.x, evt.stageY - _prevMouseLocation.y);
				_prevMouseLocation.x = evt.stageX;
				_prevMouseLocation.y = evt.stageY;
			}
			else
			{
				var ime:ImageMouseEvent = new ImageMouseEvent(evt);
				ime.scaledImageCoord = _image.transformMouseToImageCoordinates(evt.stageX, evt.stageY);
				if(_activeModule)
					_activeModule.handleMouseMove(ime);
			}
		}
	
		private function onMouseUp(evt:MouseEvent):void
		{
			_image.imageSmoothed = true;
			if(!_zoomActive)
			{
				var ime:ImageMouseEvent = new ImageMouseEvent(evt);
				ime.scaledImageCoord = _image.transformMouseToImageCoordinates(evt.stageX, evt.stageY);
				if(_activeModule)
					_activeModule.handleMouseUp(ime);
			}
			_touchDown = false;
		}
		
		private function onMouseOut(evt:MouseEvent):void
		{
			_image.imageSmoothed = true;
			_touchDown = false;
			
			if(!_zoomActive)
			{
				var pMin:Point = _image.localToGlobal(new Point());
				var pMax:Point = _image.localToGlobal(new Point(_image.width, _image.height));
				
				if(evt.stageX < pMin.x || evt.stageX > pMax.x || evt.stageY < pMin.y || evt.stageY > pMax.y)
				{
					var ime:ImageMouseEvent = new ImageMouseEvent(evt);
					ime.scaledImageCoord = _image.transformMouseToImageCoordinates(evt.stageX, evt.stageY);
					if(_activeModule)
						_activeModule.handleMouseUp(ime);
				}
			}
		}
		
		public function get image():EditImage
		{
			return _image;
		}
		
		public function set image(value:*):void
		{
			_image.imageSource = value;
			_imageChanged = true;
		}
		
		public function cacheImageFilterState():void
		{
			_image.cacheImageWithFilters();
		}
		
		public function useCachedFilteredImage(b:Boolean):void
		{
			_image.useCachedImageAsSource = b;
		}
		
		public function usingCachedFilteredImage():Boolean
		{
			return _image.useCachedImageAsSource;
		}
		
		/**
		 * Function to update the cached image without reapplying the effect.
		 */
		public function updateCachedImage(updatedFilters:Array):void
		{
			_image.updateCachedImage(updatedFilters);
			_imageChanged = true;
		}
		
		public function get cachedFilters():Array
		{
			return _image.cachedFilters;
		}
		
		public function finalBitmapData():BitmapData
		{
			if(!_imageChanged)
			{
				trace("RETURNING CACHED DATA.");
				return _cachedFinalData;
			}

			//Create a bitmap data object reflecting the current bitmap data w/ cropping applied.
			var newData:BitmapData = _image.baseImage.bitmapData.clone();
			
			for(var i:int = 0; i < _activeEffects.length; i++)
			{
				_activeEffects[i].applyToBitmapData(newData);
			}
			
			_cachedFinalData = newData;
			_imageChanged = false;
			
			return newData;
		}
		
		public function setActiveEditModule(module:ImageEditModule):void
		{
			if(_activeModule)
				_activeModule.madeInactive(this);
			
			_activeModule = module;
			
			if(module) //if we haven't set _activeModule to null
			{
				_activeModule.madeActive(this);
				_instructionLabel.visible = false;
			}
		}
		
		public function get imageBounds():Rectangle
		{
			return _image.originalBounds.toRectangle();
		}
		
		public function get zoomPercentage():Number
		{
			return _zoomPercentage;	
		}
		
		public function set zoomPercentage(value:Number):void
		{
			if(value >= (MINIMUM_ZOOM_FACTOR*100.0) && value <= (MAXIMUM_ZOOM_FACTOR*100.0))
			{
				_zoomPercentage = value;	
				_image.setZoomFactor(value / 100.0);
			}
		}
		
		public function get resetZoomEnabled():Boolean
		{
			return _resetZoomEnabled;
		}
		
		public function set resetZoomEnabled(value:Boolean):void
		{
			_resetZoomEnabled = value;
		}
		
		public function get zoomEnabled():Boolean
		{
			return _zoomEnabled;
		}
		
		public function set zoomEnabled(value:Boolean):void
		{
			_zoomEnabled = value;
		}
		
		public function get panningEnabled():Boolean
		{
			return _panningEnabled;
		}
		
		public function set panningEnabled(value:Boolean):void
		{
			_panningEnabled = value;
		}

		public function get pluginList():ImageEditPluginList
		{
			return _pluginList;
		}

		public function set pluginList(value:ImageEditPluginList):void
		{
			_pluginList = value;
		}

		public function get currentZoom():Number
		{
			return _image.currentZoomFactor;
		}
		
		public function resetState():void
		{
			//_activeModule = _pluginList.getPluginAt(0).getEditModule();
			if(_activeModule)
				_activeModule.madeInactive(this);
			_activeModule = null;
			_imageChanged = true;
			_activeEffects = new Vector.<ImageEffect>();
			
			//Really each module should be in charge of removing its UI elements & filters.
			_image.filters = [];
			_image.uiOverlay.removeAllElements();
			
			for(var i:int = 0; i < _pluginList.numPlugins; i++)
			{
				_pluginList.getPluginAt(i).getEditModule().reset();
				_pluginList.getPluginAt(i).getEditModuleUI().reset();
			}
		}
		
	}
}