package MimicPlugin
{
	

	public interface ImageEditPlugin
	{
		function getName():String;
		
		function getAuthor():String;
		
		function getIcon():Class;
		
		function getVersion():String;
		
		function getEditModule():ImageEditModule;
		
		function hasUI():Boolean;
		
		function getEditModuleUI():ImageEditModuleUI;
	}
}