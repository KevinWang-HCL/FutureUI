package assets.embedded
{	
	import flash.display.Sprite;
	import flash.media.*;
	
	public class Sounds extends Sprite
	{
		[Embed(source="assets/sounds/KeyClick.mp3")]
		private static var soundClickClass:Class;
		private static var smallSound:Sound = new soundClickClass() as Sound;
		
		public static function soundClick():void
		{
			smallSound.play();
		}
	}
}