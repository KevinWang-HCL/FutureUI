package mimicViewComponent
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	[Bindable]
	public class ImageRectangle
	{
		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
		
		public function ImageRectangle(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0)
		{
			_x = x;
			_y = y;
			_width = width;
			_height = height;
		}
		
		public function contains(x:Number, y:Number):Boolean
		{
			return x >= _x && x <= (_x + _width) && y >= _y && y <= (_y + _height);
		}
		
		/**
		 * Returns a rectangle representing the area of intersection between
		 * this rectangle and the parameter rectangle (relative to the rectangle
		 * this function is called on).
		 */
		public function intersectsWith(rect:ImageRectangle):ImageRectangle
		{
			var intersection:ImageRectangle = new ImageRectangle();
			
			var min:Point = new Point(Math.max(this._x, rect.x), Math.max(this._y, rect.y));
			var max:Point = new Point(Math.min(this._x + this._width, rect.x + rect.width),
									  Math.min(this._y + this._height, rect.y + rect.height));
			
			intersection.x = min.x;
			intersection.y = min.y;
			intersection.width = max.x - min.x;
			intersection.height = max.y - min.y;
			
			return intersection;
		}
		
		public function toRectangle():Rectangle
		{
			return new Rectangle(_x, _y, _width, _height);
		}

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			_y = value;
		}

		public function get width():Number
		{
			return _width;
		}

		public function set width(value:Number):void
		{
			_width = value;
		}

		public function get height():Number
		{
			return _height;
		}

		public function set height(value:Number):void
		{
			_height = value;
		}

		public function copyFrom(source:ImageRectangle):void
		{
			//Property setters used to trigger bindings
			x = source.x;
			y = source.y;
			width = source.width;
			height = source.height;
		}
		
		public function toString():String
		{
			return "(" + x + ", " + y + ", " + width + ", " + height + ")";
		}
		
	}
}