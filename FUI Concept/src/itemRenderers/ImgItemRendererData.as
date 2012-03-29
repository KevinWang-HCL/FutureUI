package itemRenderers
{
	[Bindable]
	public class ImgItemRendererData
	{
		private var _index:int;
		private var _image:*;
		
		public function ImgItemRendererData()
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