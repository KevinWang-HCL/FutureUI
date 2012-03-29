package assets.embedded
{
	[Bindable]
	public class Side_Icons
	{
		[Embed(source='assets/images/sideIcons/1Sided.png')]
		public static var oneSidedClass:Class;
		
		[Embed(source='assets/images/sideIcons/2Sided.png')]
		public static var twoSidedClass:Class;
		
		[Embed(source='assets/images/sideIcons/2SidedRotate.png')]
		public static var twoSidedRotateClass:Class;
	}
}