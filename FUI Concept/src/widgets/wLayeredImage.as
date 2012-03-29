package widgets
{
	import flash.events.Event;
	
	import spark.components.Group;
	import spark.components.Image;
	import spark.layouts.BasicLayout;

	[Bindable]
	public class wLayeredImage extends Group
	{
		public static var TOP:uint=0;
		public static var MIDDLE:uint=1; 
		public static var BOTTOM:uint=2;
		public static var LEFT:uint=3; 
		public static var CENTRE:uint=4; 
		public static var RIGHT:uint=5;
		
		private var _xAlignment:uint, _yAlignment:uint;
		private var _images:Vector.<Image>
		private var _imageSources:Array;
		private var _numImagesLoaded:uint;
		
		private var _xAlignChanged:Boolean, _yAlignChanged:Boolean, _imagesChanged:Boolean;
		public function wLayeredImage()
		{
			super();
			this.cacheAsBitmap = true;
			this.layout = new BasicLayout();
			
			xAlignment = CENTRE;
			yAlignment = MIDDLE;
			_images = new Vector.<Image>();
			this.addEventListener(Event.RESIZE, onResize);
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
		}
		
		protected override function commitProperties():void
		{
			super.commitProperties();
			
			if(_imagesChanged)
			{
				_numImagesLoaded = 0;
				for(var i:int = 0; i < _imageSources.length; i++)
				{
					if(i < _images.length)
					{
						_images[i].source = _imageSources[i];
					}
					else
					{
						_images[i] = new Image();
						//_images[i].cacheAsBitmap = true;
						_images[i].source = _imageSources[i];
						_images[i].addEventListener(Event.COMPLETE, function(event:Event):void {
							_numImagesLoaded++;
							if(_numImagesLoaded == _images.length)
								onAllImagesLoaded();
						});
						this.addElement(_images[i]);
					}
				}
				
				//Remove any remaining images that shouldn't be shown
				if(i < _images.length)
				{
					while(i != _images.length)
					{
						this.removeElement(_images.pop());
						i++;
					}
				}
				
				_imagesChanged = false;	
			}
			if(_xAlignChanged)
			{
				if(_images.length > 0 && _numImagesLoaded == _images.length)
					alignImagesX();
				_xAlignChanged = false;
			}
			if(_yAlignChanged)
			{
				if(_images.length > 0 && _numImagesLoaded == _images.length)
					alignImagesY();
				_yAlignChanged = false;
			}
		}
		
		private function onResize(event:Event):void
		{
			alignImagesX();
			alignImagesY();
		}
		
		private function onAllImagesLoaded():void
		{
			alignImagesX();
			alignImagesY();
		}
		
		private function alignImagesX():void
		{
			for(var i:int = 0; i < _images.length; i++)
			{
				if(_xAlignment == LEFT)
					_images[i].x = 0;
				else if(_xAlignment == CENTRE)
					_images[i].x = (this.width/2) - (_images[i].bitmapData.width/2);
				else if(_xAlignment == RIGHT)
					_images[i].x = this.width - _images[i].bitmapData.width;
			}
		}
		
		private function alignImagesY():void
		{
			for(var i:int = 0; i < _images.length; i++)
			{	
				if(_yAlignment == TOP)
					_images[i].y = 0;
				else if(_yAlignment == MIDDLE)
					_images[i].y = (this.height/2) - (_images[i].bitmapData.height / 2);	
				else if(_yAlignment == BOTTOM)
					_images[i].y = this.height - _images[i].bitmapData.height;
			}
		}
		
		/*
		 * PROPERTY SETTERS AND GETTERS
		 */
		public function get xAlignment():uint
		{
			return this._xAlignment;
		}
		
		public function set xAlignment(value:uint):void
		{
			_xAlignment = value;
			_xAlignChanged = true;
			this.invalidateProperties();
		}
		
		public function get yAlignment():uint
		{
			return this._yAlignment;	
		}
		
		public function set yAlignment(value:uint):void
		{
			_yAlignment = value;
			_yAlignChanged = true;
			this.invalidateProperties();
		}

		public function get images():Array
		{
			return _imageSources;
		}

		public function set images(value:Array):void
		{
			_imageSources = value;
			_imagesChanged = true;
			this.invalidateProperties();
		}

		
	}
}