package widgets
{
	import assets.skins.skinToggleBarButton;
	
	import flash.events.Event;
	
	import spark.components.Group;
	import spark.components.supportClasses.ButtonBarHorizontalLayout;
	import spark.layouts.VerticalLayout;

	[Style(name="cornerRadius", inherit="no", type="int", format="int")]
	[Event(name="selectedIndexChangedEvent", type="flash.events.Event")]
	public class wToggleButtonBar extends Group
	{
		public static const SELECTED_INDEX_CHANGED_EVENT:String = "selectedIndexChangedEvent";
		public static const HORIZONTAL_ORIENTATION:int = 0;
		public static const VERTICAL_ORIENTATION:int = 1;
		
		private var _buttonList:Vector.<wToggleButton>;
		private var _prevSelectedIndex:int;
		private var _selectedIndex:int;
		private var _spacing:int;
		private var _orientation:int;
		private var _cornerRadius:int;
		
		public function wToggleButtonBar()
		{
			_buttonList = new Vector.<wToggleButton>();	
			_orientation = HORIZONTAL_ORIENTATION;
			_prevSelectedIndex = -1;
			_selectedIndex = 0;
			_spacing = 0;
			_cornerRadius = 3;
			this.layout = new ButtonBarHorizontalLayout();
			(this.layout as ButtonBarHorizontalLayout).gap = _spacing;
		}
		
		public override function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			if((!styleProp || styleProp == "styleName" || styleProp == "cornerRadius") && _buttonList)
			{
				if(_orientation == HORIZONTAL_ORIENTATION)
				{
					_buttonList[0].setStyle("bottomLeftRadius", _cornerRadius);
					_buttonList[0].setStyle("topLeftRadius", _cornerRadius);
					
					if(_buttonList.length > 1)
					{
						_buttonList[_buttonList.length - 1].setStyle("bottomRightRadius", _cornerRadius);
						_buttonList[_buttonList.length - 1].setStyle("topRightRadius", _cornerRadius);
					}
				}
				else
				{
					_buttonList[0].setStyle("topRightRadius", _cornerRadius);
					_buttonList[0].setStyle("topLeftRadius", _cornerRadius);
					
					if(_buttonList.length > 1)
					{
						_buttonList[_buttonList.length - 1].setStyle("bottomRightRadius", _cornerRadius);
						_buttonList[_buttonList.length - 1].setStyle("bottomLeftRadius", _cornerRadius);
					}
				}
				
			}
		}
		
		public function buttonAt(index:int):wToggleButton
		{
			return _buttonList[index];	
		}
		
		public function set Buttons(btns:Array):void
		{
			if(btns.length == 0)
				return;
			
			_buttonList = new Vector.<wToggleButton>();
			this.removeAllElements();
			for(var i:int = 0; i < btns.length; i++)
			{
				var newButton:wToggleButton = new wToggleButton();
				newButton.setStyle("skinClass", skinToggleBarButton);
				newButton.id = "btn" + i;
				newButton.label = btns[i].hasOwnProperty("label") ? btns[i].label : "";
				if(btns[i].hasOwnProperty("icon"))
				{
					newButton.setStyle("icon", btns[i].icon);
				}
				newButton.setStyle("cornerRadius", 0);
				//If the orientation is horizontal then add the button and let ButtonBarHorizontalLayout 
				//do its stuff, however as there is not a similar version for a vertical button bar the buttons
				//need to be measured and sized 'manually'.
				if(_orientation == VERTICAL_ORIENTATION)
				{
					newButton.percentWidth = 100;
					
					if(isNaN(this.explicitHeight))
						newButton.percentHeight = 100 / btns.length;
					else
						newButton.height = (this.height - ((btns.length - 1) * _spacing)) / btns.length;
				}
				
				newButton.addEventListener(wToggleButton.SELECTED_CHANGED_EVENT, changeSelectedButton);
				this.addElement(newButton);
				_buttonList.push(newButton);
			}
			
			this.setStyle("cornerRadius", 3);
			_buttonList[_selectedIndex].selected = true;
		}
		
		private function changeSelectedButton(event:Event):void
		{
			var btn:wToggleButton = event.target as wToggleButton;
			if(btn.selected)
			{
				if(parseInt(btn.id.substr(3)) != _selectedIndex) //If a different item has been previously selected
				{
					_prevSelectedIndex = _selectedIndex;
					_selectedIndex = parseInt(btn.id.substr(3));
					_buttonList[_prevSelectedIndex].selected = false;
					_buttonList[_prevSelectedIndex].invalidateSkinState();
					this.dispatchEvent(new Event(SELECTED_INDEX_CHANGED_EVENT));
				}
			}
			else if(parseInt(btn.id.substr(3)) == _selectedIndex)
			{
				btn.selected = true;
			}
		}
		
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		
		public function set selectedIndex(value:int):void
		{
			if(value < _buttonList.length)
			{
				_buttonList[value].selected = true;
				_buttonList[value].invalidateSkinState();
			}
		}
		
		public function get spacing():int
		{
			return _spacing;
		}
		
		public function set spacing(value:int):void
		{
			_spacing = value;
			if(_orientation == HORIZONTAL_ORIENTATION)
				(this.layout as ButtonBarHorizontalLayout).gap = value;
			else
				(this.layout as VerticalLayout).gap = value;
			this.invalidateSize();
		}
		
		public function get orientation():int
		{
			return _orientation;
		}
		
		public function set orientation(value:int):void
		{
			_orientation = value;
			
			this.layout = (value == HORIZONTAL_ORIENTATION) ? new ButtonBarHorizontalLayout() : new VerticalLayout();
			
			if(value == HORIZONTAL_ORIENTATION)
				(this.layout as ButtonBarHorizontalLayout).gap = _spacing;
			else
				(this.layout as VerticalLayout).gap = _spacing;
			
			var btnArr:Array = new Array();
			for each(var btn:wToggleButton in _buttonList)
			{
				//btnArr.push(btn);
				var btnObj:Object = new Object();
					btnObj.label = btn.label;
					btnObj.icon = btn.getStyle("icon");
				btnArr.push(btnObj);
			}
			this.Buttons = btnArr;
		}
		
		[Bindable]
		public function get cornerRadius():int
		{
			return _cornerRadius;
		}
		
		public function set cornerRadius(value:int):void
		{
			_cornerRadius = value;
			this.setStyle('cornerRadius', value);
		}		
	}
}