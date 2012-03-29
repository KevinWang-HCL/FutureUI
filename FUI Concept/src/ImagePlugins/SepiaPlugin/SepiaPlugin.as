package ImagePlugins.SepiaPlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEditModuleUI;
	import MimicPlugin.ImageEditPlugin;
	import MimicPlugin.ImageModuleHost;
	
	public class SepiaPlugin implements ImageEditPlugin
	{
		private var module:SepiaModule;
		private var ui:SepiaModuleUI;
		
		public function SepiaPlugin(moduleHost:ImageModuleHost)
		{
			ui = new SepiaModuleUI();
			module = new SepiaModule(ui);
			ui.imageEditHost = moduleHost;
			ui.imageEditModule = module;
		}
		
		public function getName():String
		{
			return "Sepia";
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
			return module;
		}
		
		public function hasUI():Boolean
		{
			return false;
		}
		
		public function getEditModuleUI():ImageEditModuleUI
		{
			return ui;
		}
	}
}