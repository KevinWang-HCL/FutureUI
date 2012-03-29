package ImagePlugins.ColourPlugin
{
	import flash.display.Shader;
	import flash.filters.ShaderFilter;

	public class SepiaColourEffect extends ColourEffect
	{
		[Embed(source="assets/shaders/sepia.pbj", mimeType="application/octet-stream")]
		private static var sepiaShaderData:Class;
		
		public static const BRIGHTNESS:String = "Brightness";	
		
		public function SepiaColourEffect()
		{
			super();
			_filter = new ShaderFilter(new Shader(new sepiaShaderData()));
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