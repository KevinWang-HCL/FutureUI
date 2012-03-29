package ImagePlugins.Redaction
{
	import MimicPlugin.ImageEditModule;
	import MimicPlugin.ImageEffect;
	
	import flash.display.BitmapData;
	import flash.events.TransformGestureEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mimicViewComponent.EditImage;
	
	import mx.graphics.SolidColor;
	
	import spark.primitives.Rect;
	
	public class RedactionEffect implements ImageEffect
	{
		public static const WEIGHTING_PROPERTY:String = "redactWeighting";
		public static const COLOUR_PROPERTY:String = "redactColour";
		
		private var id:int;
		private var creatorModule:RedactionModule;
		private var rect:Rect;
		private var rotation:Number;
		private var weight:int;
		private var type:int;
		
		public function RedactionEffect(id:int, pos:Point, weight:int, type:int, creator:RedactionModule)
		{
			this.id = id;
			rect = new Rect();
			this.type = type;
			creatorModule = creator;
			if(type == RedactionModule.PLACE_LINE)
			{
				rect.x = pos.x;
				rect.y = pos.y - weight / 2;
				rect.height = weight;
			}
			else if(type == RedactionModule.PLACE_RECT)
			{
				rect.x = pos.x;
				rect.y = pos.y;
			}
			
		}
		
		public function setProperty(propName:String, value:*):void
		{
			if(propName == WEIGHTING_PROPERTY)
			{
				weight = value;
				if(type == RedactionModule.PLACE_LINE)
				{
					//Undo previous weighting and alter y to account for new weighting
					rect.y = (rect.y + rect.height/2) - (value / 2);
					rect.height = value;
				}
			}
			else if(propName == COLOUR_PROPERTY)
			{
				rect.fill = new SolidColor(value, 1.0);	
			}
		}

		public function setEndPoint(endX:Number, endY:Number):void
		{
			if(type == RedactionModule.PLACE_LINE)
			{
				var rotVecX:Number = endX - rect.x;
				var rotVecY:Number = endY - rect.y;
				rect.width = Math.sqrt(rotVecX*rotVecX + rotVecY*rotVecY);
				rotation = Math.atan2(rotVecY, rotVecX) * (180/Math.PI);
				rect.rotationZ = rotation;
			}
			else if(type == RedactionModule.PLACE_RECT)
			{
				if(endX > rect.x) 
					rect.width = endX - rect.x;
				else
				{
					rect.width += rect.x - endX;
					rect.x = endX;
				}
				
				if(endY > rect.y)
					rect.height = endY - rect.y;
				else
				{
					rect.height += rect.y - endY;
					rect.y = endY;
				}
			}
		}
		
		public function showOnImage(image:EditImage):void
		{
			image.effectOverlay.addElement(rect);
		}
		
		public function removeFromImage(image:EditImage):void
		{
			image.effectOverlay.removeElement(rect);
		}
		
		public function applyToBitmapData(data:BitmapData):void
		{
			var mat:Matrix;
			
			if(type == RedactionModule.PLACE_LINE)
			{
				trace("DRAWING LINE");
				mat = new Matrix();
				mat.rotate(rect.rotationZ * Math.PI / 180);
				mat.translate(rect.x, rect.y);
			}
			trace(rect.x, rect.y + ", " + mat);
			data.draw(rect.displayObject, mat, null, null, null, true);
		}
		
		public function isAfterEffect():Boolean
		{
			return true;
		}
		
		public function getClassification():String
		{
			return "redaction" + id;
		}
		
		public function get parentModule():ImageEditModule
		{
			return creatorModule;
		}
		
		public function set parentModule(value:ImageEditModule):void
		{
			creatorModule = value as RedactionModule;
		}
	}
}