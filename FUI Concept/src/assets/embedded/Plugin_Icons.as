package assets.embedded
{
	[Bindable]
	public class Plugin_Icons
	{
		[Embed(source='assets/images/pluginIcons/Color.png')]
		public static var colorClass:Class;
		
		[Embed(source='assets/images/pluginIcons/Crop.png')]
		public static var cropClass:Class;
		
		[Embed(source='assets/images/pluginIcons/Redaction.png')]
		public static var redactionClass:Class;
		
	}
}