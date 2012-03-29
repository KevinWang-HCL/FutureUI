package widgets
{
	import itemRenderers.ScrollListEmailFaxItemRenderer;
	
	import mx.events.FlexEvent;
	
	import spark.components.supportClasses.ItemRenderer;
	
	public class ScrollListItemBaseRenderer extends ItemRenderer
	{
		public static const ITEM_HEIGHT:int = 58;
		public static const ITEM_EXPAND_HEIGHT:int = 158;
		
		public static const ITEM_BOTTOM_BORDER_HEIGHT:int = 4; 
		
		public static const ITEM_STATE_NORMAL:int = 0;
		public static const ITEM_STATE_EXPANDED:int = 2;
		
		/***************************************
		 * current state for the item, NORMAL or EXPANDED
		 ***************************************/
		
		[Bindable]
		protected var currentItemState:int;
		
		/***************************************
		 * Object to hold new state and previous 
		 * state
		 ***************************************/
		protected var rendererData:Object = null;
		
		/***************************************
		 * Function overridable for item state
		 * change, item height will be changed 
		 * (itemHeight is called) if the function
		 * returns true, else height will not 
		 * change. 
		 ***************************************/
		protected function expandedItemCreateCompleted(event:FlexEvent) : void
		{
			var item:ScrollListItemData = data as ScrollListItemData;
			item.listOwner.itemStateChange(item, item.itemHeight, this.measuredHeight, true);
			item.itemHeight = this.measuredHeight;
		}
		
		override protected function getCurrentRendererState():String
		{
			if (currentState == 'expanded')
			{
				return 'expanded'
			}
			
			return super.getCurrentRendererState();
		}
		
		protected function onItemStateChange(from:int, to:int, dataChange:Boolean) : Boolean
		{			
			if (to == ITEM_STATE_EXPANDED)
			{
				currentState = 'expanded';
			} else {
				currentState = 'normal';
				var item:ScrollListItemData = data as ScrollListItemData;
				item.listOwner.itemStateChange(item, item.itemHeight, ITEM_HEIGHT, false);
				item.itemHeight = ITEM_HEIGHT;
			}
			
			return true;
		}
		
		protected override function commitProperties():void
		{
			super.commitProperties();
			
			if (rendererData.currentItemState != rendererData.prevItemState)
			{
				//Item state is changed, so adjust the item height according to 
				//item state
				if (onItemStateChange(rendererData.prevItemState, rendererData.currentItemState, false))
				{
					itemHeight(rendererData.currentItemState);
				}

				rendererData.prevItemState = rendererData.currentItemState;
			}
		}

		[Bindable]
		override public function get data():Object
		{
			return super.data;
		}
		
		override public function set data(value:Object):void
		{
			if (value)
			{
				super.data = value;
				rendererData = value;
				currentItemState = rendererData.currentItemState;
				
				if (onItemStateChange(rendererData.prevItemState, rendererData.currentItemState, true))
				{
				    itemHeight(currentItemState);
				}
				
				if (this is ScrollListEmailFaxItemRenderer)
				{
					data.showEmailFax = true;
				}
				else
				{
					data.showEmailFax = false;
				}
			}
		}
		
		protected function itemHeight(state:int):void
		{
			(data as ScrollListItemData).itemHeight = height;
		}
	}
}