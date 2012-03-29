package ImagePlugins.ColourPlugin
{
	import flash.display.Shader;
	import flash.filters.ShaderFilter;

	public class CMYKColourEffect extends ColourEffect
	{
		[Embed(source="assets/shaders/cmykeditor.pbj", mimeType="application/octet-stream")]
		private static var cmykShaderData:Class;
		
		public static var CYAN_OFFSET_PROP:String = "cyanOff";
		public static var MAGENTA_OFFSET_PROP:String = "magentaOff";
		public static var YELLOW_OFFSET_PROP:String = "yellowOff";
		public static var KEY_OFFSET_PROP:String = "keyOff";
		
		public function CMYKColourEffect()
		{
			super();
			_filter = new ShaderFilter(new Shader(new cmykShaderData()));
		}
		
		public override function setProperty(propName:String, value:*):void
		{
			var shaderInvalid:Boolean = false;
			if(propName == CYAN_OFFSET_PROP)
			{
				_filter.shader.data.cmykOffsets.value[0] = value;
			}
			else if(propName == MAGENTA_OFFSET_PROP)
			{
				_filter.shader.data.cmykOffsets.value[1] = value;
			}
			else if(propName == YELLOW_OFFSET_PROP)
			{
				_filter.shader.data.cmykOffsets.value[2] = value;
			}
			else if(propName == KEY_OFFSET_PROP)
			{
				_filter.shader.data.cmykOffsets.value[3] = value;
			}
		}
	}
}