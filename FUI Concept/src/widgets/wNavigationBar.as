package widgets
{
	import spark.components.Group;

	public class wNavigationBar extends Group
	{
		private var _buttonList:Array;
		private var _remeasureButtons:Boolean;
		
		public function wNavigationBar()
		{
			_buttonList = new Array();
			_remeasureButtons = false;
		}
		
		protected override function measure():void
		{
			super.measure();
			var totalWidth:Number = _buttonList[0].measuredWidth;
			for(var i:int = 1; i < _buttonList.length; i++)
			{
				_buttonList[i].x = totalWidth;
				totalWidth += _buttonList[i].measuredWidth;
			}
		}
		
		/**
		 * Pushes a new nav button onto the end of the current heirarchy.
		 * This function creates a new button with the given information from the 
		 * object provided before adding it to the bar.
		 * The provided data object should contain:
		 * id (String) : a unique identifier for the button. (Required because label could be empty or not unique).
		 * label (String) : a text label displayed on the button
		 * icon (*) : an icon displayed on the button
		 * clickHandler (Function) : called when the button is clicked.
		 */
		public function pushNavStage(obj:Object):void
		{
			var newBtn:wNavigationButton = new wNavigationButton(obj.id, obj.label, obj.icon, obj.clickHandler);
			newBtn.percentHeight = 100;
			_buttonList.push(newBtn);
			this.addElementAt(newBtn, 0);
		}
		
		/**
		 * Pushes an already created navigation button to end of the current heirarchy.
		 */
		public function pushNavButton(btn:wNavigationButton):void
		{
			btn.percentHeight = 100;
			_buttonList.push(btn);
			this.addElementAt(btn, 0);
		}
		
		/**
		 * Removes the most recently added navigation button from the heirarchy.
		 */
		public function popNavStage():void
		{
			//Shouldn't be able to pop the root 'stage'.
			if(_buttonList.length > 1)
			{
				_buttonList.pop();
				this.removeElementAt(0);
			}
		}
		
		private function popAndReturnAll():Array
		{
			var newList:Array = new Array();
			for(var i:int = _buttonList.length-1; i >= 0; i++)
				newList[i] = popNavStage();
			return newList;
		}
		
		public function set rootStage(obj:Object):void
		{
			if(_buttonList.length == 0)
				pushNavStage(obj);
			else
			{
				var newBtn:wNavigationButton = new wNavigationButton(obj.id, obj.label, obj.icon, obj.clickHandler);
				var newList:Array = popAndReturnAll();
				newList[0] = newBtn;
				for each(var btn:wNavigationButton in newList)
				{
					pushNavButton(btn);		
				}
			}
		}
	}
}