package integration
{
	import mimicViewComponent.PaperType;
	
	import mx.collections.ArrayCollection;
	
	import xerox.XDS_Data;

	public class CopySettings
	{
		public static const NUM_COPIES:String = "NumCopies";
		public static const NUM_COPIES_DEFAULT:int = 1;
		
		public static const INPUT_SIDES:String = "InputSides";
		public static const INPUT_SIDES_DEFAULT:int = 1;
		
		public static const OUTPUT_SIDES:String = "SidesOut";
		public static const OUTPUT_SIDES_DEFAULT:int = 2;
		
		
		private static const paperTypeDefaultArray:Array = [{paperSize:"auto", paperColor:"auto", paperType:"auto", orientation:"portrait"},
			{paperSize:"a4", paperColor:"white", paperType:"standard", orientation:"landscape"},
			{paperSize:"a3", paperColor:"white", paperType:"standard", orientation:"landscape"},
			{paperSize:"letter85x11", paperColor:"ivory", paperType:"heavy", orientation:"portrait"},
			{paperSize:"letter85x11", paperColor:"white", paperType:"standard", orientation:"landscape"},
			{paperSize:"letter85x11", paperColor:"pink", paperType:"standard", orientation:"landscape"}];
		
		public static const AVAILABLE_PAPER_TYPES:String = "AvailablePaperTypes";
		public static const AVAILABLE_PAPER_TYPES_DEFAULT:ArrayCollection = XDS_Data.formatPaperTrayInfo(paperTypeDefaultArray); //TODO
		
		public static const PAPER_TYPE:String = "PaperType"; //Determined by paper types in machine trays.
		public static var PAPER_TYPE_DEFAULT:int = 0; //Making this a var is a dirty great hack.
		public static const MIMIC_FORMATTED_PAPER_TYPES:String = "MimicPaperTypes";
		public static const MIMIC_FORMATTED_PAPER_TYPES_DEFAULT:Array = [ new PaperType("Autoselect"),
																			new PaperType("A4 Plain", 297, 210),
																			new PaperType("A3 Plain", 420, 297, PaperType.STANDARD, PaperType.WHITE),
																			new PaperType("11\"x8.5\" Heavy", 216, 279, PaperType.HEAVY, PaperType.IVORY),
																			new PaperType("8.5\"x11\" Punched", 279, 216, PaperType.PUNCHED, PaperType.WHITE),
																			new PaperType("8.5\"x11\" Plain", 279, 216, PaperType.STANDARD, PaperType.PINK)];
		
		public static const COLOUR_TYPE:String = "ColourType"; //Auto-colour, colour, black & white, red, green, blue, cyan, magenta, yellow
		public static const COLOUR_AUTO:String = "auto", COLOUR_FULL:String = "color", COLOUR_GRAYSCALE:String = "blackwhite",
							COLOUR_RED:String = "red", COLOUR_GREEN:String = "green", COLOUR_BLUE:String = "blue",
							COLOUR_CYAN:String = "cyan", COLOUR_MAGENTA:String = "magenta", COLOUR_YELLOW:String = "yellow";
		public static const COLOUR_TYPE_DEFAULT:String = COLOUR_AUTO;
		
		public static const AVAILABLE_COLOUR_TYPES:String = "AvailableColourTypes";
		public static const AVAILABLE_COLOUR_TYPES_DEFAULT:Array = [ COLOUR_GRAYSCALE, COLOUR_AUTO, COLOUR_FULL, COLOUR_RED, COLOUR_GREEN, COLOUR_BLUE, COLOUR_CYAN, COLOUR_MAGENTA, COLOUR_YELLOW ];
		
		
		public static const AVAILABLE_FINISHING_TYPES:String = "AvailableFinishes";
		public static const AVAILABLE_FINISHING_TYPES_DEFAULT:Array = [ "Off", "Collated", "Stapled", "Punched", "Stapled & Punched", "Folded", "Creased" ];
		public static const FINISHING_TYPE:String = "FinishingType"; //Off, collated, stapled, punched, stapled & punched, folded, creased
		public static const FINISHING_TYPE_DEFAULT:int = 0;
		//Finishing sub-settings
		//Option A
		public static const FOLD_TYPE:String = "FoldType"; //No-fold, single fold, c fold, z fold, half z fold, creased
		public static const FOLD_NONE:int = 0, FOLD_SINGLE:int = 1, FOLD_Z:int = 2, FOLD_HALF_Z:int = 3, FOLD_C:int = 4;
		public static const FOLD_TYPE_DEFAULT:int = FOLD_NONE;
		
		//Option B
		public static const STAPLE_TYPE:String = "StapleType"; 
		public static const STAPLE_NONE:int = 0, STAPLE_1_LEFT:int = 1, STAPLE_2:int = 2, STAPLE_3:int = 3, STAPLE_4:int = 4;
		public static const STAPLE_TYPE_DEFAULT:int = STAPLE_NONE;
		
		//Option C
		public static const HOLEPUNCH_TYPE:String = "HolepunchType"; //2 holes, 3 holes, 4 holes, 4 holes - swedish.
		public static const HOLEPUNCH_NONE:int = 0, HOLEPUNCH_2_HOLES:int = 1, HOLEPUNCH_3_HOLES:int = 2, HOLEPUNCH_4_HOLES:int = 3, HOLEPUNCH_4_SWEDISH:int = 4; 
		public static const HOLEPUNCH_TYPE_DEFAULT:int = HOLEPUNCH_NONE;
		
		//Option D
		public static const COLLATED:String = "Collated";
		public static const COLLATED_DEFAULT:Boolean = false;
		
		//Option E
		public static const FORMAT_AS_BOOKLET:String = "FormatAsBooklet";
		public static const FORMAT_AS_BOOKLET_DEFAULT:Boolean = false;
		
		//Option F
		public static const FOLD_GROUPING:String = "FoldGrouping"; //Fold individually, fold as set
		public static const FOLD_INDIVIDUALLY:int = 0, FOLD_AS_SET:int = 1;
		public static const FOLD_GROUPING_DEFAULT:int = FOLD_INDIVIDUALLY;
		
		//Option G
		public static const IMAGE_SIDE:String = "ImageSide";
		public static const IMAGE_INSIDE_CREASE:int = 0, IMAGE_OUTSIDE_CREASE:int = 1;
		public static const IMAGE_SIDE_DEFAULT:int = IMAGE_INSIDE_CREASE;
		
		
		//Edges are stored in the following order: top, right, bottom, left.
		public static const EDGE_ERASE:String = "EdgeErase";
		public static const EDGE_ERASE_DEFAULT:Array = [3, 3, 3, 3];
		
		private static var _instance:SettingsMap = null;
		
		public static function get():SettingsMap
		{
			if(!_instance)
			{
				_instance = new SettingsMap();
				_instance.set(JobSettings.INPUT_SIDES, 1);
				_instance.set(JobSettings.ORIENTATION, JobSettings.ORIENTATION_LANDSCAPE);
				_instance.set(NUM_COPIES, NUM_COPIES_DEFAULT);
				_instance.set(INPUT_SIDES, INPUT_SIDES_DEFAULT);
				_instance.set(OUTPUT_SIDES, OUTPUT_SIDES_DEFAULT);
				_instance.set(AVAILABLE_PAPER_TYPES, AVAILABLE_PAPER_TYPES_DEFAULT);
				
				
				var mimicFormattedPaperTypeDefaults:Array = new Array();
				for each(var obj:Object in paperTypeDefaultArray)
					mimicFormattedPaperTypeDefaults.push(PaperType.formatTrayInfoToPaperType(obj));
				_instance.set(MIMIC_FORMATTED_PAPER_TYPES, mimicFormattedPaperTypeDefaults);
				_instance.set(PAPER_TYPE, PAPER_TYPE_DEFAULT);
				_instance.set(AVAILABLE_COLOUR_TYPES, AVAILABLE_COLOUR_TYPES_DEFAULT);
				_instance.set(COLOUR_TYPE, COLOUR_TYPE_DEFAULT);
				_instance.set(AVAILABLE_FINISHING_TYPES, AVAILABLE_FINISHING_TYPES_DEFAULT);
				_instance.set(FINISHING_TYPE, FINISHING_TYPE_DEFAULT);
				_instance.set(FOLD_TYPE, FOLD_TYPE_DEFAULT);
				_instance.set(STAPLE_TYPE, STAPLE_TYPE_DEFAULT);
				_instance.set(HOLEPUNCH_TYPE, HOLEPUNCH_TYPE_DEFAULT);
				_instance.set(COLLATED, COLLATED_DEFAULT);
				_instance.set(FORMAT_AS_BOOKLET, FORMAT_AS_BOOKLET_DEFAULT);
				_instance.set(FOLD_GROUPING, FOLD_GROUPING_DEFAULT);
				_instance.set(IMAGE_SIDE, IMAGE_SIDE_DEFAULT);
				_instance.set(EDGE_ERASE, EDGE_ERASE_DEFAULT);
			}
			
			return _instance;
		}
		
		public static function setDefaults():void
		{
			if(!_instance)
			{
				_instance = new SettingsMap();
			}
			//_instance.set(JobSettings.INPUT_SIDES, 1);
			//_instance.set(JobSettings.ORIENTATION, JobSettings.ORIETNTAION_LANDSCAPE);
			_instance.set(NUM_COPIES, NUM_COPIES_DEFAULT);
			_instance.set(INPUT_SIDES, INPUT_SIDES_DEFAULT);
			_instance.set(OUTPUT_SIDES, OUTPUT_SIDES_DEFAULT);
			_instance.set(PAPER_TYPE, PAPER_TYPE_DEFAULT);
			_instance.set(COLOUR_TYPE, COLOUR_TYPE_DEFAULT);
			_instance.set(FINISHING_TYPE, FINISHING_TYPE_DEFAULT);
			_instance.set(FOLD_TYPE, FOLD_TYPE_DEFAULT);
			_instance.set(STAPLE_TYPE, STAPLE_TYPE_DEFAULT);
			_instance.set(HOLEPUNCH_TYPE, HOLEPUNCH_TYPE_DEFAULT);
			_instance.set(COLLATED, COLLATED_DEFAULT);
			_instance.set(FORMAT_AS_BOOKLET, FORMAT_AS_BOOKLET_DEFAULT);
			_instance.set(FOLD_GROUPING, FOLD_GROUPING_DEFAULT);
			_instance.set(IMAGE_SIDE, IMAGE_SIDE_DEFAULT);
			_instance.set(EDGE_ERASE, EDGE_ERASE_DEFAULT);
		}
	}
}