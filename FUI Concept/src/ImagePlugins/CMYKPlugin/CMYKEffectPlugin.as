package ImagePlugins.CMYKPlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEditModuleUI;
	import MimicPlugin.ImageEditPlugin;
	import MimicPlugin.ImageModuleHost;

	public class CMYKEffectPlugin implements ImageEditPlugin
	{
		private var cmykModule:CMYKModule;
		private var cmykModuleUI:CMYKModuleUI;
		
		public function CMYKEffectPlugin(moduleHost:ImageModuleHost)
		{
			cmykModuleUI = new CMYKModuleUI();
			cmykModule = new CMYKModule(moduleHost, cmykModuleUI);
			cmykModuleUI.imageEditModule = cmykModule;
			cmykModuleUI.imageEditHost = moduleHost;
		}
		
		public function getName():String
		{
			return "Color";
		}
		
		public function getAuthor():String
		{
			return "Me";
		}
		
		public function getIcon():Class
		{
			return null;
		}
		
		public function getVersion():String
		{
			return "v1.0.0";
		}
		
		public function getEditModule():ImageEditModule
		{
			return cmykModule;
		}
		
		public function hasUI():Boolean
		{
			return true;
		}
		
		public function getEditModuleUI():ImageEditModuleUI
		{
			return cmykModuleUI;
		}
	}
}