package widgets
{
	import assets.skins.skinHSlider;
	
	import spark.components.HSlider;
	
	[Style(name="trackStartColor", inherit="no", type="uint")]
	[Style(name="trackEndColor", inherit="no", type="uint")]
	public class wStylableHSlider extends HSlider
	{
		private var _trackStartColour:uint = 0xCCCCCC;
		private var _trackEndColour:uint = 0xBBBBBB;
		
		public function wStylableHSlider()
		{
			super();
			this.setStyle("skinClass", skinHSlider);
		}
		
		public override function styleChanged(styleName:String):void
		{
			super.styleChanged(styleName);
			
			if(!styleName)
			{
				if(getStyle("trackStartColor"))
					trackStartColour = getStyle("trackStartColor");
				if(getStyle("trackEndColor"))
					trackEndColour = getStyle("trackEndColor");
			}
			else if(styleName == "trackStartColour")
			{
				trackStartColour = getStyle(styleName);
			}
			else if(styleName == "trackEndColour")
			{
				trackEndColour = getStyle(styleName);
			}
		}
		
		[Bindable]
		public function get trackStartColour():uint
		{
			return _trackStartColour;
		}
		
		public function set trackStartColour(value:uint):void
		{
			_trackStartColour = value;
		}

		[Bindable]
		public function get trackEndColour():uint
		{
			return _trackEndColour;
		}

		public function set trackEndColour(value:uint):void
		{
			_trackEndColour = value;
		}

	}
}