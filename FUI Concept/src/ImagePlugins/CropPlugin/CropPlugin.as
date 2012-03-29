package ImagePlugins.CropPlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEditModuleUI;
	import MimicPlugin.ImageEditPlugin;
	import MimicPlugin.ImageModuleHost;
	
	import assets.embedded.Plugin_Icons;
	
	public class CropPlugin implements ImageEditPlugin
	{
		private var cropModule:CropModule;
		private var cropModuleUI:CropModuleUI;
		
		public function CropPlugin(host:ImageModuleHost)
		{
			cropModule = new CropModule(host);
			cropModuleUI = new CropModuleUI();
				cropModuleUI.imageEditHost = host;
				cropModuleUI.imageEditModule = cropModule;
		}
		
		public function getName():String
		{
			return "Crop";
		}
		
		public function getAuthor():String
		{
			return "Me";
		}
		
		public function getIcon():Class
		{
			return Plugin_Icons.cropClass;
		}
		
		public function getVersion():String
		{
			return "v1.0.0";
		}
		
		public function getEditModule():ImageEditModule
		{
			return cropModule;
		}
		
		public function hasUI():Boolean
		{
			return false;
		}
		
		public function getEditModuleUI():ImageEditModuleUI
		{
			return cropModuleUI;
		}
	}
}