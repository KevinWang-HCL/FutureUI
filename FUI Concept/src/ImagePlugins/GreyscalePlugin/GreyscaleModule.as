package ImagePlugins.GreyscalePlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEffect;
	import MimicPlugin.ImageModuleHost;
	
	import mimicViewComponent.ImageMouseEvent;
	
	public class GreyscaleModule implements ImageEditModule
	{
		private var greyscaleEffect:GreyscaleEffect;
		private var ui:GreyscaleModuleUI;
		
		public function GreyscaleModule(ui:GreyscaleModuleUI)
		{
			this.ui = ui;
		}
		
		public function madeActive(host:ImageModuleHost):void
		{	
			host.applyImageEffect(createImageEffect());
		}
		
		public function madeInactive(host:ImageModuleHost):void
		{	
			host.removeImageEffect(greyscaleEffect);
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
		
		
		public function handleZoomed(host:ImageModuleHost):void
		{
			
		}
		
		public function notifyEffectRemoved(effect:ImageEffect):void
		{
			ui.applyEffectBtn.selected = false;
		}
		
		public function createImageEffect():ImageEffect
		{
			if(!greyscaleEffect)
			{
				greyscaleEffect = new GreyscaleEffect();
				greyscaleEffect.parentModule = this;
			}
			return greyscaleEffect;
		}
	}
}