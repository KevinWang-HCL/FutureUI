package ImagePlugins.ColourPlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEffect;
	
	import flash.display.BitmapData;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	
	import mimicViewComponent.EditImage;
	
	public class ColourEffect implements ImageEffect
	{		
		protected var _parentModule:ColourModule;
		protected var _filter:ShaderFilter;
		
		public function ColourEffect()
		{
		}
		
		public function setProperty(propName:String, value:*):void
		{
		}
		
		public function showOnImage(image:EditImage):void
		{
			if(image.useCachedImageAsSource)
				image.useCachedImageAsSource = false;
			
			var filters:Array = image.baseImage.filters;
			filters.push(_filter);
			image.baseImage.filters = filters;
		}
		
		public function removeFromImage(image:EditImage):void
		{
			if(image.useCachedImageAsSource)
				image.useCachedImageAsSource = false;
			
			var filters:Array = image.baseImage.filters;
			var ind:int = filters.indexOf(_filter);
			filters.splice(ind, 1);
			image.baseImage.filters = filters;
		}
		
		public function applyToBitmapData(data:BitmapData):void
		{
			data.applyFilter(data, data.rect, new Point(0, 0), _filter);
		}
		
		public function isAfterEffect():Boolean
		{
			return false;
		}
		
		public function getClassification():String
		{
			return "colourChannel";
		}
		
		public function get parentModule():ImageEditModule
		{
			return _parentModule;
		}
		
		public function get filter():ShaderFilter
		{
			return _filter;
		}
		
		public function set parentModule(value:ImageEditModule):void
		{
			_parentModule = value as ColourModule;
		}
	}
}