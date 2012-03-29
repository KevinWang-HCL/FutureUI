package widgets
{
	import assets.skins.skinButton;
	
	import spark.components.Button;

	[Style(name="backgroundAlpha", inherit="no", type="Number")]
	[Style(name="colorHighlight", inherit="no", type="uint")]
	[Style(name="colorShadow", inherit="no", type="uint")]
	[Style(name="colorHighlightDown", inherit="no", type="uint")]
	[Style(name="colorShadowDown", inherit="no", type="uint")]
	[Style(name="textAlignment", inherit="no", type="String")]
	[Style(name="indicator", inherit="no", type="Boolean")]
	public class wButton extends Button
	{
		public function wButton()
		{
			super();
			
			this.setStyle("skinClass", assets.skins.skinButton);
		}
		
		override public function styleChanged(styleProp:String):void {
			
			super.styleChanged(styleProp);
			if(!styleProp || styleProp == "styleName")
			{
				backgroundAlpha = this.getStyle("backgroundAlpha");
				highlight = this.getStyle("colorHighlight");
				shadow = this.getStyle("colorShadow");
				highlightDown = this.getStyle("colorHighlightDown");
				shadowDown = this.getStyle("colorShadowDown");
				
				if(getStyle("textAlignment"))
					textAlignmentProp = this.getStyle("textAlignment");
				else
					textAlignmentProp = "center";
				
				if(getStyle("indicator"))
					indicatorOn = getStyle("indicator");
				else
					indicatorOn = false;
			}
			else
			{
				switch (styleProp) {
					case "backgroundAlpha":
						backgroundAlpha = this.getStyle("backgroundAlpha");
						break;
					
					case "colorHighlight":
						highlight = this.getStyle("colorHighlight");
						break;
					
					case "colorShadow":
						shadow = this.getStyle("colorShadow");
						break;
					
					case "colorHighlightDown":
						highlightDown = this.getStyle("colorHighlightDown");
						break;
					
					case "colorShadowDown":
						shadowDown = this.getStyle("colorShadowDown");
						break;
					case "textAlignment":
						textAlignmentProp = this.getStyle("textAlignment");
						break;
					case "indicator":
						indicatorOn = this.getStyle("indicator");
						break;
				}
			}
		}
		
		
		private var _backgroundShadow:Boolean = true;

		[Bindable]
		public function get backgroundShadow():Boolean
		{
			return _backgroundShadow;
		}

		public function set backgroundShadow(value:Boolean):void
		{
			_backgroundShadow = value;
		}

		
		private var _backgroundAlpha:Number = 1.0;

		[Bindable]
		public function get backgroundAlpha():Number
		{
			return _backgroundAlpha;
		}

		public function set backgroundAlpha(value:Number):void
		{
			_backgroundAlpha = value;
		}

		
 		private var _highlight:uint = 0xD4D4D4;

		[Bindable]
		public function get highlight():uint
		{
			return _highlight;
		}

		public function set highlight(value:uint):void
		{
			_highlight = value;
		}
		
		private var _shadow:uint = 0xB6B6B6;
		
		[Bindable]
		public function get shadow():uint
		{
			return _shadow;
		}
		
		public function set shadow(value:uint):void
		{
			_shadow = value;
		}
		
		private var _highlightDown:uint = 0x338AC3;
		
		[Bindable]
		public function get highlightDown():uint
		{
			return _highlightDown;
		}
		
		public function set highlightDown(value:uint):void
		{
			_highlightDown = value;
		}
		
		private var _shadowDown:uint = 0x3CA5E9;
		
		[Bindable]
		public function get shadowDown():uint
		{
			return _shadowDown;
		}
		
		public function set shadowDown(value:uint):void
		{
			_shadowDown = value;
		}
		
		
		// public property set all corner's radius
		private var _cornerRadius:Number = 0;

		[Bindable]
		public function get cornerRadius():Number
		{
			return _cornerRadius;
		}

		public function set cornerRadius(value:Number):void
		{
			_cornerRadius = value;
		}

		
		// Public properties to set individual corner radius
		private var _topLeftRadius:Number = 0;
		
		[Bindable]
		
		public function get topLeftRadius():Number
		{
			return _topLeftRadius;
		}
		
		public function set topLeftRadius(value:Number):void
		{
			_topLeftRadius = value;
		}
		
		
		private var _topRightRadius:Number = 0;
		
		[Bindable]
		public function get topRightRadius():Number
		{
			return _topRightRadius;
		}
		
		public function set topRightRadius(value:Number):void
		{
			_topRightRadius = value;
		}
		
		
		private var _bottomLeftRadius:Number = 0;
		
		[Bindable]
		public function get bottomLeftRadius():Number
		{
			return _bottomLeftRadius;
		}
		
		public function set bottomLeftRadius(value:Number):void
		{
			_bottomLeftRadius = value;
		}
		
		
		private var _bottomRightRadius:Number = 0;
		
		[Bindable]
		public function get bottomRightRadius():Number
		{
			return _bottomRightRadius;
		}
		
		public function set bottomRightRadius(value:Number):void
		{
			_bottomRightRadius = value;
		}
		
		
		private var _hasIndicator:Boolean = false;

		[Bindable]
		public function get hasIndicator():Boolean
		{
			return _hasIndicator;
		}

		public function set hasIndicator(value:Boolean):void
		{
			_hasIndicator = value;
		}

		
		private var _indicatorOn:Boolean = false;

		[Bindable]
		public function get indicatorOn():Boolean
		{
			return _indicatorOn;
		}

		public function set indicatorOn(value:Boolean):void
		{
			if(_indicatorOn != value)
			{
				_indicatorOn = value;
				this.invalidateSkinState();
			}
		}

		private var _textAlignment:String = "center";
		
		[Bindable]
		public function get textAlignmentProp():String
		{
			return _textAlignment;
		}
		
		public function set textAlignmentProp(value:String):void
		{
			_textAlignment = value;
		}
	}
}