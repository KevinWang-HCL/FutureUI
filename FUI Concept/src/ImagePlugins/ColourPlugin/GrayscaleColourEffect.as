package ImagePlugins.ColourPlugin
{
	import flash.display.Shader;
	import flash.filters.ShaderFilter;

	public class GrayscaleColourEffect extends ColourEffect
	{
		[Embed(source="assets/shaders/grayscale.pbj", mimeType="application/octet-stream")]
		private static var grayscaleShaderData:Class;
		
		public static const BRIGHTNESS:String = "Brightness";	
		
		public function GrayscaleColourEffect()
		{
			super();
			_filter = new ShaderFilter(new Shader(new grayscaleShaderData()));
		}
		
		public override function setProperty(propName:String, value:*):void
		{
			if(propName == BRIGHTNESS)
			{
				_filter.shader.data.offset.value = [value];
			}
		}
	}
}