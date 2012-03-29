package itemRenderers
{
	[Bindable]
	public class LblRendererData
	{
		private var _index:int;
		private var _itemName:String;
		
		public function LblRendererData()
		{
		}
		
		public function get index():int
		{
			return _index;
		}
		
		public function set index(value:int):void
		{
			_index = value;
		}
		
		public function get itemName():String
		{
			return _itemName;
		}
		
		public function set itemName(value:String):void
		{
			_itemName = value;
		}
	}
}