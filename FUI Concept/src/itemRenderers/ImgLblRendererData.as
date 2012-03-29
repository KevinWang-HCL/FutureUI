package itemRenderers
{
	[Bindable]
	public class ImgLblRendererData
	{
		private var _index:int;
		private var _itemName:String;
		private var _image:*;
		
		public function ImgLblRendererData()
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

		public function get image():*
		{
			return _image;
		}

		public function set image(value:*):void
		{
			_image = value;
		}


	}
}