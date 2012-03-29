package itemRenderers
{
	[Bindable]
	public class ScrollerLabelRendererData
	{
		private var _title:String;
		
		public function ScrollerLabelRendererData()
		{
		}
		
		public function get title():String
		{
			return _title;
		}
		
		public function set title(value:String):void
		{
			_title = value;
		}
	}
}