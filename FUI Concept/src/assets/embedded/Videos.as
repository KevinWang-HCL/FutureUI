package assets.embedded
{
	[Bindable]
	public class Videos
	{
		[Embed(source='assets/videos/DocumentHandlerGlass.swf')]
		public static var DocumentHandlerGlassClass:Class;
		
		[Embed(source='assets/videos/DocumentHandler.swf')]
		public static var DocumentHandlerClass:Class;
	}
}