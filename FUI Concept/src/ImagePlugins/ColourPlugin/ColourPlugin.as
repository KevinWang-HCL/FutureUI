package ImagePlugins.ColourPlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEditModuleUI;
	import MimicPlugin.ImageEditPlugin;
	import MimicPlugin.ImageModuleHost;
	import assets.embedded.Plugin_Icons;
	
	public class ColourPlugin implements ImageEditPlugin
	{
		private var _module:ColourModule;
		private var _ui:ColourModuleUI;
		
		public function ColourPlugin(moduleHost:ImageModuleHost)
		{
			_ui = new ColourModuleUI();
			_ui.imageEditHost = moduleHost;
			_module = new ColourModule(moduleHost, _ui);
			_ui.imageEditModule = _module;
		}
		
		public function getName():String
		{
			return "Color";
		}
		
		public function getAuthor():String
		{
			return "Blah";
		}
		
		public function getIcon():Class
		{
			return Plugin_Icons.colorClass;
		}
		
		public function getVersion():String
		{
			return "v1.0.0";
		}
		
		public function getEditModule():ImageEditModule
		{
			return _module;
		}
		
		public function hasUI():Boolean
		{
			return true;
		}
		
		public function getEditModuleUI():ImageEditModuleUI
		{
			return _ui;
		}
	}
}