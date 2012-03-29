package xerox
{
	// This class is a pure data enumeration providing XML files that are sent to the device
	public class XDS_DeviceXML
	{
		// xml sent by XDSView on connect
		public static const xmlSetDebugClient:XML = <XUIDoc sequence='0'><XUIRequest><SetDebugClient/></XUIRequest></XUIDoc>;
		public static const xmlXIADebug:XML = <XUIDoc sequence='2'><XUIRequest><Get><class>XIADebug</class></Get></XUIRequest></XUIDoc>;
		public static const xmlClientList:XML = <XUIDoc sequence='3'><XUIRequest><ClientList/></XUIRequest></XUIDoc>;
		public static const xmlClassList:XML = <XUIDoc sequence='4'><XUIRequest><ClassList/></XUIRequest></XUIDoc>;
		public static const xmlDocList:XML = <XUIDoc sequence='5'><XUIRequest><DocList/></XUIRequest></XUIDoc>;
		public static const xmlGetObjCounters:XML = <XUIDoc sequence='6'><XUIRequest><GetObjCounters/></XUIRequest></XUIDoc>;
		
		// XML to initialise jobs - "CopyJob" is a placeholder, replace with "ScanToFileJob" for Workflow Scanning
		public static var xmlGetJobDefaultByRef:XML = <XUIDoc sequence='0'><XUIRequest><Get initialize='true' defaults='true'><ref>162</ref></Get></XUIRequest></XUIDoc>;
		public static var xmlGetJobDefaultByClassName:XML = <XUIDoc sequence='0'><XUIRequest><Get initialize='false' defaults='true'><class>CopyJob</class></Get></XUIRequest></XUIDoc>;
		public static var xmlCopyJob:XML = <XUIDoc><XUIRequest><ReplaceChild><class>CopyJob</class><xpath>/</xpath><data></data></ReplaceChild></XUIRequest></XUIDoc>;
		public static var xmlScanToFileJob:XML = <XUIDoc><XUIRequest><ReplaceChild><class>ScanToFileJob</class><xpath>/</xpath><data></data></ReplaceChild></XUIRequest></XUIDoc>;
		/*public static var xmlScanToFileDestination:XML = <fileDestinations>
			<item>
			  <defaultDestination>true</defaultDestination>
			  <id>0</id>
			  <directory>/</directory>
			  <name>Scan2File</name>
			  <path>/</path>
			  <filingProtocol>ftp</filingProtocol>
			  <server>13.210.140.47:21</server>
			  <serverCredentialsRequired>false</serverCredentialsRequired>
			  <serverLogin>
				<username/>
				<password/>
			  </serverLogin>
			  <type>file</type>
			</item>
		  </fileDestinations>;*/
		public static var xmlScanToFileDestination:XML = <fileDestinations>
					<item>
					  <defaultDestination>true</defaultDestination>
					  <id>0</id>
					  <directory>media</directory>
					  <name>FUIConceptScanToFile</name>
					  <path>\photos\scans</path>
					  <filingProtocol>smb</filingProtocol>
					  <server></server>
					  <serverCredentialsRequired>true</serverCredentialsRequired>
					  <serverLogin>
						<username>playbook</username>
						<password/>
					  </serverLogin>
					  <type>file</type>
					</item>
				  </fileDestinations>;
		//ABCScan2File
		
		// general document request. The value of 'ref' specifies which document is requested.
		public static const xmlGetDocument:XML = <XUIDoc sequence='0'><XUIRequest><Get ignoreAttributes='true'><class></class></Get></XUIRequest></XUIDoc>;
			
		// hard-wired Color Output modes - not currently used, but shows values for reference. See xmlUIColorOutput below.
		// these would be used if you want to separate Color Output mode from Single Color.
		public static const xmlColorOutput:XML = <XUIDoc><colorOutput><mode displayName='Auto'>auto</mode><mode displayName='Color'>color</mode><mode displayName='Black & White'>blackwhite</mode><mode displayName='Single Color'>singleColor</mode></colorOutput></XUIDoc>;
		public static const xmlSingleColor:XML = <XUIDoc><singleColor>red</singleColor><singleColor>green</singleColor><singleColor>blue</singleColor><singleColor>cyan</singleColor><singleColor>magenta</singleColor><singleColor>yellow</singleColor></XUIDoc>;
		
		// hard-wired Color Effects modes
		// on Jupiter, 'Single Color' seems to be presented within the Output Color list. The other options are under Color Presets.
		// it seems that Color Effects should only be available if Output Color is set to 'auto' or 'color'.
		public static const xmlColorEffects:XML = <XUIDoc><colorEffects><mode>off</mode><mode>singleColor</mode><mode>lively</mode><mode>bright</mode><mode>warm</mode><mode>cool</mode><singleColor>red</singleColor><singleColor>green</singleColor><singleColor>blue</singleColor><singleColor>cyan</singleColor><singleColor>magenta</singleColor><singleColor>yellow</singleColor></colorEffects></XUIDoc>;
		
	}	
}