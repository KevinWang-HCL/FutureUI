package widgets
{
	
	import flash.utils.ByteArray;

	public class ScrollListItemData extends Object
	{
		[Bindable]
		public var itemData:Object;
		
		public var currentItemState:int;
		public var prevItemState:int;
		public var playAnimation:Boolean;
		[Bindable]
		public var email:Boolean = true;
		[Bindable]
		public var emailSendType:String = "To";
		[Bindable]
		public var fax:Boolean = false;
		public var showEmailFax:Boolean = false;
		public var itemHeight:int = ScrollListItemBaseRenderer.ITEM_HEIGHT;
		
		public var listOwner:BounceScroller = null;
		
		[Bindable]
		public var userData:Object;
		
		public function ScrollListItemData(obj:Object)
		{
			super();
			
			itemData = obj;
			currentItemState = ScrollListItemBaseRenderer.ITEM_STATE_NORMAL; 
			prevItemState = ScrollListItemBaseRenderer.ITEM_STATE_NORMAL;
			playAnimation = true;
		}
		
		public function clone() : ScrollListItemData
		{
			var buffer:ByteArray = new ByteArray();     
			buffer.writeObject(itemData);     
			buffer.position = 0; 
			
			var res:ScrollListItemData = new ScrollListItemData(buffer.readObject());
			res.userData = userData;
			res.currentItemState = currentItemState;
			res.prevItemState = prevItemState;
			res.playAnimation = playAnimation;
			res.listOwner = listOwner;
			res.email = email;
			res.fax = fax;
			return res;
		}
	}
}
