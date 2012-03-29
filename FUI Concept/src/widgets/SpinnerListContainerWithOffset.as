package widgets
{
	import spark.components.SpinnerListContainer;
	
	public class SpinnerListContainerWithOffset extends SpinnerListContainer
	{
		private var _shadowVisible:Boolean = true;
		private var _drawBackground:Boolean = true;

		public function SpinnerListContainerWithOffset()
		{
			super();
		}
		
		public function get drawBackground():Boolean
		{
			return _drawBackground;
		}
		
		public function set drawBackground(value:Boolean):void
		{
			_drawBackground = value;
		}
		
		public function get shadowVisible():Boolean
		{
			return _shadowVisible;
		}
		
		public function set shadowVisible(value:Boolean):void
		{
			_shadowVisible = value;
		}
	}
}