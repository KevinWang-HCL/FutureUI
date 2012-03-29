package widgets
{
	import flash.display.Graphics;
	
	import spark.skins.mobile.SpinnerListContainerSkin;
	
	public class SkinSpinnerListContainer extends SpinnerListContainerSkin
	{
		static public const selectionIndicatorHeight:int = 58;
		
		public function SkinSpinnerListContainer()
		{
			super();
			selectionIndicatorHeight = selectionIndicatorHeight;
			selectionIndicatorClass = SpinnerListSelectorClass;
			borderClass = SpinnerListBorderClass;
			borderThickness = 0;
			shadowClass = SpinnerListShadowClass;
			cornerRadius = 6;
		}
		
		/**
		 *  @private
		 */
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.layoutContents(unscaledWidth, unscaledHeight);
			
			// The SpinnerLists contain a left and right border. We don't want to show the leftmost 
			// SpinnerLists's left border nor the rightmost one's right border. 
			// We inset the mask on the left and right sides to accomplish this. 
			var g:Graphics = contentGroupMask.graphics;
			g.clear();
			g.beginFill(0x00FF00);
/*			g.drawRoundRect(borderThickness * 2, borderThickness, 
				unscaledWidth - borderThickness * 4,
				unscaledHeight - borderThickness * 2,
				cornerRadius, cornerRadius);*/
			g.drawRoundRect(0,0,unscaledWidth-1,unscaledHeight, cornerRadius, cornerRadius);
			g.endFill();     
		}
	}
}