package ImagePlugins.TonePlugin
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEffect;
	import MimicPlugin.ImageModuleHost;
	
	import mimicViewComponent.ImageMouseEvent;
	
	public class ToneModule implements ImageEditModule
	{
		[Embed(source="assets/shaders/sepia.pbj", mimeType="application/octet-stream")]
		private static var sepiaShaderData:Class;
		[Embed(source="assets/shaders/grayscale.pbj", mimeType="application/octet-stream")]
		private static var grayscaleShaderData:Class;
		
		public static const NO_TONE:int = 0, SEPIA_TONE:int = 1, GRAYSCALE_TONE:int = 2;
		
		private var moduleHost:ImageModuleHost;
		private var ui:TonePluginUI;
		
		private var sepiaEffect:ToneEffect;
		private var grayscaleEffect:ToneEffect;
		
		private var currentToneEffect:int;
		
		public function ToneModule(host:ImageModuleHost, ui:TonePluginUI)
		{
			this.moduleHost = host;
			this.ui = ui;
			
			sepiaEffect = new ToneEffect(new sepiaShaderData());
				sepiaEffect.parentModule = this;
			grayscaleEffect = new ToneEffect(new grayscaleShaderData());
				grayscaleEffect.parentModule = this;
			currentToneEffect = NO_TONE;
		}
		
		public function madeActive(host:ImageModuleHost):void
		{
			if(currentToneEffect != NO_TONE)
			{
				if((currentToneEffect == SEPIA_TONE && !host.hasImageEffect(sepiaEffect))
					|| (currentToneEffect == GRAYSCALE_TONE && !host.hasImageEffect(grayscaleEffect)))
					setToneEffect(currentToneEffect);
			}
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
			ui.reset();
		}
		
		public function createImageEffect():ImageEffect
		{  
			return null;
		}
		
		public function setToneEffect(tone:int):void
		{
			if(moduleHost.usingCachedFilteredImage())
				moduleHost.useCachedFilteredImage(false);

			if(tone == NO_TONE && currentToneEffect != NO_TONE)
			{
				if(currentToneEffect == SEPIA_TONE)
					moduleHost.removeImageEffect(sepiaEffect);
				else if(currentToneEffect == GRAYSCALE_TONE)
					moduleHost.removeImageEffect(grayscaleEffect);	
			}
			else if(tone == SEPIA_TONE)
			{
				if(currentToneEffect == GRAYSCALE_TONE)
					moduleHost.removeImageEffect(grayscaleEffect);
				
				moduleHost.applyImageEffect(sepiaEffect);
			}
			else if(tone == GRAYSCALE_TONE)
			{		
				if(currentToneEffect == SEPIA_TONE)
					moduleHost.removeImageEffect(sepiaEffect);
				
				moduleHost.applyImageEffect(grayscaleEffect);
			}
			currentToneEffect = tone;
			moduleHost.cacheImageFilterState();
			moduleHost.useCachedFilteredImage(true);
		}
		
		public function hasActiveEffects():Boolean
		{
			return currentToneEffect != NO_TONE;	
		}
		
		public function reset():void
		{
			trace("RESETTING TONE EFFECT");
			setToneEffect(NO_TONE);
			ui.reset();
		}
	}
}