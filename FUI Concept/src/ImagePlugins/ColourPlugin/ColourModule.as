package ImagePlugins.ColourPlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEditModuleUI;
	import MimicPlugin.ImageEffect;
	import MimicPlugin.ImageModuleHost;
	
	import integration.SettingsMap;
	
	import mimicViewComponent.ImageMouseEvent;
	
	public class ColourModule implements ImageEditModule
	{
		public static const NO_EFFECT:int = 0, CMYK_EFFECT:int = 1, SEPIA_EFFECT:int = 2, GRAYSCALE_EFFECT:int = 3;
		
		private var _moduleHost:ImageModuleHost;
		private var _ui:ImageEditModuleUI;
		private var _activeEffectType:int;
		private var _activeEffect:ColourEffect;
		
		public function ColourModule(moduleHost:ImageModuleHost, ui:ImageEditModuleUI)
		{
			_activeEffectType = NO_EFFECT;
			_activeEffect = null;
			_ui = ui;
			_moduleHost = moduleHost;
		}
		
		public function madeActive(host:ImageModuleHost):void
		{
		}
		
		public function madeInactive(host:ImageModuleHost):void
		{
		}
		
		public function handleMouseDown(evt:ImageMouseEvent):void
		{
		}
		
		public function handleMouseMove(evt:ImageMouseEvent):void
		{
		}
		
		public function handleMouseUp(evt:ImageMouseEvent):void
		{
		}
		
		public function handleDoubleClick(evt:ImageMouseEvent):void
		{
		}
		
		public function handleZoomed(host:ImageModuleHost):void
		{
		}
		
		public function notifyEffectRemoved(effect:ImageEffect):void
		{
		}
		
		public function setActiveEffect(type:int):void
		{
			if(_moduleHost.usingCachedFilteredImage())
				_moduleHost.useCachedFilteredImage(false);

			if(_activeEffectType != NO_EFFECT)
				_moduleHost.removeImageEffect(_activeEffect);
			
			switch(type)
			{
				case CMYK_EFFECT:
					_activeEffect = new CMYKColourEffect();
					break;
				case SEPIA_EFFECT:
					_activeEffect = new SepiaColourEffect();
					break;
				case GRAYSCALE_EFFECT:
					_activeEffect = new GrayscaleColourEffect();
					break;
			}
			
			if(type != NO_EFFECT)
				_moduleHost.applyImageEffect(_activeEffect);
			
			_activeEffectType = type;
			_moduleHost.cacheImageFilterState();
			_moduleHost.useCachedFilteredImage(true);
		}
		
		public function applyOutputSettings(settings:SettingsMap):void
		{
			
		}
		
		public function hasActiveEffects():Boolean
		{
			return _activeEffectType != NO_EFFECT;
		}
		
		public function createImageEffect():ImageEffect
		{
			return null;
		}
		
		public function getActiveEffect():ColourEffect
		{
			return _activeEffect;
		}
		
		public function getActiveEffectType():int
		{
			return _activeEffectType;
		}
		
		public function reset():void
		{
			setActiveEffect(NO_EFFECT);
			_ui.reset();
		}
	}
}