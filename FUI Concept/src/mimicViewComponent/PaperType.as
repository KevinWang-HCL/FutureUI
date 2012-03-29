package mimicViewComponent
{
	import flash.display.BitmapData;
	
	import integration.ApplicationSettings;

	public class PaperType
	{
		//Orientation enumerations
		public static const LANDSCAPE:int = 0;
		public static const PORTRAIT:int = 1;
		
		//Paper type enumerations
		public static const STANDARD:int = 0;
		public static const HEAVY:int = 1;
		public static const RECYCLED:int = 2;
		public static const PUNCHED:int = 3;
		
		//Paper colour values
		public static const WHITE:uint = 0xFFFFFF;
		public static const RED:uint = 0xFF0000;
		public static const BLUE:uint = 0x63FFFF;
		public static const GREEN:uint = 0x94FF9C;
		public static const ORANGE:uint = 0xFF8400;
		public static const PINK:uint = 0xFFC4FF;
		public static const YELLOW:uint = 0xFFFF77;
		public static const BUFF:uint = 0xFFDE9C;
		public static const GOLDEN_ROD:uint = 0xFFC600;
		public static const GRAY:uint = 0xD8D8D8;
		public static const IVORY:uint = 0xFFFFC2;
		
		private static const PAPER_COLOUR_LOOKUP:Array = [
			{name:"white", colour:WHITE},
			{name:"red", colour:RED}, {name:"blue", colour:BLUE},
			{name:"green", colour:GREEN}, {name:"orange", colour:ORANGE},
			{name:"pink", colour:PINK}, {name:"yellow", colour:YELLOW},
			{name:"buff", colour:BUFF}, {name:"goldenrod", colour:GOLDEN_ROD},
			{name:"gray", colour:GRAY}, {name:"ivory", colour:IVORY}
		];
		
		private static const PAPER_SIZE_LOOKUP:Array = [
			{name:"auto", longEdge:297, shortEdge:210},
			{name:"a3", longEdge:420, shortEdge:297},
			{name:"a4", longEdge:297, shortEdge:210},
			{name:"letter85x11", longEdge:279, shortEdge:216},
			{name:"env10", longEdge:241, shortEdge:104}
		];
		
		private static function capitaliseFirstLetter(string:String):String
		{
			return string.charAt(0).toUpperCase() + string.substr(1);
		}
		
		public static function formatTrayInfoToPaperType(tinf:Object):PaperType
		{
			var w_mm:int = 0;
			var h_mm:int = 0;
			var colour:uint = 0;
			var name:String = "";
			
			for each(var ob:Object in PAPER_SIZE_LOOKUP)
			{
				if(tinf.paperSize == ob.name)
				{
					var paperName:String = capitaliseFirstLetter(ob.name);
					if(paperName.substr(0, 6) == "Letter")
						paperName = "Letter";
					
					if(ob.name == "auto")
						name = "Auto"
					else
						name = paperName + " " + capitaliseFirstLetter(tinf.orientation);
					
					if(tinf.orientation == "landscape")
					{
						w_mm = ob.longEdge;
						h_mm = ob.shortEdge;
					}
					else
					{
						w_mm = ob.shortEdge;
						h_mm = ob.longEdge;
					}
					break;
				}
			}
			
			if(name == "")
			{
				name = "A4 ";
				w_mm = 297;
				h_mm = 210;
			}
			
			//Set colour
			for each(var o:Object in PAPER_COLOUR_LOOKUP)
			{
				if(o.name == tinf.paperColor) 
				{
					colour = o.colour;
					
					if(name.search("Auto") == -1) //If the name so far isn't Auto
						name += " " + capitaliseFirstLetter(o.name);
					break;
				}
			}
			
			if(colour == 0)
				colour = WHITE;
			
			var p:PaperType = new PaperType(name, w_mm, h_mm, STANDARD, colour);
			return p;
		}
		
		private var _name:String;
		private var _w_mm:Number;
		private var _h_mm:Number;
		private var _orientation:int;
		private var _colour:uint;
		private var _type:int;
		private var _bitmapData:BitmapData;
		
		/**
		 * Constructor for the PaperType class.
		 * @param width_mm width of the paper type in millimetres. Defaults to A4.
		 * @param height_mm height of the paper type in millimetres. Defaults to A4.
		 * @param dpi dpi of the paper type as represented in an image.
		 **/
		public function PaperType(name:String, width_mm:Number = 210, height_mm:Number = 297, type:int = STANDARD, colour:uint = WHITE)
		{
			this._name = name;
			this._w_mm = width_mm;
			this._h_mm = height_mm;
			this._type = type;
			this._colour = colour;
			this._orientation = (width_mm > height_mm) ? LANDSCAPE : PORTRAIT;
			
			//var dpi:int = ApplicationSettings.get().get(ApplicationSettings.PRESCAN_DPI);
			var dpi:Number = ApplicationSettings.get().get(ApplicationSettings.MIMIC_DPI);
			//this._bitmapData = new BitmapData(width_mm/25.4 * MimicViewer.SCAN_DPI, height_mm/25.4 * MimicViewer.SCAN_DPI, false, colour);
			this._bitmapData = new BitmapData(width_mm/25.4 * dpi, height_mm/25.4 * dpi, false, colour);
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get widthMillimeters():Number
		{
			return _w_mm;
		}
		
		public function set widthMillimeters(value:Number):void
		{
			_w_mm = value;
		}
		
		public function get heightMillimeters():Number
		{
			return _h_mm;
		}
		
		public function set heightMillimeters(value:Number):void
		{
			_h_mm = value;
		}
		
		public function get orientation():int
		{
			return _orientation;
		}
		
		public function set orientation(value:int):void
		{
			_orientation = value;
		}
		
		public function get colour():uint
		{
			return _colour;
		}
		
		public function get colourRGBArray():Array
		{
			var arr:Array = new Array();
			
			arr[0] = ((_colour >> 16) & 0xFF) / 255.0;
			arr[1] = ((_colour >> 8) & 0xFF) / 255.0;
			arr[2] = (_colour & 0xFF) / 255.0;
			
			return arr;
		}
		
		public function set colour(value:uint):void
		{
			_colour = value;
		}
		
		public function get type():int
		{
			return _type;
		}
		
		public function set type(value:int):void
		{
			this._type = value;
		}
		
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}

		public function set bitmapData(value:BitmapData):void
		{
			_bitmapData = value;
		}

		public function toString():String
		{
			return "[" + _name + ", " + _w_mm + ", " + _h_mm + ", " + ((orientation == PORTRAIT)?"Portrait":"Landscape") + ", " + colourRGBArray + ", " + type + "]";
		}


	}
}