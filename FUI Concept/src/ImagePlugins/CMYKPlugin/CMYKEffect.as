package ImagePlugins.CMYKPlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEffect;
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	
	import mimicViewComponent.EditImage;
	
	public class CMYKEffect implements ImageEffect
	{
		[Embed(source="assets/shaders/cmykeditor.pbj", mimeType="application/octet-stream")]
		private static var cmykShaderData:Class;
		
		public static var CYAN_OFFSET_PROP:String = "cyanOff";
		public static var MAGENTA_OFFSET_PROP:String = "magentaOff";
		public static var YELLOW_OFFSET_PROP:String = "yellowOff";
		public static var KEY_OFFSET_PROP:String = "keyOff";
		
		private var cmykShader:Shader;
		private var cmykFilter:ShaderFilter;
		private var creator:ImageEditModule;
		
		public function CMYKEffect()
		{
			cmykShader = new Shader(new cmykShaderData());
			cmykFilter = new ShaderFilter(cmykShader);
		}
		
		public function setProperty(propName:String, value:*):void
		{
			var shaderInvalid:Boolean = false;
			if(propName == CYAN_OFFSET_PROP)
			{
				cmykShader.data.cmykOffsets.value[0] = value;
			}
			else if(propName == MAGENTA_OFFSET_PROP)
			{
				cmykShader.data.cmykOffsets.value[1] = value;
			}
			else if(propName == YELLOW_OFFSET_PROP)
			{
				cmykShader.data.cmykOffsets.value[2] = value;
			}
			else if(propName == KEY_OFFSET_PROP)
			{
				cmykShader.data.cmykOffsets.value[3] = value;
			}
		}
		
		public function getProperty(propName:String):*
		{
			if(propName == CYAN_OFFSET_PROP)
			{
				return cmykShader.data.cmykOffsets.value[0];
			}
			else if(propName == MAGENTA_OFFSET_PROP)
			{
				return cmykShader.data.cmykOffsets.value[1];
			}
			else if(propName == YELLOW_OFFSET_PROP)
			{
				return cmykShader.data.cmykOffsets.value[2];
			}
			else if(propName == KEY_OFFSET_PROP)
			{
				return cmykShader.data.cmykOffsets.value[3];
			}
		}
		
		public function showOnImage(image:EditImage):void
		{	
			if(image.useCachedImageAsSource)
				image.useCachedImageAsSource = false;
			
			var filters:Array = image.baseImage.filters;
			filters.push(cmykFilter);
			image.baseImage.filters = filters;
		}
		
		public function removeFromImage(image:EditImage):void
		{
			if(image.useCachedImageAsSource)
				image.useCachedImageAsSource = false;
			
			var filters:Array = image.baseImage.filters;
			var ind:int = filters.indexOf(cmykFilter);
			filters.splice(ind, 1);
			image.baseImage.filters = filters;
		}
		
		public function applyToBitmapData(data:BitmapData):void
		{
			data.applyFilter(data, data.rect, new Point(), cmykFilter);
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
		
		public function get shaderFilter():ShaderFilter
		{
			return cmykFilter;
		}
	}
}