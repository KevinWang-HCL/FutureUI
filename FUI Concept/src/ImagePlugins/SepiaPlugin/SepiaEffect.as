package ImagePlugins.SepiaPlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEffect;
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	
	import mimicViewComponent.EditImage;
	
	public class SepiaEffect implements ImageEffect
	{
		[Embed(source="assets/shaders/sepia.pbj", mimeType="application/octet-stream")]
		private static var sepiaShaderData:Class;
		
		private var shader:Shader;
		private var filter:ShaderFilter;
		
		private var creator:ImageEditModule;
		
		public function SepiaEffect()
		{
			shader = new Shader(new sepiaShaderData());
			filter = new ShaderFilter(shader);
		}
		
		public function setProperty(propName:String, value:*):void
		{
		}
		
		public function showOnImage(image:EditImage):void
		{
			if(image.useCachedImageAsSource)
				image.useCachedImageAsSource = false;
			
			var filters:Array = image.baseImage.filters;
			filters.push(filter);
			image.baseImage.filters = filters;
		}
		
		public function removeFromImage(image:EditImage):void
		{
			if(image.useCachedImageAsSource)
				image.useCachedImageAsSource = false;
			
			var filters:Array = image.baseImage.filters;
			var ind:int = filters.indexOf(filter);
			filters.splice(ind, 1);
			image.baseImage.filters = filters;
		}
		
		public function applyToBitmapData(data:BitmapData):void
		{
			data.applyFilter(data, data.rect, new Point(), new ShaderFilter(shader));
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
			return creator;
		}
		
		public function set parentModule(value:ImageEditModule):void
		{
			this.creator = value;
		}
	}
}