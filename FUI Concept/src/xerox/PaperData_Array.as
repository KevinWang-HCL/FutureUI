package xerox
{
	import assets.embedded.Paper_Icons;

	public class PaperData_Array
	{
		
		public var paperSizeArray:Array;  
		public var paperTypeArray:Array;  
		public var paperIconArrayL1:Array; //"col1 = size, col2 = type, color3 = color, color4=orientation 
		public var paperIconArrayL2:Array; //"col1 = size, col2 = type, color3 = color, color4=orientation 
		
		public function PaperData_Array()
		{
			setPaperSizes();
			setPaperTypes();
			setPaperIcons();
		}

		public function setPaperSizes(): void
		{
			paperSizeArray = new Array;
			var i:int = 0;
			
			paperSizeArray[i++] = ["auto",         "Auto"];
			paperSizeArray[i++] = ["letter85x11",  "Letter 8.5x11"];
			paperSizeArray[i++] = ["a4",           "A4"];
			paperSizeArray[i++] = ["a3",           "A3"];
			paperSizeArray[i++] = ["env10",        "Env10"];
			paperSizeArray[i++] = ["custom",        "Custom"];
			
		}

		public function setPaperTypes(): void
		{
			paperTypeArray = new Array;
			var i:int = 0;
			
			paperTypeArray[i++] = ["auto",  "Auto"];
			paperTypeArray[i++] = ["plain",  "Plain"];
			paperTypeArray[i++] = ["punched",  "Punched"];
			paperTypeArray[i++] = ["envelope",  "Envelope"];
			paperTypeArray[i++] = ["letterhead",  ""];
			paperTypeArray[i++] = ["preprinted",  "Preprint"];
			paperTypeArray[i++] = ["transparency",  "Transparency"];
			paperTypeArray[i++] = ["precutTabs",  "Precut Tabs"];
			paperTypeArray[i++] = ["custom1",  "Custom1"];
			paperTypeArray[i++] = ["custom2",  "Custom2"];
			paperTypeArray[i++] = ["custom3",  "Custom3"];
			paperTypeArray[i++] = ["custom4",  "Custom4"];
			paperTypeArray[i++] = ["custom5",  "Custom5"];
			paperTypeArray[i++] = ["custom6",  "Custom6"];
			paperTypeArray[i++] = ["custom7",  "Custom7"];
		}
		
		public function setPaperIcons():void
		{
			paperIconArrayL1 = new Array; 
			paperIconArrayL2 = new Array; 
			//PaperIconArrayL3 = new Array; 
			var i:int = 0;
			paperIconArrayL1[i++] = ["auto",    "auto",    "auto",    "portrait",  Paper_Icons.ps_auto_32Class];
			//Portrait
			paperIconArrayL1[i++] = ["",        "plain",   "blue",    "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_BlueClass];
			paperIconArrayL1[i++] = ["",        "plain",   "buff",    "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_BuffClass];
			paperIconArrayL1[i++] = ["",        "plain",   "clear",   "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_ClearClass];
			paperIconArrayL1[i++] = ["",        "plain",   "custom1",  "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_Custom1Class];
			paperIconArrayL1[i++] = ["",        "plain",   "custom2",  "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_Custom2Class];
			paperIconArrayL1[i++] = ["",        "plain",   "custom3",  "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_Custom3Class];
			paperIconArrayL1[i++] = ["",        "plain",   "custom4",  "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_Custom4Class];
			paperIconArrayL1[i++] = ["",        "plain",   "custom5",  "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_Custom5Class];
			paperIconArrayL1[i++] = ["",        "plain",   "custom6",  "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_Custom6Class];
			paperIconArrayL1[i++] = ["",        "plain",   "custom7",  "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_Custom7Class];
			paperIconArrayL1[i++] = ["",        "plain",   "goldenrod",   "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_GoldenrodClass];
			paperIconArrayL1[i++] = ["",        "plain",   "gray",   "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_GrayClass];
			paperIconArrayL1[i++] = ["",        "plain",   "green",   "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_GreenClass];
			paperIconArrayL1[i++] = ["",        "plain",   "ivory",   "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_IvoryClass];
			paperIconArrayL1[i++] = ["",        "plain",   "orange",   "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_OrangeClass];
			paperIconArrayL1[i++] = ["",        "plain",   "pink",   "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_PinkClass];
			paperIconArrayL1[i++] = ["",        "plain",   "red",   "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_RedClass];
			paperIconArrayL1[i++] = ["",        "plain",   "white",   "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_WhiteClass];
			paperIconArrayL1[i++] = ["",        "plain",   "yellow",   "portrait",  Paper_Icons.Paper_Opt_Color_LEF_32_YellowClass];
			//LandScape
			paperIconArrayL1[i++] = ["",        "plain",   "blue",    "landscape", Paper_Icons.Paper_Sum_Plain_SEF_32_BlueClass];
			paperIconArrayL1[i++] = ["",        "plain",   "buff",    "landscape", Paper_Icons.Paper_Sum_Plain_SEF_32_BuffClass];
			paperIconArrayL1[i++] = ["",        "plain",   "clear",    "landscape", Paper_Icons.Paper_Sum_Plain_SEF_32_ClearClass];
			paperIconArrayL1[i++] = ["",        "plain",   "goldenrod",    "landscape", Paper_Icons.Paper_Sum_Plain_SEF_32_GoldenrodClass];
			paperIconArrayL1[i++] = ["",        "plain",   "gray",    "landscape", Paper_Icons.Paper_Sum_Plain_SEF_32_GrayClass];
			paperIconArrayL1[i++] = ["",        "plain",   "green",    "landscape", Paper_Icons.Paper_Sum_Plain_SEF_32_GreenClass];
			paperIconArrayL1[i++] = ["",        "plain",   "ivory",    "landscape", Paper_Icons.Paper_Sum_Plain_SEF_32_IvoryClass];
			paperIconArrayL1[i++] = ["",        "plain",   "orange",    "landscape", Paper_Icons.Paper_Sum_Plain_SEF_32_OrangeClass];
			paperIconArrayL1[i++] = ["",        "plain",   "pink",    "landscape", Paper_Icons.Paper_Sum_Plain_SEF_32_PinkClass];
			paperIconArrayL1[i++] = ["",        "plain",   "red",    "landscape", Paper_Icons.Paper_Sum_Plain_SEF_32_RedClass];
			paperIconArrayL1[i++] = ["",        "plain",   "white",   "landscape",  Paper_Icons.Paper_Sum_Plain_SEF_32_WhiteClass];
			paperIconArrayL1[i++] = ["",        "plain",   "yellow",   "landscape",  Paper_Icons.Paper_Sum_Plain_SEF_32_YellowClass];
			//Precut Portrait
			paperIconArrayL1[i++] = ["",        "precutTabs", "blue",    "portrait", Paper_Icons.Paper_Sum_PreCutTab_LEF_32_BlueClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "Buff",    "portrait", Paper_Icons.Paper_Sum_PreCutTab_LEF_32_BuffClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "clear",    "portrait", Paper_Icons.Paper_Sum_PreCutTab_LEF_32_ClearClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "goldenrod",    "portrait", Paper_Icons.Paper_Sum_PreCutTab_LEF_32_GoldenrodClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "gray",    "portrait", Paper_Icons.Paper_Sum_PreCutTab_LEF_32_GrayClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "green",    "portrait", Paper_Icons.Paper_Sum_PreCutTab_LEF_32_GreenClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "ivory",    "portrait", Paper_Icons.Paper_Sum_PreCutTab_LEF_32_IvoryClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "orange",    "portrait", Paper_Icons.Paper_Sum_PreCutTab_LEF_32_OrangeClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "pink",    "portrait", Paper_Icons.Paper_Sum_PreCutTab_LEF_32_PinkClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "red",    "portrait", Paper_Icons.Paper_Sum_PreCutTab_LEF_32_RedClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "white",    "portrait", Paper_Icons.Paper_Sum_PreCutTab_LEF_32_WhiteClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "yellow",    "portrait", Paper_Icons.Paper_Sum_PreCutTab_LEF_32_YellowClass];
			//Precut Landscape
			paperIconArrayL1[i++] = ["",        "precutTabs", "blue",    "landscape", Paper_Icons.Paper_Sum_PreCutTab_SEF_32_BlueClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "Buff",    "landscape", Paper_Icons.Paper_Sum_PreCutTab_SEF_32_BuffClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "clear",    "landscape", Paper_Icons.Paper_Sum_PreCutTab_SEF_32_ClearClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "goldenrod",    "landscape", Paper_Icons.Paper_Sum_PreCutTab_SEF_32_GoldenrodClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "gray",    "landscape", Paper_Icons.Paper_Sum_PreCutTab_SEF_32_GrayClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "green",    "landscape", Paper_Icons.Paper_Sum_PreCutTab_SEF_32_GreenClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "ivory",    "landscape", Paper_Icons.Paper_Sum_PreCutTab_SEF_32_IvoryClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "orange",    "landscape", Paper_Icons.Paper_Sum_PreCutTab_SEF_32_OrangeClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "pink",    "landscape", Paper_Icons.Paper_Sum_PreCutTab_SEF_32_PinkClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "red",    "landscape", Paper_Icons.Paper_Sum_PreCutTab_SEF_32_RedClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "white",    "landscape", Paper_Icons.Paper_Sum_PreCutTab_SEF_32_WhiteClass];
			paperIconArrayL1[i++] = ["",        "precutTabs", "yellow",    "landscape", Paper_Icons.Paper_Sum_PreCutTab_SEF_32_YellowClass];
			
			//Envelope Portrait
			paperIconArrayL1[i++] = ["",        "envelope", "blue",    "portrait", Paper_Icons.Paper_Sum_Envelope_LEF_32_BlueClass];
			paperIconArrayL1[i++] = ["",        "envelope", "Buff",    "portrait", Paper_Icons.Paper_Sum_Envelope_LEF_32_BuffClass];
			paperIconArrayL1[i++] = ["",        "envelope", "clear",    "portrait", Paper_Icons.Paper_Sum_Envelope_LEF_32_ClearClass];
			paperIconArrayL1[i++] = ["",        "envelope", "goldenrod",    "portrait", Paper_Icons.Paper_Sum_Envelope_LEF_32_GoldenrodClass];
			paperIconArrayL1[i++] = ["",        "envelope", "gray",    "portrait", Paper_Icons.Paper_Sum_Envelope_LEF_32_GrayClass];
			paperIconArrayL1[i++] = ["",        "envelope", "green",    "portrait", Paper_Icons.Paper_Sum_Envelope_LEF_32_GreenClass];
			paperIconArrayL1[i++] = ["",        "envelope", "ivory",    "portrait", Paper_Icons.Paper_Sum_Envelope_LEF_32_IvoryClass];
			paperIconArrayL1[i++] = ["",        "envelope", "orange",    "portrait", Paper_Icons.Paper_Sum_Envelope_LEF_32_OrangeClass];
			paperIconArrayL1[i++] = ["",        "envelope", "pink",    "portrait", Paper_Icons.Paper_Sum_Envelope_LEF_32_PinkClass];
			paperIconArrayL1[i++] = ["",        "envelope", "red",    "portrait", Paper_Icons.Paper_Sum_Envelope_LEF_32_RedClass];
			paperIconArrayL1[i++] = ["",        "envelope", "white",    "portrait", Paper_Icons.Paper_Sum_Envelope_LEF_32_WhiteClass];
			paperIconArrayL1[i++] = ["",        "envelope", "yellow",    "portrait", Paper_Icons.Paper_Sum_Envelope_LEF_32_YellowClass];
			//Precut Landscape
			paperIconArrayL1[i++] = ["",        "envelope", "blue",    "landscape", Paper_Icons.Paper_Sum_Envelope_SEF_32_BlueClass];
			paperIconArrayL1[i++] = ["",        "envelope", "Buff",    "landscape", Paper_Icons.Paper_Sum_Envelope_SEF_32_BuffClass];
			paperIconArrayL1[i++] = ["",        "envelope", "clear",    "landscape", Paper_Icons.Paper_Sum_Envelope_SEF_32_ClearClass];
			paperIconArrayL1[i++] = ["",        "envelope", "goldenrod",    "landscape", Paper_Icons.Paper_Sum_Envelope_SEF_32_GoldenrodClass];
			paperIconArrayL1[i++] = ["",        "envelope", "gray",    "landscape", Paper_Icons.Paper_Sum_Envelope_SEF_32_GrayClass];
			paperIconArrayL1[i++] = ["",        "envelope", "green",    "landscape", Paper_Icons.Paper_Sum_Envelope_SEF_32_GreenClass];
			paperIconArrayL1[i++] = ["",        "envelope", "ivory",    "landscape", Paper_Icons.Paper_Sum_Envelope_SEF_32_IvoryClass];
			paperIconArrayL1[i++] = ["",        "envelope", "orange",    "landscape", Paper_Icons.Paper_Sum_Envelope_SEF_32_OrangeClass];
			paperIconArrayL1[i++] = ["",        "envelope", "pink",    "landscape", Paper_Icons.Paper_Sum_Envelope_SEF_32_PinkClass];
			paperIconArrayL1[i++] = ["",        "envelope", "red",    "landscape", Paper_Icons.Paper_Sum_Envelope_SEF_32_RedClass];
			paperIconArrayL1[i++] = ["",        "envelope", "white",    "landscape", Paper_Icons.Paper_Sum_Envelope_SEF_32_WhiteClass];
			paperIconArrayL1[i++] = ["",        "envelope", "yellow",    "landscape", Paper_Icons.Paper_Sum_Envelope_SEF_32_YellowClass];
			
			//Layer 2			
			var j:int = 0;
			//Portrait
			paperIconArrayL2[j++] = ["",        "gloss",   		 "",        "portrait",  Paper_Icons.Paper_Sum_Overlay_LEF_32_GlossClass];
			paperIconArrayL2[j++] = ["",        "heavyweight",   "",        "portrait",  Paper_Icons.Paper_Sum_Overlay_LEF_32_HeavyClass];
			paperIconArrayL2[j++] = ["",        "punched",       "",        "portrait",  Paper_Icons.Paper_Sum_Overlay_LEF_32_HolePunchedClass];
			paperIconArrayL2[j++] = ["",        "labels",        "",        "portrait",  Paper_Icons.Paper_Sum_Overlay_LEF_32_LabelsClass];
			paperIconArrayL2[j++] = ["",        "letterhead",    "",        "portrait",  Paper_Icons.Paper_Sum_Overlay_LEF_32_LetterheadClass];
			paperIconArrayL2[j++] = ["",        "lightweight",   "",        "portrait",  Paper_Icons.Paper_Sum_Overlay_LEF_32_LightClass];
			paperIconArrayL2[j++] = ["",        "other",    "",        "portrait", Paper_Icons.Paper_Sum_Overlay_LEF_32_OtherClass];
			paperIconArrayL2[j++] = ["",        "preprinted",    "",        "portrait", Paper_Icons.Paper_Sum_Overlay_LEF_32_PreprintedClass];
			paperIconArrayL2[j++] = ["",        "recyecled",    "",        "portrait", Paper_Icons.Paper_Sum_Overlay_LEF_32_RecycledClass];
			paperIconArrayL2[j++] = ["",        "roughStock",    "",        "portrait", Paper_Icons.Paper_Sum_Overlay_LEF_32_RoughPaperClass];
			paperIconArrayL2[j++] = ["",        "transparency",    "",        "portrait", Paper_Icons.Paper_Sum_Overlay_LEF_32_TransparencyClass];
			paperIconArrayL2[j++] = ["",        "custom1",    "",        "portrait", Paper_Icons.Paper_Sum_Overlay_LEF_32_Custom1Class];
			paperIconArrayL2[j++] = ["",        "custom2",    "",        "portrait", Paper_Icons.Paper_Sum_Overlay_LEF_32_Custom2Class];
			paperIconArrayL2[j++] = ["",        "custom3",    "",        "portrait", Paper_Icons.Paper_Sum_Overlay_LEF_32_Custom3Class];
			paperIconArrayL2[j++] = ["",        "custom4",    "",        "portrait", Paper_Icons.Paper_Sum_Overlay_LEF_32_Custom4Class];
			paperIconArrayL2[j++] = ["",        "custom5",    "",        "portrait", Paper_Icons.Paper_Sum_Overlay_LEF_32_Custom5Class];
			paperIconArrayL2[j++] = ["",        "custom6",    "",        "portrait", Paper_Icons.Paper_Sum_Overlay_LEF_32_Custom6Class];
			paperIconArrayL2[j++] = ["",        "custom7",    "",        "portrait", Paper_Icons.Paper_Sum_Overlay_LEF_32_Custom7Class];
			
			//Landscape
			paperIconArrayL2[j++] = ["",        "gloss",   		 "",        "landscape",  Paper_Icons.Paper_Sum_Overlay_SEF_32_GlossClass];
			paperIconArrayL2[j++] = ["",        "heavyweight",   "",        "landscape",  Paper_Icons.Paper_Sum_Overlay_SEF_32_HeavyClass];
			paperIconArrayL2[j++] = ["",        "punched",       "",        "landscape",  Paper_Icons.Paper_Sum_Overlay_SEF_32_HolePunchedClass];
			paperIconArrayL2[j++] = ["",        "labels",        "",        "landscape",  Paper_Icons.Paper_Sum_Overlay_SEF_32_LabelsClass];
			paperIconArrayL2[j++] = ["",        "letterhead",    "",        "landscape",  Paper_Icons.Paper_Sum_Overlay_SEF_32_LetterheadClass];
			paperIconArrayL2[j++] = ["",        "lightweight",   "",        "landscape",  Paper_Icons.Paper_Sum_Overlay_SEF_32_LightClass];
			paperIconArrayL2[j++] = ["",        "other",    "",        "landscape", Paper_Icons.Paper_Sum_Overlay_SEF_32_OtherClass];
			paperIconArrayL2[j++] = ["",        "preprinted",    "",        "landscape", Paper_Icons.Paper_Sum_Overlay_SEF_32_PreprintedClass];
			paperIconArrayL2[j++] = ["",        "recyecled",    "",        "landscape", Paper_Icons.Paper_Sum_Overlay_SEF_32_RecycledClass];
			paperIconArrayL2[j++] = ["",        "roughStock",    "",        "landscape", Paper_Icons.Paper_Sum_Overlay_SEF_32_RoughPaperClass];
			paperIconArrayL2[j++] = ["",        "transparency",    "",        "landscape", Paper_Icons.Paper_Sum_Overlay_SEF_32_TransparencyClass];
			paperIconArrayL2[j++] = ["",        "custom1",    "",        "landscape", Paper_Icons.Paper_Sum_Overlay_SEF_32_Custom1Class];
			paperIconArrayL2[j++] = ["",        "custom2",    "",        "landscape", Paper_Icons.Paper_Sum_Overlay_SEF_32_Custom2Class];
			paperIconArrayL2[j++] = ["",        "custom3",    "",        "landscape", Paper_Icons.Paper_Sum_Overlay_SEF_32_Custom3Class];
			paperIconArrayL2[j++] = ["",        "custom4",    "",        "landscape", Paper_Icons.Paper_Sum_Overlay_SEF_32_Custom4Class];
			paperIconArrayL2[j++] = ["",        "custom5",    "",        "landscape", Paper_Icons.Paper_Sum_Overlay_SEF_32_Custom5Class];
			paperIconArrayL2[j++] = ["",        "custom6",    "",        "landscape", Paper_Icons.Paper_Sum_Overlay_SEF_32_Custom6Class];
			paperIconArrayL2[j++] = ["",        "custom7",    "",        "landscape", Paper_Icons.Paper_Sum_Overlay_SEF_32_Custom7Class];
		}

	}
}