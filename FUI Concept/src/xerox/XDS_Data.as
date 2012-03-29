package xerox
{
	import integration.CopySettings;
	
	import mimicViewComponent.PaperType;
	
	import mx.collections.ArrayCollection;

	public class XDS_Data
	{
		import xerox.XDS_Main;
		public var xdsMain:XDS_Main;
		
		//--------------------------------------------------------------------------------------------------------		
		private static var paperData:PaperData_Array = new PaperData_Array;
		private var _pPaperTrayInfo:Array;
		[Bindable]
		public function get paperTrayInfo():Array {
			return _pPaperTrayInfo;
		}
		public function set paperTrayInfo(value:Array):void {
			_pPaperTrayInfo = value;
 		   //CopySettings.get().set(CopySettings.AVAILABLE_TRAYS, value);
			CopySettings.get().set(CopySettings.AVAILABLE_PAPER_TYPES, formatPaperTrayInfo(value));
			
			var mimicFormattedTypes:Array = new Array();
			for each(var o:Object in value)
			{
				mimicFormattedTypes.push(PaperType.formatTrayInfoToPaperType(o));	
			}
			trace("XDS_DATA TRAY INFO FORMATTED: " + mimicFormattedTypes);
			CopySettings.get().set(CopySettings.MIMIC_FORMATTED_PAPER_TYPES, mimicFormattedTypes);
		}
		//--------------------------------------------------------------------------------------------------------		
		private var _pFinisherInfo:Object;
		[Bindable]
		public function get finisherInfo():Object {
			return _pFinisherInfo;
		}
		public function set finisherInfo(value:Object):void {
			_pFinisherInfo = value;
			//CopySettings.get().set(CopySettings.AVAILABLE_FINISHING_TYPES, value);
		}
		//--------------------------------------------------------------------------------------------------------		
		private var _pCopyQuantitiy:int;
		[Bindable]
		public function get copyQuantitiy():int {
			return _pCopyQuantitiy;
		}
		public function set copyQuantitiy(value:int):void {
			_pCopyQuantitiy = value;
			//CopySettings.get().set(CopySettings.NUM_COPIES, value);
		}
		//--------------------------------------------------------------------------------------------------------		
		private var _pCopySides:String;
		[Bindable]
		public function get copySides():String {
			return _pCopySides;
		}
		public function set copySides(value:String):void {
			_pCopySides = value;
			//CopySettings.get().set(CopySettings.OUTPUT_SIDES, value);
		}
		//--------------------------------------------------------------------------------------------------------		
		private var _pCopyColor:String;
		[Bindable]
		public function get copyColor():String {
			return _pCopyColor;
		}
		public function set copyColor(value:String):void {
			_pCopyColor = value;
			//CopySettings.get().set(CopySettings.COLOUR_TYPE, value);
		}
		
		//--------------------------------------------------------------------------------------------------------		
		private var pCRUHFSIInfo:Array;
		[Bindable]
		public function get CRUHFSIInfo():Array {
			return pCRUHFSIInfo;
		}
		public function set CRUHFSIInfo(value:Array):void {
			pCRUHFSIInfo = value;
		}
		
		//--------------------------------------------------------------------------------------------------------		
		private var _pSelectedPaperTrayNum:int;
		[Bindable]
		public function get selectedPaperTrayNum():int {
			return _pSelectedPaperTrayNum;
		}
		
		public function set selectedPaperTrayNum(value:int):void {
			_pSelectedPaperTrayNum = value;
			//CopySettings.get().set(CopySettings.TRAYNUM_SELECTED, value);
			//CopySettings.get().set(CopySettings.PAPER_TYPE, value);
		}
		//--------------------------------------------------------------------------------------------------------		
		
		public function XDS_Data()
		{
		}

		public function Initialize():void
		{
			//Set "paperTrayInfo" Default
			var defaultPaperTray:Array = new Array;
			var defaultPaperTrayNum:int = 7;  
			for(var i:int = 0; i < defaultPaperTrayNum; i++)
			{
				var trayObject:Object = new Object;
				trayObject.trayNumber = i;
				switch( i )
				{
					case 0:
						trayObject.paperSize = "auto";
						trayObject.paperColor = "auto";
						trayObject.paperType = "auto";
						trayObject.orientation = "portrait";
						break;
					case 1:
						trayObject.paperSize = "a3";
						trayObject.paperColor = "yellow";
						trayObject.paperType = "precutTabs";
						trayObject.orientation = "landscape";
						break;
					case 2:
						trayObject.paperSize = "letter85x11";
						trayObject.paperColor = "blue";
						trayObject.paperType = "letterhead";
						trayObject.orientation = "portrait";
						break;
					case 3:
						trayObject.paperSize = "a4";
						trayObject.paperColor = "blue";
						trayObject.paperType = "punched";
						trayObject.orientation = "portrait";
						break;
					case 4:
						trayObject.paperSize = "a4";
						trayObject.paperColor = "blue";
						trayObject.paperType = "punched";
						trayObject.orientation = "portrait";
						break;
					case 5:
						trayObject.paperSize = "env10";
						trayObject.paperColor = "yellow";
						trayObject.paperType = "custom2";
						trayObject.orientation = "portrait";
						break;
					default:
						trayObject.paperSize = "a3";
						trayObject.paperColor = "orange";
						trayObject.paperType = "custom1";
						trayObject.orientation = "landscape";
						break;
				}
				
				defaultPaperTray[i] = trayObject;
			}
			
			paperTrayInfo = defaultPaperTray;
			
			//Set "finisherInfo" default:
			var defaultFinisherInfo:Object = new Object;
			defaultFinisherInfo.finisherType = "hvfFinisherBMTrifolderWithInserter";
			defaultFinisherInfo.stapler = "multi";
			defaultFinisherInfo.folding = "advancedNoZHalf";
			defaultFinisherInfo.bookletMaker = "true";
			defaultFinisherInfo.punchHoles = "punch2or3or4";
			defaultFinisherInfo.creasing = "true";  //optional
			defaultFinisherInfo.duplexCapable = "true"; //optional
			finisherInfo = defaultFinisherInfo;
			
			
			//CRUHFSIInfo
			var defaultCRUHFSIInfo:Array = new Array;
			var defaultCRUHFSIInfoNum:int = 4;  
			for(var i:int = 0; i < defaultCRUHFSIInfoNum; i++)
			{
				var cruObject:Object = new Object;
				switch( i )
				{
					case 0:
						cruObject.name = "magentaInkStick";
						cruObject.percentRemaining = "20";
						break;
					case 1:
						cruObject.name = "cyanInkStick";
						cruObject.percentRemaining = "40";
						break;
					case 2:
						cruObject.name = "yellowInkStick";
						cruObject.percentRemaining = "60";
						break;
					case 3:
						cruObject.name = "blackInkStick";
						cruObject.percentRemaining = "80";
						break;
					default:
						break;
				}
				
				defaultCRUHFSIInfo[i] = cruObject;
			}
			
			CRUHFSIInfo = defaultCRUHFSIInfo;
			
			selectedPaperTrayNum = 1;
			copyQuantitiy = 1;
			copyColor = "green";
			copySides = "oneToOne";
		}
	
		public static function formatPaperTrayInfo(trayInfo:Array):ArrayCollection
		{
			var formattedData:ArrayCollection = new ArrayCollection;
			
			var ignoreSamePaper:Boolean = false;
			
			var objectIndex:int = 0;
			
			for(var i:int = 0; i < trayInfo.length; i++)
			{
				//filter the same one	
				ignoreSamePaper = false;
				for( var j:int = 0; j<i; j++ )
				{
					if( trayInfo[j].paperSize == trayInfo[i].paperSize &&
						trayInfo[j].paperColor == trayInfo[i].paperColor &&
						trayInfo[j].paperType == trayInfo[i].paperType &&
						trayInfo[j].orientation == trayInfo[i].orientation )
					{
						ignoreSamePaper = true;
						break;
					}
				}
				if (ignoreSamePaper)
					continue;
				
				var formattedObject:Object = new Object();
				//Fill in the item number
				formattedObject.index = trayInfo[i].trayNumber;
				
				//Fill in the item name
				formattedObject.itemName = null;
				for ( var x:int=0; x< paperData.paperSizeArray.length; x++ )
				{
					if( paperData.paperSizeArray[x][0] == trayInfo[i].paperSize )
					{
						formattedObject.itemName = paperData.paperSizeArray[x][1];
						break;
					}
				}
				for ( var y:int=0; y< paperData.paperTypeArray.length; y++ )
				{
					if( paperData.paperTypeArray[y][0] == trayInfo[i].paperType && trayInfo[i].paperType != "auto")
					{
						formattedObject.itemName += " " + paperData.paperTypeArray[y][1];
						break;
					}
				}
				
				//Fill in the item icon
				formattedObject.image = new Array;
				formattedObject.image[0] = null;
				
				for(var j:int = 0; j < paperData.paperIconArrayL1.length; j++)
				{
					if( trayInfo[i].paperType != "auto" && trayInfo[i].paperType != "envelope" && trayInfo[i].paperType != "precutTabs" )
					{   //default to plain paper
						if( paperData.paperIconArrayL1[j][1] == "plain" && 
							paperData.paperIconArrayL1[j][2] == trayInfo[i].paperColor &&
							paperData.paperIconArrayL1[j][3] == trayInfo[i].orientation )
						{
							formattedObject.image[0] = paperData.paperIconArrayL1[j][4];
							break;
						}
					}
					else
					{ // auto or envelope or precutTabs
						if( paperData.paperIconArrayL1[j][1] == trayInfo[i].paperType && 
							paperData.paperIconArrayL1[j][2] == trayInfo[i].paperColor &&
							paperData.paperIconArrayL1[j][3] == trayInfo[i].orientation ) 
						{
							formattedObject.image[0] = paperData.paperIconArrayL1[j][4];	
							break;
						}
					}
				}
				
				if( formattedObject.image[0] != null )
				{
					for(var k:int = 0; k < paperData.paperIconArrayL2.length; k++)
					{
						if( paperData.paperIconArrayL2[k][1] == trayInfo[i].paperType )
						{
							formattedObject.image[1] = paperData.paperIconArrayL2[k][4];
							break;
						}
					}
				}
				else
					trace("**** Error: Paper No Image: " + i);
				
				//formattedData[objectIndex++] = formattedObject;
				formattedData.addItem(formattedObject);
				objectIndex++;
			}
			
			
			//filter the duplicated one
			return formattedData;
		}
		
		
	}
}