package xerox
{
	// This class is a pure data enumeration providing UI mapping and display names
	public final class XDS_UIMappingXML
	{
		// UI mapping xml for Color Output. This maps the dropdown options to the two XML parameters, Color Output and Single Color.
		// when the Copy job is submitted, the UI value is read and the corresponding Color Output and Single Color xml are sent to the device
		public static const xmlUIColorOutput:XML=<XUIDoc><colorOutput>
			<mode displayName='Auto'>auto</mode>
			<mode displayName='Color'>color</mode>
			<mode displayName='Black & White'>blackwhite</mode>
			<mode displayName='Single Color: Red' singleColor='red' >singleColor</mode>
			<mode displayName='Single Color: Green' singleColor='green' >singleColor</mode>
			<mode displayName='Single Color: Blue' singleColor='blue' >singleColor</mode>
			<mode displayName='Single Color: Cyan' singleColor='cyan' >singleColor</mode>
			<mode displayName='Single Color: Magenta' singleColor='magenta' >singleColor</mode>
			<mode displayName='Single Color: Yellow' singleColor='yellow' >singleColor</mode>
			</colorOutput></XUIDoc>;
		
		// UI mapping for paper tray names.
		public static const xmlPaperTrayNames:XML=<XUIDoc><PaperTrayNames>
			<trayNumber displayName='Tray 1'>1</trayNumber>
			<trayNumber displayName='Tray 2'>2</trayNumber>
			<trayNumber displayName='Tray 3'>3</trayNumber>
			<trayNumber displayName='Tray 4'>4</trayNumber>
			<trayNumber displayName='Tray 5'>5</trayNumber>
			<trayNumber displayName='Tray 6'>6</trayNumber>
			<trayNumber displayName='Auto'>0</trayNumber>
			</PaperTrayNames></XUIDoc>;
	}
}