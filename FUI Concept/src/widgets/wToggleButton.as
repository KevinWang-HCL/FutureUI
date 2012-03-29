package widgets
{
	import assets.embedded.Sounds;
	import assets.skins.skinToggleButton;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.states.State;
	
	import spark.components.Button;

	[Style(name="bottomLeftRadius", inherit="no", type="uint")]
	[Style(name="bottomRightRadius", inherit="no", type="uint")]
	[Style(name="topLeftRadius", inherit="no", type="uint")]
	[Style(name="topRightRadius", inherit="no", type="uint")]
	[Style(name="cornerRadius", inherit="no", type="uint")]
	[Style(name="textAlignment", inherit="no", type="String")]
	[Event(name="selectedChangedEvent", type="flash.events.Event")]
	[Bindable]
	public class wToggleButton extends Button
	{
		public static var SELECTED_CHANGED_EVENT:String = "selectedChangedEvent";
		private var _selected:Boolean = false;
		
		//Corner radius properties.
		private var _blR:Number = 0, _brR:Number = 0, _tlR:Number = 0, _trR:Number = 0;
		
		//Text alignment prop: valid values are center, left and right
		private var _textAlignment:String = "center";
		
		public function wToggleButton()
		{
			super();
			
			var upState:State = new State();
				upState.name = "up";
			var selectedState:State = new State();
				selectedState.name = "selected";
			var overState:State = new State();
				overState.name = "over";
			var downState:State = new State();
				downState.name = "down";
			var disabledState:State = new State();
				disabledState.name = "disabled";
			this.states = [upState, selectedState, overState, downState, disabledState];
			this.currentState = "up";
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			//this.addEventListener(MouseEvent.CLICK, mouseClickHandler);
			this.setStyle("skinClass", assets.skins.skinToggleButton);
		}
		
		public override function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			if(!styleProp)
			{
				var alignment:String = getStyle("textAlignment");
				if(!alignment)
					alignment = "center";
				textAlignmentProp = alignment;
				
				if(getStyle("cornerRadius"))
				{
					var radius:uint = getStyle("cornerRadius");
					bottomLeftRadius = radius;
					bottomRightRadius = radius;
					topLeftRadius = radius;
					topRightRadius = radius;
				}
			}
			else
			{
				switch(styleProp)
				{
					case "cornerRadius":
						var rad:uint = getStyle(styleProp);
						bottomLeftRadius = rad;
						bottomRightRadius = rad;
						topLeftRadius = rad;
						topRightRadius = rad;
						break;
					case "bottomLeftRadius":
						bottomLeftRadius = getStyle(styleProp);
						break;
					case "bottomRightRadius":
						bottomRightRadius = getStyle(styleProp);
						break;
					case "topLeftRadius":
						topLeftRadius = getStyle(styleProp);
						break;
					case "topRightRadius":
						topRightRadius = getStyle(styleProp);
						break;
					case "textAlignment":
						textAlignmentProp = getStyle(styleProp);
						break;
				}
			}
		}
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			Sounds.soundClick();
			this.selected = !_selected;
		}
		
		protected override function getCurrentSkinState():String
		{
			return this.currentState;
		}

		public function get selected():Boolean
		{
			return _selected;
		}

		public function set selected(value:Boolean):void
		{
			if(value != _selected)
			{
				this._selected = value;
				this.currentState = value ? "selected" : "up";
				this.dispatchEvent(new Event(SELECTED_CHANGED_EVENT));
			}
		}

		public function get bottomLeftRadius():Number
		{
			return _blR;
		}
		
		public function set bottomLeftRadius(value:Number):void
		{
			_blR = value;
		}
		
		public function get bottomRightRadius():Number
		{
			return _brR;
		}
		
		public function set bottomRightRadius(value:Number):void
		{
			_brR = value;
		}
		
		public function get topLeftRadius():Number
		{
			return _tlR;
		}
		
		public function set topLeftRadius(value:Number):void
		{
			_tlR = value;
		}
		
		public function get topRightRadius():Number
		{
			return _trR;
		}
		
		public function set topRightRadius(value:Number):void
		{
			_trR = value;
		}
		
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