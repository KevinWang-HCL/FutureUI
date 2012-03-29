package MimicPlugin
{
	import integration.SettingsMap;
	
	public class ImageEditSettings
	{
		/*public static const SETTING_COLOUR_BALANCE:String = "colour_balance";
		public static const DEFAULT_COLOUR_BALANCE:Array = [1.0, 1.0, 1.0, 1.0];*/
		
		public static const SETTING_EDGE_CROP:String = "EDGE_CROP";
		public static const DEFAULT_EDGE_CROP:Array = [3.0, 3.0, 3.0, 3.0];
		
		
		public static function createAndInitialiseSettingsMap():SettingsMap
		{
			var settings:SettingsMap = new SettingsMap();
			
			settings.set(SETTING_EDGE_CROP, DEFAULT_EDGE_CROP);
			
			return settings;
		}
	}
}