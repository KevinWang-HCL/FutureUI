package MimicPlugin
{
	import spark.components.Group;

	public class ImageEditModuleUI extends Group
	{
		protected var moduleRef:ImageEditModule;
		protected var pluginHost:ImageModuleHost;
		
		public function ImageEditModuleUI()
		{
			
		}
		
		public function reset():void
		{
			
		}
		
		public function get imageEditModule():ImageEditModule
		{
			return moduleRef;
		}
		
		public function set imageEditModule(value:ImageEditModule):void
		{
			moduleRef = value;
		}
		
		public function get imageEditHost():ImageModuleHost
		{
			return pluginHost;	
		}
		
		public function set imageEditHost(value:ImageModuleHost):void
		{
			pluginHost = value;
		}
		
		public function get requiredHeight():Number
		{
			return 0;
		}
	}
}