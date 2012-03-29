package ImagePlugins.TonePlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEffect;
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	
	import mimicViewComponent.EditImage;
	
	public class ToneEffect implements ImageEffect
	{
		private var _filter:ShaderFilter;
		private var _creator:ImageEditModule;
		
		public function ToneEffect(shaderSrc:*)
		{
			_filter = new ShaderFilter(new Shader(shaderSrc));	
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
			if(filters.length == 1)
				image.baseImage.filters = [];
			else
			{
				filters.splice(ind, 1);
				image.baseImage.filters = filters;
			}
		}
		
		public function applyToBitmapData(data:BitmapData):void
		{
			data.applyFilter(data, data.rect, new Point(), _filter);
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
			return _creator;
		}
		
		public function set parentModule(value:ImageEditModule):void
		{
			_creator = value;
		}
	}
}