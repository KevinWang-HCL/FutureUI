package ImagePlugins.TonePlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEditModuleUI;
	import MimicPlugin.ImageEditPlugin;
	import MimicPlugin.ImageModuleHost;
	
	public class TonePlugin implements ImageEditPlugin
	{
		private var module:ToneModule;
		private var ui:TonePluginUI;
		
		public function TonePlugin(moduleHost:ImageModuleHost)
		{
			ui = new TonePluginUI();
			module = new ToneModule(moduleHost, ui);
			ui.imageEditModule = module;
			ui.imageEditHost = moduleHost;
		}
		
		public function getName():String
		{
			return "Tone";
		}
		
		public function getIcon():Class
		{
			return null;
		}
		
		public function getAuthor():String
		{
			return "Me";
		}
		
		public function getVersion():String
		{
			return "v1.0";
		}
		
		public function getEditModule():ImageEditModule
		{
			return module;
		}
		
		public function hasUI():Boolean
		{
			return true;
		}
		
		public function getEditModuleUI():ImageEditModuleUI
		{
			return ui;
		}
	}
}