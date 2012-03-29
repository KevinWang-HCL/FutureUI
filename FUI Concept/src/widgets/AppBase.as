package widgets
{
	import itemRenderers.AppFlickrItemRenderer;
	import itemRenderers.AppTwitterItemRenderer;
	
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	
	import spark.components.Group;
	
	public class AppBase
	{
		[Bindable]
		public var appName:String = "";
		public var installed:Boolean = false;
		[Bindable]
		public var image:Object;
		public var appEnabled:Boolean = false; //in the right list
		public var appReadyToStart:Boolean = false; //logged in
		
		public var display:String = "app";
		
		public function onActivated() : void
		{
			appEnabled = true;
		}
		
		public function onStart() : void
		{
		}
		
		public function onLoadSetting(xmlData:XML): void
		{
		}
		
		static public function itemRendererFunction(item:*): IFactory
		{
			var data:AppBase = item.itemData as AppBase;
			if (data)
			{
				switch (data.appName)
				{
				case "Flickr":
					return new ClassFactory(AppFlickrItemRenderer);
				case "Twitter":
					return new ClassFactory(AppTwitterItemRenderer);
				}
			}
			
			return null;
		}
	}
}