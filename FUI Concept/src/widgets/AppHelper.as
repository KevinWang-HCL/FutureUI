package widgets
{	
	import assets.embedded.SendStore_Icons;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;

	public class AppHelper
	{
		private const xmlAppSettings:String = "assets/data/AppSettings.xml";
		
		private var appArray:ArrayCollection = new ArrayCollection;
		
		public function getAppArray() : ArrayCollection
		{
			return appArray;
		}
		
		public function AppHelper()
		{	
			var uRLLoader:URLLoader = new URLLoader();
			uRLLoader.addEventListener(Event.COMPLETE, appSettingLoadComplete);
			
			uRLLoader.load(new URLRequest(xmlAppSettings));
		}
		
		// Called once the XML keyboard has loaded
		private function appSettingLoadComplete(event:Event):void 
		{
			var xmlData:XML = new XML(event.target.data);
			
			var appList:XMLList = xmlData.app;
			var buttonPathData:String = null;
			
			for each (var appRow:XML in appList)
			{
				// Get all the child @attributes and nodes of row
				var appInstalled:Boolean = appRow.@installed == "true";
				var appStyle:String = appRow.@style;
				var appSettings:XMLList = appRow.children();
				var app : AppBase = null;
				
				if (appStyle == "Twitter" && appInstalled)
				{
					app = new TwitterApp;
					app.image = SendStore_Icons.appTwitterClass;
				}
				else if (appStyle == "Flickr" && appInstalled)
				{
					app = new FlickrApp;
					app.image = SendStore_Icons.appFlickrClass;
				}
				
				if (app != null)
				{
					app.appName = appRow.@name;
					app.installed = appRow.@installed;
					
					app.onLoadSetting(appSettings[0]);
					appArray.addItem(app);
				}
			}
		}
		
		public function onStart() : void
		{
			for each (var app:AppBase in appArray) 
			{
				if (app.appEnabled && app.appReadyToStart)
				{
					app.onStart();
				}
			}
		}
	}
}