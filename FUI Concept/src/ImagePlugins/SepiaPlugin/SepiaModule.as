package ImagePlugins.SepiaPlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEffect;
	import MimicPlugin.ImageModuleHost;
	
	import mimicViewComponent.ImageMouseEvent;
	
	public class SepiaModule implements ImageEditModule
	{
		private var sepiaEffect:SepiaEffect;
		private var ui:SepiaModuleUI;
		
		public function SepiaModule(ui:SepiaModuleUI)
		{
			this.ui = ui;
		}
		
		public function madeActive(host:ImageModuleHost):void
		{
			//trace("Sepia module made active");
			host.applyImageEffect(createImageEffect());
			host.cacheImageFilterState();
			host.useCachedFilteredImage(true);
		}
		
		public function madeInactive(host:ImageModuleHost):void
		{
			//host.removeImageEffect(sepiaEffect);
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
			ui.applyEffectBtn.selected = false;
		}
		
		public function createImageEffect():ImageEffect
		{
			if(!sepiaEffect)
			{
				sepiaEffect = new SepiaEffect();	
				sepiaEffect.parentModule = this;
			}
			return sepiaEffect;
		}
		
		public function reset():void
		{
			
		}
	}
}