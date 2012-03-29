package ImagePlugins.CMYKPlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEffect;
	import MimicPlugin.ImageModuleHost;
	
	import mimicViewComponent.ImageMouseEvent;

	public class CMYKModule implements ImageEditModule
	{
		//There should only ever be one effect created. Any modification
		//is done through the effect's properties.
		private var effect:CMYKEffect;
		private var _moduleHost:ImageModuleHost;
		private var _ui:CMYKModuleUI;
		public function CMYKModule(moduleHost:ImageModuleHost, ui:CMYKModuleUI)
		{
			_moduleHost = moduleHost;
			_ui = ui;
			createImageEffect();
		}
		
		
		public function madeActive(host:ImageModuleHost):void
		{
			if(!host.hasImageEffect(effect) || !host.usingCachedFilteredImage())
			{
				host.applyImageEffect(effect);
				host.cacheImageFilterState();
				host.useCachedFilteredImage(true);
			}
		}
		
		public function madeInactive(host:ImageModuleHost):void
		{
			//host.useCachedFilteredImage(false);
			//host.removeImageEffect(effect);
			//trace("CMYK EFFECT REMOVED");
		}
		
		public function handleMouseDown(evt:ImageMouseEvent):void
		{
			//Do nothing
		}
		
		public function handleMouseMove(evt:ImageMouseEvent):void
		{
			//Do nothing	
		}
		
		public function handleMouseUp(evt:ImageMouseEvent):void
		{
			//Do nothing
		}
		
		public function handleDoubleClick(evt:ImageMouseEvent):void
		{
			
		}
		
		public function handleZoomed(host:ImageModuleHost):void
		{
			
		}
		
		public function notifyEffectRemoved(effect:ImageEffect):void
		{
			_ui.reset();
		}
		
		public function hasActiveEffects():Boolean
		{
			return effect.getProperty(CMYKEffect.CYAN_OFFSET_PROP) != 0 
					|| effect.getProperty(CMYKEffect.MAGENTA_OFFSET_PROP) != 0
					|| effect.getProperty(CMYKEffect.YELLOW_OFFSET_PROP) != 0
					|| effect.getProperty(CMYKEffect.KEY_OFFSET_PROP) != 0;	
		}
		
		public function createImageEffect():ImageEffect
		{
			if(!effect)
			{
				effect = new CMYKEffect();
				effect.parentModule = this;
			}
			return effect;
		}
		
		public function reset():void
		{
			_ui.reset();
			effect.setProperty(CMYKEffect.CYAN_OFFSET_PROP, 0);
			effect.setProperty(CMYKEffect.MAGENTA_OFFSET_PROP, 0);
			effect.setProperty(CMYKEffect.YELLOW_OFFSET_PROP, 0);
			effect.setProperty(CMYKEffect.KEY_OFFSET_PROP, 0);
			_moduleHost.updateCachedImage([effect.shaderFilter]);
		}
	}
}