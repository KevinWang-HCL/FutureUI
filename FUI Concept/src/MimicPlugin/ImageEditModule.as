package MimicPlugin
{
	import integration.SettingsMap;
	
	import mimicViewComponent.ImageMouseEvent;

	public interface ImageEditModule
	{
		function madeActive(host:ImageModuleHost):void;
		
		function madeInactive(host:ImageModuleHost):void;
		
		function handleMouseDown(evt:ImageMouseEvent):void;
		
		function handleMouseMove(evt:ImageMouseEvent):void;
		
		function handleMouseUp(evt:ImageMouseEvent):void;
		
		function handleDoubleClick(evt:ImageMouseEvent):void;
		
		function handleZoomed(host:ImageModuleHost):void;
		
		function notifyEffectRemoved(effect:ImageEffect):void;
		
		function applyOutputSettings(settings:SettingsMap):void;
		
		function hasActiveEffects():Boolean;
		
		function createImageEffect():ImageEffect;
		
		function reset():void;		
	}
}