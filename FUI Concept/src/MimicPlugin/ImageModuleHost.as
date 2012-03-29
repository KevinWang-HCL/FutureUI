package MimicPlugin
{
	import flash.geom.Rectangle;
	
	import mimicViewComponent.EditImage;
	
	import mx.core.IVisualElement;

	public interface ImageModuleHost
	{
		function get image():EditImage;
		
		function set image(value:*):void;
		
		function hasImageEffect(effect:ImageEffect):Boolean;
		
		function applyImageEffect(effect:ImageEffect):void;
		
		function removeImageEffect(effect:ImageEffect):void;
		
		function addUILayerElement(elem:IVisualElement):void;
		
		function removeUILayerElement(elem:IVisualElement):void;
		
		function notifyImageEffectChanged(effect:ImageEffect):void;
		
		function cacheImageFilterState():void;
		
		function useCachedFilteredImage(b:Boolean):void;
		
		function usingCachedFilteredImage():Boolean;
		
		function updateCachedImage(updatedFilters:Array):void;
		
		function get cachedFilters():Array;
		
		function get imageBounds():Rectangle;
		
		function get panningEnabled():Boolean;
		
		function set panningEnabled(value:Boolean):void;
		
		function get zoomEnabled():Boolean;
		
		function set zoomEnabled(value:Boolean):void;
		
		function get resetZoomEnabled():Boolean;
		
		function set resetZoomEnabled(value:Boolean):void;
		
		function get currentZoom():Number;
	}
}