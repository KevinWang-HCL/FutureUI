package assets.embedded
{
	[Bindable]
	public class Orientation_Icons
	{
		[Embed(source='assets/images/orientationIcons/Landscape.png')]
		public static var landscapeClass:Class;
		
		[Embed(source='assets/images/orientationIcons/Portrait.png')]
		public static var portraitClass:Class;
	}
}