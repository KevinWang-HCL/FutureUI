package MimicPlugin
{
	import flash.display.BitmapData;
	
	import mimicViewComponent.EditImage;

	public interface ImageEffect
	{
		
		/**
		 * Function to set the value of a property specific to the image effect.
		 */
		function setProperty(propName:String, value:*):void;
		
		/**
		 * Function determining how to show the effect on a bitmap image. 
		 */
		function showOnImage(image:EditImage):void;
		
		/**
		 * Function determining how the effect gets removed from the bitmap image.
		 */
		function removeFromImage(image:EditImage):void;
		
		/**
		 * Function determining how to apply the effect to a bitmap data object. 
		 */
		function applyToBitmapData(data:BitmapData):void;
		
		/**
		 * Returns whether or not the effect is one that should be applied 'last'.
		 * If there're multiple effects that should be applied last then they will
		 * be applied in the order the user added them to the MimicViewer.
		 */
		function isAfterEffect():Boolean;
		
		/**
		 * Returns the classification name of the effect. This is required in order to create
		 * mutually exclusive effects, wherein two effects with the same classification cannot be
		 * applied at the same time.
		 */
		function getClassification():String;
		
		/**
		 * Returns the module that created the image effect.
		 */
		function get parentModule():ImageEditModule;
		
		function set parentModule(value:ImageEditModule):void;
	}
}