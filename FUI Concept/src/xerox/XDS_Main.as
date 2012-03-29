// ActionScript file
package xerox
{
	import flash.events.*;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.*;
	
	import integration.ApplicationSettings;
	import integration.CopySettings;
	import integration.ISettingsObserver;
	
	import mx.collections.XMLListCollection;
	import mx.core.FlexGlobals;

	// ActionScript file containing main application logic
	[Event(name="MachineConnectedEvent", type="flash.events.Event")]
	[Event(name="DocHandlerStateChangeEvent", type="xerox.XRX_DataEvent")]
	[Event(name="PrescanProgressEvent", type="xerox.XRX_DataEvent")]
	public class XDS_Main extends EventDispatcher implements ISettingsObserver
	{
		public static const MACHINE_CONNECTED_EVENT:String = "MachineConnectedEvent";
		public static const DOC_HANDLER_CHANGE_EVENT:String = "DocHandlerStateChangeEvent";
		
		//Prescan Progress Events
		public static const PRESCAN_PROGRESS_EVENT:String = "PrescanProgressEvent";
		public static const PRESCAN_SCANNING_EVENT:String = "PrescanScanningEvent";
		public static const PRESCAN_FORMATTING_EVENT:String = "PrescanFormattingEvent";
		public static const PRESCAN_TRANSFERRING_EVENT:String = "PrescanTransferringEvent";
		public static const PRESCAN_COMPLETED:String = "PrescanComplete";
		public static const PRESCAN_FAILED:String = "PrescanFailed";
		
		public var xdsData:XDS_Data;
		private var timerConnectionTimeout:Timer = new Timer(15000, 1);
		//This is to access panelOutput layout
		//public var comppanelOutput:panelOutput;
		
		private var conn:XDS_Socket;
		
		// receiving data
		private var xmlReceivedData:XML = new XML;
		
		// handling sequence data
		//private var xmlFiles:XDS_SequenceXML = new XDS_SequenceXML; // contains the XML files to send to the machine
		private var numSequence:Number = 1; // tracks the sequence of sent and received XML
		private var dicSequenceResponses:Dictionary = new Dictionary;
		
		private var dicDocListDictionay:Dictionary = new Dictionary;
		
		// Job definitions
		private var xmlGetJob:XML = new XML; // used when initialising a type of job
		
		public var xmlCopyJob:XML = new XML; // XML that defines a Copy job. Change node values to desired settings, and send to machine.
		
		
		// manage the preview scan
		public var boolWaitingForJobFinish:Boolean = false;
		//private var previewStatus:String = "inactive"; // by default, no preview is active
		private var previewJobNumber:int;
		
		private var bNeedConnectToMachine:Boolean = false;
		
		// Timeout for preview scan
		private var numPreviewTimeout:Number = 45000; // if Preview does not complete within this time, give up
		private var timerPreviewTimer:Timer = new Timer(numPreviewTimeout, 1);
		
		public static var colorTable:Array = [0, "auto", 1, "blackwhite", 2, "color", 3, "red", 4, "green", 5, "blue", 6, "cyan", 7, "magenta", 8, "yellow"];
		
		// Default connection details
		public var numPort:Number = 49001; // user cannot vary this
		
		// DADF Status - is it raised
		public var DADFRaised:Boolean = false;
		
		// Is there a document in the DADF (doc handler)?
		public var DocOnHandler:Boolean = false;
		
		private var _pxfdStrHost:String; // user can change this in UI
		[Bindable]
		public function get xfdStrHost():String {
			return _pxfdStrHost;
		}
		
		public function set xfdStrHost(value:String):void {
			_pxfdStrHost = value;
		}
		
		private var _isCopying:Boolean = false;
		public function get isCopying():Boolean
		{
			return _isCopying;
		}
		
		public function set isCopying(value:Boolean):void
		{
			_isCopying = value;
		}
		
		// String for when no preview is available
		[Bindable]
		public var xfdStrPreviewStatus:String = "No Preview Available";
		
		public var imagePreviewUnavailable:String = "assets/images/previewUnavailable.png";
		
		[Bindable]
		public var xfdImagePreview:String = imagePreviewUnavailable;
		
		// Default file path for Preview - this is where the device saves the preview scan
		private var _pxfdStrPreviewPath:String; // user can change this in UI
		
		[Bindable]
		public function get xfdStrPreviewPath():String {
			return _pxfdStrPreviewPath;
		}
		
		public function set xfdStrPreviewPath(value:String):void {
			_pxfdStrPreviewPath = value;
		}
		
		// XML that defines the paper trays and their display names
		private var pxfdPaperTrays:XMLListCollection;
		
		[Bindable]
		public function get xfdPaperTrays():XMLListCollection {
			return pxfdPaperTrays;
		}
		
		public function set xfdPaperTrays(value:XMLListCollection):void {
			pxfdPaperTrays = value;
		}
		
		// XML that defines the Color Output options
		private var pxfdColorOutput:XMLListCollection;
		
		[Bindable]
		public function get xfdColorOutput():XMLListCollection {
			return pxfdColorOutput;
		}
		
		public function set xfdColorOutput(value:XMLListCollection):void {
			pxfdColorOutput = value;
		}
			
		/**
		 * Creates a new instance of XDS Main.
		 */ 
		public function XDS_Main() {
			xdsData = new XDS_Data;
			xdsData.xdsMain = this;
			CopySettings.get().registerObserver(this);
			XDS_APICallController.get().registerObserver(this);
			xdsData.Initialize();
			conn = new XDS_Socket();
			conn.addEventListener('SocketAction', SocketActionHandler); // listen for a state change from the socket (e.g. connected, disconnected)
			conn.addEventListener(XRX_DataEvent.EVENT_OCCURRED, XRX_DataEventHandler); // listen for data coming from XDSSocket using custom data event
			
			XDS_DeviceXML.xmlScanToFileDestination.item.server = ApplicationSettings.get().get(ApplicationSettings.LOCAL_IP) + ":139";
			trace("XDS DEVICE XML SERVER: " + XDS_DeviceXML.xmlScanToFileDestination.item.server);
			//populateConfigSettings( );
			//requestConnection();
		}
		
		/**
		 * Load the fuiConfig.xml file for machine settings. This is redundant and should all
		 * be retrieved from ApplicationSettings. Ensure this can be deleted.
		 */
		/*public function populateConfigSettings():void{
			var uRLLoader:URLLoader = new URLLoader();
			var configFileUrl:String = "assets//files//fuiConfig.xml";
			uRLLoader.addEventListener(Event.COMPLETE, configFileLoaded); 
			uRLLoader.load(new URLRequest(configFileUrl));
		}*/
		
		/**
		 * Load event for the fuiConfig.xml loader. Should be redundant, ensure nothing uses this
		 * so it can be deleted.
		 */
		/*private function configFileLoaded(evt:Event):void {
			var xmlData:XML = new XML(evt.target.data);
			bNeedConnectToMachine = ( xmlData.ConnectToMachine.toString() == "false" )? false:true;
			xfdStrPreviewPath = xmlData.PreviewPath;	
			xfdStrHost = xmlData.MachineIP;
			XDS_APICallController.get().set(XDS_APICallController.STATUS_CONFIGFILE_LOADED, true );
		}*/
	
		/**
		 * Function that watches for changes in settings for any settingsmap 
		 * this class is registered to.
		 */
		public function notifySettingChanged(settingName:String, newValue:*):void
		{
			switch( settingName )
			{
				case CopySettings.PAPER_TYPE:
					xdsData.selectedPaperTrayNum = newValue;
					break;
				case CopySettings.NUM_COPIES:
					xdsData.copyQuantitiy = newValue;
					break;
				case CopySettings.COLOUR_TYPE:
					xdsData.copyColor = newValue;
					break;
				case CopySettings.OUTPUT_SIDES:
					xdsData.copySides = newValue;
					break;
				/*case XDS_APICallController.STATUS_CONFIGFILE_LOADED:
					if( newValue == true )
					{
						if( bNeedConnectToMachine )
						  requestConnection();
					}
					break;*/
				case XDS_APICallController.STATUS_MACHINE_CONNECTED:
					if( newValue == true )
					{
						UIAction('InitialiseMachine');
					}
					break;
				case XDS_APICallController.STATUS_MACHINE_INITIALIZED:
					if( newValue == true )
					{
						timerPreviewTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, machineConnectingTimeoutHandler);
						timerPreviewTimer.stop(); // stop the timeout
						UIAction('GetMachineData');
					}
					break;
				case XDS_APICallController.STATUS_MACHINE_SYNC_COMPLETED:
					if( newValue == true )
					{
						this.dispatchEvent(new Event("MachineConnectedEvent"));
					}
					break;
				default:
					break;
			}
			
		}
		
		public function catchImageIOError(evt:Event):void { // if the preview image fails to load show no preview available
			xfdStrPreviewStatus  = "Error Loading Preview";
			xfdImagePreview = imagePreviewUnavailable;
			
		}

		public function getSidesString():String
		{
			var input:int = CopySettings.get().get(CopySettings.INPUT_SIDES);
			var output:int = CopySettings.get().get(CopySettings.OUTPUT_SIDES);
			
			var returnString:String = "";
			
			if(input == 1)
				returnString = "oneTo";
			else
				returnString = "twoTo";
			
			if(output == 1)
				returnString += "One";
			else if(output == 2)
				returnString += "Two";
			else
				returnString += "TwoRotated";
			
			return returnString;
		}
		
		public function getCopySidesIndex(sides:String):int
		{
			var index:int;
			switch( sides )
			{
				case "oneToOne":
					index = 0;
					break;
				case "twoToTwo":
					index = 1;
					break;
				case "rotate":
					index = 2;
					break;
				default:
					index= 0;
					break;
			}
			return index;
		}
		
		public function getCopyColorString(index:int):String
		{
			var color:String;
			
			for( var i:int = 0; i<9; i++ )
			{
				if( colorTable[i*2] == index )
					return colorTable[i*2+1]; 
			}
			
			return "auto";
		}

		public function getCopyColorIndex(color:String):int
		{
			for( var i:int = 0; i<9; i++ )
			{
				if( colorTable[i*2+1] == color )
					return colorTable[i*2]; 
			}
			
			return 0;
		}
				
		private function scan2FileJobTimeoutHandler(evt:Event):void {
			trace("SCAN TO FILE TIMEOUT");
			// timeout has expired, cancel the Preview
			cancelPreview();
			
			// notify the UI
			setUIState('Scan2FileJobTimeout'); // display the job status
		}
		
		private function cancelPreview():void {
			try { // error will occur if no preview in operation, but we just want to continue
				timerPreviewTimer.stop(); // stop the timeout
				
				// remove the event handler to save system resources
				timerPreviewTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, scan2FileJobTimeoutHandler);
			}
			catch (errObject:Error) {
			}
			trace("PREVIEW CANCELLED");
			boolWaitingForJobFinish = false; // no preview scan now in progress
		}
		
		public function UIAction(action:String):void {
			//trace("UI action initiated: " + action);
			// handle the UI event depending on which type it is
			switch (action) {
				case "InitialiseMachine":
					
					trace('initialise');
					// send the sequenced docs that XDS View sends after connection
					// responses include job status
					sendSequenceXML(XDS_DeviceXML.xmlSetDebugClient, funSetDebugClient_Response);
					sendSequenceXML(XDS_DeviceXML.xmlXIADebug, funXIADebug_Response);
					sendSequenceXML(XDS_DeviceXML.xmlClientList, funClientList_Response);
					sendSequenceXML(XDS_DeviceXML.xmlClassList, funClassList_Response);
					sendSequenceXML(XDS_DeviceXML.xmlDocList, funDocList_Response);
					sendSequenceXML(XDS_DeviceXML.xmlGetObjCounters, funGetObjCounters_Response);
					
					break;
				
				case "GetMachineData":
					// request the XML that defines a copy job
					trace("Get Copy Job Default");
					//get copy default
					var refNum:int = dicDocListDictionay["CopyJob"];
					XDS_DeviceXML.xmlGetJobDefaultByRef.XUIRequest.Get.ref = refNum; // specify the type of job required
					sendSequenceXML(XDS_DeviceXML.xmlGetJobDefaultByRef, funGetCopyJobDefault_Response);
										
					trace("Initialising Copy Job");
					//get copy client instance
					XDS_DeviceXML.xmlGetJobDefaultByClassName.XUIRequest.Get["class"] = "CopyJob"; // specify the type of job required
					sendSequenceXML(XDS_DeviceXML.xmlGetJobDefaultByClassName, funGetCopyJobInstance_Response);
					
					//get scan2file client instance
					trace("Initialising ScanToFile Job");
					XDS_DeviceXML.xmlGetJobDefaultByClassName.XUIRequest.Get["class"] = "ScanToFileJob"; // specify the type of job required
					sendSequenceXML(XDS_DeviceXML.xmlGetJobDefaultByClassName, funGetScanToFileJobInstance_Response); // request the job description from the device
					
					// request the XML that defines the device's paper trays
					getDocument("PaperTrayAttributes",funGetPaperTrayAttributes_Response);
					
					// request the XML that provides Copy Service Info. This gives DADF status.
					getDocument("CopyServiceInfo", funGetCopyServiceInfo_Response);
					
					// request the XML that provides MachineConfig Info. This gives finisher information.
					getDocument("MachineConfig", funGetMachineConfig_Response);
					
					// request the XML that provides Xbroser Info. This gives finisher information.
					getDocument("XBrowserData", funGetXBrowserData_Response);
					
					getDocument("CRUHFSIInfo", funGetCRUHFSIInfo_Response);
					
					break;
				
				case "PerformCopyJob":
					var xmlCopyJob:XML = XDS_DeviceXML.xmlCopyJob;
					xmlCopyJob.XUIRequest.ReplaceChild.child("data").CopyJob.command = "submit";
					
					// set the paper tray according to the user's selection
					xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.traySelection=xdsData.selectedPaperTrayNum;
					// set the number of copies according to the user's selection
					xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.job.copyCount=xdsData.copyQuantitiy;
					
					xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.originalSize.mode[0] = getOriginalSizeMode();
					xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.originalSize.manualInput.mode[0] = getOriginalSizeManualSize();
					if( getOriginalSizeManualSize() == "custom" )
					{
						xmlCopyJob.XUIRequest.ReplaceChild.child("data").CopyJob.submit.settings.document.originalSize.manualInput.custom.x[0] = "432";
						xmlCopyJob.XUIRequest.ReplaceChild.child("data").CopyJob.submit.settings.document.originalSize.manualInput.custom.y[0] = "297";
					}
					
					// set the color output according to the user's selection
					if( xdsData.copyColor == "auto" || xdsData.copyColor == "blackwhite" || xdsData.copyColor == "color" )
					    xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.colorOutput.mode=xdsData.copyColor;
					else
					{
						xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.colorOutput.mode="singleColor";
						xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.colorEffects.singleColor = xdsData.copyColor;
					}
					
					var sides:String = getSidesString();
					//if( xdsData.copySides != "rotate" )
					if(sides.search("Rotated") == -1) //If the sides string doesn't contain a Rotated 'flag'
						xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.plex.mode = sides;
					  	//xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.plex.mode = xdsData.copySides;
					else
					{
						//xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.plex.mode = "twoToTwo";
						xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.plex.mode = sides.substr(0, sides.length - 7); //7 is the length of 'Rotated'
						xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.plex.rotateSideTwo = "true";
					}
					  
					var edges:Array = CopySettings.get().get(CopySettings.EDGE_ERASE);
					xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.edgeErase.mode = "edge";
					xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.edgeErase.edge.sideOne.top = edges[0];
					xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.edgeErase.edge.sideOne.right = edges[1];
					xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.edgeErase.edge.sideOne.bottom = edges[2];
					xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.edgeErase.edge.sideOne.left = edges[3];
					//Left and right are mirrored on side two (for exmaple if you want to remove hole punches it'll be the left margin
					//on side one, but the right margin on side two).
					xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.edgeErase.edge.sideTwo.top = edges[0];
					xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.edgeErase.edge.sideTwo.right = edges[3];
					xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.edgeErase.edge.sideTwo.bottom = edges[2];
					xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.edgeErase.edge.sideTwo.left = edges[1];
					
					trace("Sending Copy Job");
					trace(xmlCopyJob);
					boolWaitingForJobFinish = true;
					
					// enable this line to actually send a Copy job
					// otherwise this case just traces the xml
					conn.send(xmlCopyJob);
					break;
				
				case "PerformScanToFileJob":
					cancelPreview(); // end any preview that is in progress
					
					var xmlWorkflowScanJob:XML = XDS_DeviceXML.xmlScanToFileJob;
					// set document name
					xmlWorkflowScanJob.XUIRequest.ReplaceChild.child("data").ScanToFileJob.submit.settings.job.documentName[0] = "preview";
					
					// set document format
//					xmlWorkflowScanJob.XUIRequest.ReplaceChild.child("data").ScanToFileJob.submit.settings.job.fileFormat.format[0] = "jpegImages";
					xmlWorkflowScanJob.XUIRequest.ReplaceChild.child("data").ScanToFileJob.submit.settings.job.fileFormat = "jpegImages";
					// overwrite existing doc (ensures consistent name)
					xmlWorkflowScanJob.XUIRequest.ReplaceChild.child("data").ScanToFileJob.submit.settings.job.filingPolicy[0] = "overwrite";//"newAutoGenerate";
					
					// set original size, since currently I am not lifting the DADF before starting the job
					// should ideally try to auto detect, and only fix scan size if auto detect fails
					xmlWorkflowScanJob.XUIRequest.ReplaceChild.child("data").ScanToFileJob.submit.settings.document.originalSize.mode[0] = getOriginalSizeMode();
					xmlWorkflowScanJob.XUIRequest.ReplaceChild.child("data").ScanToFileJob.submit.settings.document.originalSize.manualInput.mode[0] = getOriginalSizeManualSize();
				    if( getOriginalSizeManualSize() == "custom" )
					{
						xmlWorkflowScanJob.XUIRequest.ReplaceChild.child("data").ScanToFileJob.submit.settings.document.originalSize.manualInput.custom.x[0] = "432";
						xmlWorkflowScanJob.XUIRequest.ReplaceChild.child("data").ScanToFileJob.submit.settings.document.originalSize.manualInput.custom.y[0] = "297";
					}
					//set file destination with log in information otherwise it has no access right to server.
					if( xmlWorkflowScanJob.XUIRequest.ReplaceChild.child("data").ScanToFileJob.submit.settings.job.fileDestinations.length() == 0 )
					{
						xmlWorkflowScanJob.XUIRequest.ReplaceChild.child("data").ScanToFileJob.submit.settings.job.appendChild(XDS_DeviceXML.xmlScanToFileDestination);
						trace("APPENDED SCAN TO FILE DESTINATION XML.");
					}
					else
					{
						trace("REPLACING SCAN TO FILE XML:\n" + xmlWorkflowScanJob.XUIRequest.ReplaceChild.child("data").ScanToFileJob.submit.settings.job);
						xmlWorkflowScanJob.XUIRequest.ReplaceChild.child("data").ScanToFileJob.submit.settings.job.replace("fileDestinations",XDS_DeviceXML.xmlScanToFileDestination);
					}
					trace("REPLACED SCAN TO FILE DESTINATION XML:\n" + xmlWorkflowScanJob.XUIRequest.ReplaceChild.child("data").ScanToFileJob.submit.settings.job);
					//set the resolution					
					xmlWorkflowScanJob.XUIRequest.ReplaceChild.child("data").ScanToFileJob.submit.settings.document.resolution = "72x72";
					
					boolWaitingForJobFinish = true;
					
					var prevImg:File = new File(ApplicationSettings.get().get(ApplicationSettings.PRESCAN_FILE_PATH));
					if(prevImg.exists)
						prevImg.deleteFile();
					conn.send(xmlWorkflowScanJob);
					timerPreviewTimer.start(); // start the preview Timeout counting
					timerPreviewTimer.addEventListener(TimerEvent.TIMER_COMPLETE, scan2FileJobTimeoutHandler); // listen for the timer to complete
					trace("SCAN TO FILE XML SENT");
					break;
				case "PreviewOnly":
					break;
				
			}
		}

		public function getOriginalSizeMode():String {
			var selPaperSize:String = xdsData.paperTrayInfo[xdsData.selectedPaperTrayNum].paperSize;
			var originalSizeMode:String;
			switch( selPaperSize )
			{
				case "auto":
					originalSizeMode = "autoDetect";
					break;
				default: 
					originalSizeMode = "manualInput";
					break;
			}
			
			return originalSizeMode;
			
		}
		
		public function getOriginalSizeManualSize():String {
			var selPaperSize:String = xdsData.paperTrayInfo[xdsData.selectedPaperTrayNum].paperSize;
			var selPaperOrientation:String = xdsData.paperTrayInfo[xdsData.selectedPaperTrayNum].orientation;
			var originalSize:String;
			switch( selPaperSize )
			{
				case "a4":
					originalSize = (selPaperOrientation == "portrait")? "A4LongEdgeFeed": "A4ShortEdgeFeed";
					break;
	            case "a3":
					originalSize = "A3ShortEdgeFeed";
					break;
				default:
					originalSize = "custom";
					break;
			}
			
			return originalSize;
		}
		
		/**
		 *  Provide the default paper tray.
		 *  The UI calls this function to configure the UI
		 * 	#PROBABLY-NOT-USED 
		 **/
		public function getDefaultPaperTray():int {
			var defaultTray:int = xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.traySelection.@default as Number;
			
			// go through the display list of paper trays looking for the default tray
			var i:int;
			if(xfdPaperTrays.length >= 1) { // check there is at least 1 item in array
				for (i = 0; i < (xfdPaperTrays.length); i++) {
					if(xfdPaperTrays[i] == String(defaultTray))
					{
						return i; // return the index of the default within the display list of paper trays
					}
				}
			}
			return -1;
		}
		
		// Provide the default number of copies
		// The UI calls this function to configure the UI
		public function getDefaultNumberOfCopies():int {
			return xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.job.@default as Number;
		}
		
		// Provide the default Color Output option (returns the index)
		public function getDefaultColorOutput():int {
			// get the default value from the CopyJob xml
			var defaultValue:String = xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit.settings.document.colorOutput.mode.@default;
			//trace("Default value: " + defaultValue);
			
			// find the index of the default value within the Color Output xml
			var tempList:XMLList = new XMLList(XDS_DeviceXML.xmlColorOutput.colorOutput); // seem to need to convert the xml to xmlList first - and must drill down below the root node
			var tempListColl:XMLListCollection = new XMLListCollection(tempList); // and then to xmlListCollection
			
			var defaultIndex:int = findValue(tempListColl, "mode", defaultValue);
			// if default value not found, then use index = 0
			
			if (defaultIndex == -1) {
				defaultIndex = 0;
			}
			return defaultIndex;
		}
		
		/** 
		 * loops through all descendant nodes with the specified node name
		 * returns the index of the first node with the specified value
		 */
		private function findValue(myListColl:XMLListCollection, nodeName:String, searchValue:String):int {
			var myList:XMLList = myListColl.descendants(nodeName); // put all the  nodes of the specified name in an XMLList
			var i:int=0;
			for each(var node:XML in myList){
				if(node == searchValue) {
					return i;
				}
				else {
					i++;
				}
			}
			return -1; // value never found
		}
		
		private function SocketActionHandler(event:XRX_EventType):void {
			//trace("Socket action initiated: " + event.arg[0]);
			
			// handle the event depending on which type of event it is
			switch (event.arg[0]) {
				case "StateChangeConnected":
					setUIState("Connected");
					//trace("in connected");
					break;
				
				case "StateChangeDisconnected":
					setUIState("Disconnected");
					break;
			}
		}
		
		private function sendSequenceXML(data:XML, responseFunction:Function):void {
			// sends sequenced XML data to the socket
			data.@sequence = numSequence; // set sequence attribute to next sequence value
			dicSequenceResponses[numSequence] = responseFunction; // record the function to call when the response is received
			trace("Sending data. Sequence: " + numSequence);
			conn.send(data); // send xml to socket
			numSequence++; // increment sequence value - make sure to do this last
		}
		
		//private function getDocument(ref:Number, responseFunction:Function):void {
		private function getDocument(className:String, responseFunction:Function):void  {
			var someXML:XML = new XML;
			someXML  = XDS_DeviceXML.xmlGetDocument;
			//someXML.XUIRequest.Get.ref = ref;
			someXML.XUIRequest.Get["class"] = className;
			sendSequenceXML(someXML,responseFunction);
			
		}
		
		// functions to handle received sequence data i.e. responses to sequenced XML sent data
		private function funSetDebugClient_Response(receivedData:XML):void {
			//trace("SetDebugClient response received");
			setUIState('Initialised');
		}
		
		private function funXIADebug_Response(receivedData:XML):void {
			//trace("XIADebug response received");
			// note that debug has been successfully initialised
			
		}
		
		private function funClientList_Response(receivedData:XML):void {
			//trace("ClientList response received");
		}
		
		private function funClassList_Response(receivedData:XML):void {
			//trace("ClassList response received");
		}
		
		private function funDocList_Response(receivedData:XML):void {
			//trace("DocList response received");
			// Get the list of doc
			var docList:XMLListCollection = new XMLListCollection(receivedData.XUIResponse.child("return").data.doc);
			var refNum:int;
			var className:String;
			
			for(var i:int = 0; i < (docList.length); i++)
			{
				refNum = docList.elements('ref')[i].valueOf();
				className = docList.elements('name')[i].valueOf();
				dicDocListDictionay[refNum] = docList.elements('name')[i].valueOf(); 	
				dicDocListDictionay[className] = docList.elements('ref')[i].valueOf(); 	
			}
		}
		
		private function funGetObjCounters_Response(receivedData:XML):void {
			//trace("GetObjCounters response received");
			//set init completed
			if( XDS_APICallController.get().get(XDS_APICallController.STATUS_MACHINE_INITIALIZED) == false )
				XDS_APICallController.get().set(XDS_APICallController.STATUS_MACHINE_INITIALIZED, true);
		}
		
		private function funGetCRUHFSIInfo_Response(receivedData:XML):void {
			//trace("GetObjCounters response received");
			
			var xmlData:XMLListCollection = new XMLListCollection(receivedData.XUIResponse.child("return").data.CRUHFSIInfo.item); // convert the received data to XML
			
			//Update XDS_Data
			var tmpCRUList:Array = new Array;
			for(var i:int = 0; i < (xmlData.length); i++)
			{
				var cruObject:Object = new Object();
				if( xmlData.elements('type')[i].valueOf() == "cru" )
				{
					cruObject.name = xmlData.elements('name')[i].valueOf().toString();
					cruObject.percentRemaining = xmlData.elements('percentRemaining')[i].valueOf().toString();
					//trace("CRU name: " + cruObject.name);
					//trace("CRU percentage: " + cruObject.percentRemaining);
					//trace("");
					tmpCRUList.push(cruObject);
				}
			}
			
			xdsData.CRUHFSIInfo = tmpCRUList;
			
		}
		
		private function funGetXBrowserData_Response(receivedData:XML):void {
			//trace("GetXBrowserData response received");
			var xmlData:XML = XML(receivedData.XUIResponse.child("return").data); // convert the received data to XML
			var outcome:String = checkDADFRaised(xmlData);
			//trace("DADF outcome: " + checkDADFRaised(xmlData));
			//set sync completed
			if( XDS_APICallController.get().get(XDS_APICallController.STATUS_MACHINE_SYNC_COMPLETED) == false )
				XDS_APICallController.get().set(XDS_APICallController.STATUS_MACHINE_SYNC_COMPLETED, true);
		}
		
		private function funGetMachineConfig_Response(receivedData:XML):void {
			//trace("GetMachineConfig response received");
			var tmpFinisherInfo:Object = new Object();
			
			tmpFinisherInfo.finisherType = receivedData.XUIResponse.child("return").data.MachineConfig.finisherGraphic.valueOf();
			tmpFinisherInfo.stapler = receivedData.XUIResponse.child("return").data.MachineConfig.destinations.capabilities.stapling.valueOf();
			tmpFinisherInfo.folding = receivedData.XUIResponse.child("return").data.MachineConfig.destinations.capabilities.folding.valueOf();
			tmpFinisherInfo.bookletMaker = receivedData.XUIResponse.child("return").data.MachineConfig.destinations.capabilities.bookletMaker.valueOf();
			tmpFinisherInfo.punchHoles = receivedData.XUIResponse.child("return").data.MachineConfig.destinations.capabilities.punchHoles.valueOf();
			if( receivedData.XUIResponse.child("return").data.MachineConfig.destinations.capabilities.creasing.length() == 0 )
				tmpFinisherInfo.creasing = "none";
			else
				tmpFinisherInfo.creasing = receivedData.XUIResponse.child("return").data.MachineConfig.destinations.capabilities.creasing.valueOf();
			
			xdsData.finisherInfo = tmpFinisherInfo;
			
			//trace("Finisher data: " );
			//trace("finisherType: " + xdsData.finisherInfo.finisherType);
			//trace("stapler: " + xdsData.finisherInfo.stapler);
			//trace("folding: " + xdsData.finisherInfo.folding);
			//trace("bookletMaker: " + xdsData.finisherInfo.bookletMaker);
			//trace("punch: " + xdsData.finisherInfo.punchHoles);
			//trace("creasing: " + xdsData.finisherInfo.creasing);
			//trace("");
		}
		
		private function funGetPaperTrayAttributes_Response(receivedData:XML):void {
			// show the paper trays in the UI
			//trace("GetPaperTrays response received");
			
			// for convenience, create a temporary variable to hold the paper tray information received from the device
			var temp:XMLListCollection = new XMLListCollection(XDS_UIMappingXML.xmlPaperTrayNames.PaperTrayNames.trayNumber);
			
			// Get the list of paper trays configured on the device.
			var installedPaperTrays:XMLListCollection = new XMLListCollection(receivedData.XUIResponse.child("return").data.PaperTrayAttributes.trayAttributes);
			
			// Remove any trays that aren't configured on the device.
			// may want to put this in a function - compare 2 xml structures and remove non-matching items from 1 of them
			var i:int;
			if(temp.length >= 1) // check there is at least 1 item in array
			{
				for (i = (temp.length-1); i >= 0; i--) // iterate backwards because index shifts when an item is deleted
				{
					// is the display tray's number found in the installed trays?
					if(findValue(installedPaperTrays, "trayNumber", temp[i]) == -1) {
						temp.removeItemAt(i); // if the machine doesn't support this tray, remove it
					}
				}
				xfdPaperTrays = temp;
				
				//Update XDS_Data
				var tmpPaperTray:Array = new Array;
				for(var i:int = 0; i < (installedPaperTrays.length); i++)
				{
					var trayObject:Object = new Object();
					trayObject.trayNumber = installedPaperTrays.elements('trayNumber')[i].valueOf();
					trayObject.paperSize = installedPaperTrays.elements('paper')[i].size.setting.valueOf();
					trayObject.paperColor = installedPaperTrays.elements('paper')[i].color.valueOf();
					trayObject.paperType = installedPaperTrays.elements('paper')[i].type.valueOf();;
					trayObject.orientation = installedPaperTrays.elements('paper')[i].orientation.valueOf();;
					
					//trace("Paper Tray no: " + trayObject.trayNumber);
				//	trace("Setting: " + trayObject.paperSize);
					//trace("Color: " + trayObject.paperColor);
					//trace("Type: " + trayObject.paperType);
					//trace("Orientation: " + trayObject.orientation);
					//trace("");
					
					tmpPaperTray[i] = trayObject;
				}
				
				xdsData.paperTrayInfo = tmpPaperTray;
				
				// show the Color Output options
				var tempList:XMLList = new XMLList(XDS_UIMappingXML.xmlUIColorOutput.colorOutput.mode.@displayName); // seem to need to convert the xml to xmlList first - and must drill down below the root node
				xfdColorOutput = new XMLListCollection(tempList); // and then to xmlListCollection
				setUIState('ReadyToCopy');
			}
		}
		
		private function funGetCopyJobDefault_Response(receivedData:XML):void {
			//trace("GetCopyJobDefault response received");
			//delete XDS_DeviceXML.xmlCopyJob.XUIRequest.ReplaceChild.child("data")[0]; // clear out the 'dummy' node "data"
			//XDS_DeviceXML.xmlCopyJob.XUIRequest.ReplaceChild.appendChild(receivedData.XUIResponse.child("return").child("data")); // put in the "data" node sent by the machine
			
			if(receivedData.XUIResponse.child("return").result != "failure")
			{
				var xmlData:XML = new XML(receivedData.XUIResponse.child("return").data.CopyJob.submit); 
				
				//set copy default settings in XDS
				xdsData.selectedPaperTrayNum = xmlData.settings.document.traySelection.@default;
				xdsData.copyQuantitiy = xmlData.settings.job.copyCount.@default;
				xdsData.copySides = xmlData.settings.document.plex.mode.@default;
				xdsData.copyColor = xmlData.settings.document.colorOutput.mode.@default;
			}
		}

		private function funGetCopyJobInstance_Response(receivedData:XML):void {
			//trace("GetCopyJobInstance response received");
			delete XDS_DeviceXML.xmlCopyJob.XUIRequest.ReplaceChild.child("data")[0]; // clear out the 'dummy' node "data"
			XDS_DeviceXML.xmlCopyJob.XUIRequest.ReplaceChild.appendChild(receivedData.XUIResponse.child("return").child("data")); // put in the "data" node sent by the machine
			var xmlData:XML = new XML(XDS_DeviceXML.xmlCopyJob.XUIRequest.ReplaceChild.data.CopyJob.submit); 
			//trace("############################################\n" + XDS_DeviceXML.xmlCopyJob);
		}
		
		private function funGetCopyServiceInfo_Response(receivedData:XML):void {
			//setDADFStatus(receivedData.XUIResponse.child("return").child("data").CopyServiceInfo.dadfRaised[0]);
			//setDocOnHandlerStatus(receivedData.XUIResponse.child("return").child("data").CopyServiceInfo.docOnHandler[0]);
		}
		
		private function funGetScanToFileJobInstance_Response(receivedData:XML):void {
			//trace("GetScanToFile Response received");
			delete XDS_DeviceXML.xmlScanToFileJob.XUIRequest.ReplaceChild.child("data")[0]; // clear out the 'dummy' node "data"
			XDS_DeviceXML.xmlScanToFileJob.XUIRequest.ReplaceChild.appendChild(receivedData.XUIResponse.child("return").child("data")); // put in the "data" node sent by the machine
			//trace("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" + XDS_DeviceXML.xmlScanToFileJob);
		}
		
		public function requestConnection():void {
			if( !XDS_APICallController.get().get(XDS_APICallController.STATUS_MACHINE_CONNECTED) )
 			{
				var machineIP:String = ApplicationSettings.get().get(ApplicationSettings.MACHINE_IP);
				conn.connect(machineIP,numPort);
				timerConnectionTimeout.start(); // start the preview Timeout counting
				timerConnectionTimeout.addEventListener(TimerEvent.TIMER_COMPLETE, machineConnectingTimeoutHandler); // listen for the timer to complete
			}
		}

		private function machineConnectingTimeoutHandler(evt:Event):void 
		{
			timerPreviewTimer.stop(); // stop the timeout
			timerPreviewTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, machineConnectingTimeoutHandler);
		}
		
		public function syncButtonGoOffline():void
		{
			FlexGlobals.topLevelApplication.currentState = "panelOutput";
		}
		
		public function closeConnection():void {
			if( XDS_APICallController.get().get(XDS_APICallController.STATUS_MACHINE_CONNECTED) )
			{
				//trace(conn);
				conn.closeConnection();
			}
		}
		
		private function XRX_DataEventHandler(evt:XRX_DataEvent):void {
			//trace('Data received in Main.');
			var xmlReceivedData:XML = XML(evt.data); // convert the received data to XML
			
			if(xmlReceivedData.@sequence.length() != 0) { // if received XML has a 'sequence' attribute
				// convert the XML sequence value to a number so it can be used as dictionary key
				var sequence:Number = Number(xmlReceivedData.@sequence);
				//trace("Data has sequence: " + sequence);
				
				if(dicSequenceResponses[sequence] != null) {
					//trace("Sequence response was expected.");
					// if that sequence appears in the list of sequence messages requiring a response
					// call the desired handler function, sending the data as a parameter
					dicSequenceResponses[sequence](xmlReceivedData);
					// and remove the item from the list
					delete dicSequenceResponses[sequence];
				}
				else {
					//trace("Sequence response was NOT expected.");
				}
			}
			else {
					//trace("Data does not have \'sequence\'.");
					// these trace every non-sequence doc received. Currently disabled just to save space in debug text.
					//	writeDebugText("Non-sequence data received \n");
					//	writeDebugText("Name of first child node: " + xmlReceivedData.*.name() + "\n\n");
					//trace("XDS DATA received that isn't sequenced.");
					if( xmlReceivedData.XUIEvent.DocumentChangedEvent.length() != 0 )
					{
						var refNum:int = xmlReceivedData.XUIEvent.DocumentChangedEvent.ref.valueOf();
						var className:String = dicDocListDictionay[refNum];
						var xmlData:XML = XML(xmlReceivedData.XUIEvent.DocumentChangedEvent.data); // convert the received data to XML
						//trace( "DICDOC: " + className );
						switch( className )
						{
							case "JobMonitor":
								var previewMonitorResult:Boolean = checkPreviewStatus(xmlData);
								//trace("Job Monitor outcome: "+checkPreviewStatus(xmlData));
								break;
							case "XBrowserData":
								var result:String = checkDADFRaised(xmlData);
//								trace("DADF outcome: " + checkDADFRaised(xmlData));
								break;
						}
					}
			}
			
			//trace("Data: " + evt.data.toString());
		}
		
		private function checkPreviewStatus(xmlData:XML):Boolean {
			// examines incoming XML data to see if the preview job has completed
			//trace("\n\nCHECK PREVIEW STATUS: " + xmlData.JobMonitor.jobType + "\n" + xmlData + "\n\n");
			trace("CHECK PREVIEW STATUS: " + xmlData.JobMonitor.jobType + "\n\t" + xmlData.JobMonitor.mode + "\n\t" + xmlData.JobMonitor.jobId.jobIndex + "\n\t" + xmlData.JobMonitor.active.status.mode);
			if(boolWaitingForJobFinish )
			{
				//trace("*** Job Monitor Update ***");
				//trace("Job Type: " + xmlData.JobMonitor.jobType);
				//trace("Job ID: " + xmlData.JobMonitor.jobID.jobIndex);
				//trace("Job status: " + xmlData.JobMonitor.active.status.mode);
				//writeDebugText("Job Monitor Received \n");
				//writeDebugText("Job ID: " + xmlData.JobMonitor.jobId.jobIndex + "\n");
				//writeDebugText("Job status: " + xmlData.JobMonitor.active.status.mode + "\n\n");
				
				/*
				 * For some unknown reason the machine will occasionally return a message
				 * containing jobType unknown and status transferring where it should 
				 * be returning a complete message. Or at least this seems to be the case.
				 * This is a hack to treat this scenario as a 'complete' message.
				 */
				/*if(xmlData.JobMonitor.jobType == "unknown")
				{
					//trace(xmlData);
					var status:String = xmlData.JobMonitor.active.status.mode[0].text();
					cancelPreview();
					dispatchPrescanProgressEvent(PRESCAN_COMPLETED);
				}*/
				if(xmlData.JobMonitor.jobType == "scanToFile" ||
					xmlData.JobMonitor.jobType == "copy" ) 
				{ // if it's a scan job
					var jobStatus:String = xmlData.JobMonitor.active.status.mode[0].text();
					
					if(xmlData.JobMonitor.jobType == "copy") //Should really check the jobStatus before setting
						_isCopying = true; 
					
					//trace("A:" + jobStatus + " " + xmlData.JobMonitor.jobId.jobIndex + ", " + previewJobNumber);
					if( ((jobStatus == "scanning") || (jobStatus == "scheduledToScan"))) { // if no preview is currently being generated
						// and a new job has started scanning, assume it's the requested preview
						// note that the job status 'scheduledToScan' doesn't always happen so can't be reliably used as an indicator
						previewJobNumber = xmlData.JobMonitor.jobId.jobIndex; // note the job number so its progress can be tracked
						dispatchPrescanProgressEvent(PRESCAN_SCANNING_EVENT);
						setUIState('Scan2FileJobScanning'); // display the job status
					}
					else if( (previewJobNumber == xmlData.JobMonitor.jobId.jobIndex)) {
						// if a preview is being generated and this Job Monitor update matches the job number
						switch (jobStatus) {
							case "formatting":
								setUIState('Scan2FileJobFormatting'); // display the job status
								dispatchPrescanProgressEvent(PRESCAN_FORMATTING_EVENT);
								break;
							case "waitingToTransfer":
								dispatchPrescanProgressEvent(PRESCAN_TRANSFERRING_EVENT);
								break;
							case "completed":
								cancelPreview();
								setUIState('Scan2FileJobCompleted'); // display the job status
								if(xmlData.JobMonitor.jobType == "scanToFile")
									dispatchPrescanProgressEvent(PRESCAN_COMPLETED);
								else 
									isCopying = false;
								break;
							case "completedWithErrors":
								cancelPreview();
								setUIState('Scan2FileJobCompletedWithErrors'); // display the job status
								if(xmlData.JobMonitor.jobType == "scanToFile")
									dispatchPrescanProgressEvent(PRESCAN_COMPLETED);
								else 
									isCopying = false;
								break;
							case "completedTerminated":
								trace("COMPLETED TERMINATED MESSAGE RECEIVED");
								if(xmlData.JobMonitor.active.status.completedTerminated.text() != "repositoryLoginError")
								{
									cancelPreview();
									setUIState('Scan2FileJobDeleted'); // display the job status
									if(xmlData.JobMonitor.jobType == "scanToFile")
										dispatchPrescanProgressEvent(PRESCAN_FAILED);
									else 
										isCopying = false;
								}
								break;
							case "deleted":
								cancelPreview();
								if(xmlData.JobMonitor.jobType == "scanToFile")
									dispatchPrescanProgressEvent(PRESCAN_FAILED);
								else 
									isCopying = false;
								break;
						}//switch end
					}//if end
				}//if end 
				//Corner case: the first prescan out after the machine wakes up 
				//from energy saver mode will cause this an inactive message of unknown
				//job type, and with a much higher job id than it should have, seems to be returned
				//instead of a completed message. Look into the actual cause of this.
				//THIS ISN'T WORKING
				else if(xmlData.JobMonitor.jobType == "unknown" &&
						xmlData.JobMonitor.mode == "inactive" &&
						xmlData.JobMonitor.jobId.jobIndex != previewJobNumber)
				{
					trace( "Unknown job encountered: " + (new Date().toString()) );
					cancelPreview();
					setUIState('Scan2FileJobCompleted'); // display the job status
					if(xmlData.JobMonitor.jobType == "scanToFile")
						dispatchPrescanProgressEvent(PRESCAN_COMPLETED);
					else 
						isCopying = false;
				}
			}//if end
			return false;
		}
		
		private function dispatchPrescanProgressEvent(stage:String):void
		{
			var obj:Object = new Object();
				obj.status = stage;
			var evt:XRX_DataEvent = new XRX_DataEvent(PRESCAN_PROGRESS_EVENT, obj);
			this.dispatchEvent(evt);
		}
		
		// DADF Status Checking
		private function setDADFStatus(dadfStatus:String):void {
			// set the DADF (document handler) status - raised or lowered?
			//trace("dadf status var: " + DADFRaised.toString());
			//trace("dadf status XML: " + dadfStatus.toString());
			//trace("SETTING DADF STATUS: " + dadfStatus);
			if(dadfStatus == "false") {
				if( DADFRaised ) // a scan2file job is required when the dadf lowered.
				{
					//FlexGlobals.topLevelApplication.currentState = "panelOutput";
					//Perform_ScanToFileJob();
				}
				
				DADFRaised = false;
			}
			else {
				if( !DADFRaised ) // a scan2file job is required when the dadf lowered.
				{
					//FlexGlobals.topLevelApplication.currentState = "LoadGlass";
				}
				DADFRaised = true;
			}
			// notify the UI that a status update has been received
			setUIState('DADFStatus');
		}
		
		private function setDocOnHandlerStatus(docStatus:String):void {
			//trace("SETTING DOC ON HANDLER: " + docStatus);
			// set the DADF (doc handler) status - doc on handler or not?
			if(docStatus == "false") {
				DocOnHandler = false;
			}
			else {
				DocOnHandler = true;
			}
			// notify the UI that a status update has been received
			setUIState('DocOnHandler');
		}
		
		private function checkDADFRaised(xmlData:XML):String {
			// examines incoming XML data to see if the DADF has been raised or lowered
			// returns true if it is raised
			// update the document handler status
			if(xmlData.XBrowserData.dadfRaised[0].toString() != DADFRaised.toString()) {
				// if raised / lowered status has changed
				setDADFStatus(xmlData.XBrowserData.dadfRaised[0]);
				dispatchDocumentHandlerEvent((xmlData.XBrowserData.dadfRaised[0] == "true") ? true : false, false);
			}
			if(xmlData.XBrowserData.docOnHandler[0].toString() != DocOnHandler.toString()) {
				// if doc on handler status has changed
				setDocOnHandlerStatus(xmlData.XBrowserData.docOnHandler[0]);
				//trace("BLAH BLAH BLAH: " + xmlData.XBrowserData.docOnHandler[0]);
				dispatchDocumentHandlerEvent(false, (xmlData.XBrowserData.docOnHandler[0] == "true") ? true : false);
			}
			
			return "Dadf Status Received";
		}
		
		private function dispatchDocumentHandlerEvent(raised:Boolean, docInHandler:Boolean):void
		{
			var evtData:Object = new Object();
			evtData.dadfRaised = raised;
			evtData.docOnHandler = docInHandler;
			this.dispatchEvent(new XRX_DataEvent(DOC_HANDLER_CHANGE_EVENT, evtData));
		}
		
		public function Perform_CopyJob():void {
			// notify the main logic that the user wants to Start the copy job
			UIAction('PerformCopyJob');
		}
		
		/**
		 * It seems that a local (i.e. on-machine) Workflow scanning job
		 * needs to be run before this can be called successfully from a remote
		 * source such as the playbook. This could be to do with the XDS request
		 * not setting/sending a particular parameter.
		 **/
		public function Perform_ScanToFileJob():void {
			// notify the main logic that the user wants to preview the doc on the platen
			UIAction('PerformScanToFileJob');
			xfdImagePreview = imagePreviewUnavailable; // reset the image to the "not available" image
		}
			
		public function setUIState(action:String):void {
			// sets UI component 'state'. 
			// These are not Flex View States. They are locally defined 'sub-states' allowing 
			// components to be enabled and disabled depending on connection status etc.
			// Think of them more like actions for the UI to take when specific events occur, as instructed by the main logic.
			
			switch (action) {
				case "Connected": // socket has just been connected
					XDS_APICallController.get().set(XDS_APICallController.STATUS_MACHINE_CONNECTED, true);	
					break;
				
				case "Disconnected": // socket has just been disconnected
					XDS_APICallController.get().set(XDS_APICallController.STATUS_MACHINE_CONNECTED, false);
					break;
				
				case "Initialised": // debug etc have been initialised
					break;
				
				case "ReadyToCopy": // copy service has been initialised
					// ensure the UI shows the default Copy settings
					// set the default paper tray from main
					if (getDefaultPaperTray() != -1) // if a valid default index has been returned
					{
						//comppanelOutput.dropPaperTray.selectedIndex = getDefaultPaperTray();
					}
					break;
				
				case "DADFStatus": // display DADF status
					break;
				
				case "DocOnHandler": // display whether there is a doc in the handler
					break;
				
				case "Scan2FileJobScheduled": // job monitor says the preview job is scheduled
					xfdStrPreviewStatus  =  "Scheduled...";
					break;
				
				case "Scan2FileJobScanning": // job monitor says the preview job is scanning
					xfdStrPreviewStatus  =  "Scanning...";
					break;
				
				case "Scan2FileJobFormatting": // job monitor says the preview job is formatting
					xfdStrPreviewStatus  = "Processing...";
					break;
				
				case "PreviewOnly": 
					break;
				case "Scan2FileJobCompleted": // job monitor says the preview job is completed
					xfdStrPreviewStatus = "Job completed OK";
					xfdImagePreview = xfdStrPreviewPath; 
					break;
				
				case "Scan2FileJobCompletedWithErrors": // job monitor says the preview job is completed with errors
					xfdStrPreviewStatus = "Job complete with error";
					xfdImagePreview = imagePreviewUnavailable; // reset the image to the "not available" image
					break;
				
				case "Scan2FileJobDeleted": // job monitor says the preview job was deleted, i.e. failed
					xfdStrPreviewStatus = "Job deleted";
					xfdImagePreview = imagePreviewUnavailable; // reset the image to the "not available" image
					break;
				
				case "Scan2FileJobTimeout": // job monitor says the preview job was deleted, i.e. failed
					xfdStrPreviewStatus = "Cancelled by Timeout";
					xfdImagePreview = imagePreviewUnavailable; // reset the image to the "not available" image
					dispatchPrescanProgressEvent(PRESCAN_FAILED);
					break;
			}
		}
		
	}			
}