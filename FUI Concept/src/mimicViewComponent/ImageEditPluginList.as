package mimicViewComponent
{
	import ImagePlugins.ColourPlugin.ColourPlugin;
	import ImagePlugins.CropPlugin.CropPlugin;
	import ImagePlugins.Redaction.RedactionPlugin;
	
	import MimicPlugin.ImageEditPlugin;

	public class ImageEditPluginList
	{
		private var _plugins:Vector.<ImageEditPlugin>;
		
		public function ImageEditPluginList(imageEditView:ImageEditView)
		{
			_plugins = new Vector.<ImageEditPlugin>();
			addPlugin(new CropPlugin(imageEditView));
			//addPlugin(new CMYKEffectPlugin(imageEditView));
			//addPlugin(new TonePlugin(imageEditView));
			addPlugin(new ColourPlugin(imageEditView));
			addPlugin(new RedactionPlugin(imageEditView));
		}
		
		public function loadPlugin(location:String):void
		{
			//TODO load from local swf or remotely from swf.
		}
		
		public function addPlugin(plugin:ImageEditPlugin):void
		{
			_plugins.push(plugin);
		}
		
		public function removePlugin(plugin:ImageEditPlugin):void
		{
			_plugins.splice(_plugins.indexOf(plugin), 1);
		}
		
		public function getPluginAt(index:int):ImageEditPlugin
		{
			return _plugins[index];
		}
		
		public function get numPlugins():int
		{
			return _plugins.length;
		}
	}
}