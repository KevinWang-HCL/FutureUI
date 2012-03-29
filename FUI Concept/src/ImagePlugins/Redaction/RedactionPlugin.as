package ImagePlugins.Redaction
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEditModuleUI;
	import MimicPlugin.ImageEditPlugin;
	import MimicPlugin.ImageModuleHost;
	import assets.embedded.Plugin_Icons;
	
	public class RedactionPlugin implements ImageEditPlugin
	{
		private var redactionModule:RedactionModule;
		private var redactionModuleUI:RedactionModuleUI;
		
		public function RedactionPlugin(host:ImageModuleHost)
		{
			redactionModuleUI = new RedactionModuleUI();
			redactionModule = new RedactionModule(host);
			redactionModuleUI.imageEditHost = host;
			redactionModuleUI.imageEditModule = redactionModule;
		}
		
		public function getName():String
		{
			return "Redaction";
		}
		
		public function getIcon():Class
		{
			return Plugin_Icons.redactionClass;
		}
		
		public function getAuthor():String
		{
			return "Me";
		}
		
		public function getVersion():String
		{
			return "v1.0.0";
		}
		
		public function getEditModule():ImageEditModule
		{
			return redactionModule;
		}
		
		public function hasUI():Boolean
		{
			return true;
		}
		
		public function getEditModuleUI():ImageEditModuleUI
		{
			return redactionModuleUI;
		}
	}
}