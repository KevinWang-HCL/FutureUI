package integration
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class ApplicationSettings
	{
		{
			private static var filePath:String = "file://" + File.userDirectory.nativePath + "/shared/documents/FUI Concept/fuiConfig.xml";
			private static var fs:FileStream = null;
			
			try
			{
				private static var file:File = new File(filePath);
				fs = new FileStream();
				fs.open(file, FileMode.READ);
				settingsXML = XML(fs.readUTFBytes(fs.bytesAvailable));
				trace("XML Application Settings loaded!\n" + settingsXML);
			}
			catch(err:IOError)
			{
				trace("XML Application file not found!");
			}
			catch(err:Error)
			{
				trace("Unable to compile URL, probably running in local mode");
			}
			finally
			{
				if(fs)
					fs.close();
			}
		}
		
		public static const LOCAL_MODE_ENABLED:String = "LocalMode";
		public static const LOCAL_MODE_ENABLED_DEFAULT:Boolean = true;
		
		/* Use to switch between Desktop and tablet */
		public static const ON_TOUCHSCREEN:String = "TouchScreen";
		public static const ON_TOUCHSCREEN_DEFAULT:Boolean = false;
		
		public static const MACHINE_IP:String = "MachineIP";
		public static const MACHINE_IP_DEFAULT:String = ""; 
		
		/* The IP of the machine running the application (i.e. PC for debugging, or playbook) */
		public static const LOCAL_IP:String = "LocalIP";
		public static const LOCAL_IP_DEFAULT:String = getDeviceIP();
		
		private static function getDeviceIP():String
		{
			var netInterfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			
			for each(var ni:NetworkInterface in netInterfaces)
			{
				if(ni.active)
				{
					var addresses:Vector.<InterfaceAddress> = ni.addresses;
					for each(var addr:InterfaceAddress in addresses)
					{
						if(addr.ipVersion == "IPv4")
							return addr.address;
					}
				}
			}
			
			return "";
		}
		
		public static const PRESCAN_FILE_PATH:String = "PrescanFilePath";
		public static const PRESCAN_FILE_PATH_DEFAULT:String = "file://" + File.userDirectory.nativePath + "/shared/photos/scans/preview.XSM/00000001.jpg"; 
		
		public static const PRESCAN_DPI:String = "PrescanDPI";
		public static const PRESCAN_DPI_DEFAULT:Number = 72;
		
		public static const LOCAL_MIMIC:String = "DefaultMimic";
		public static const LOCAL_MIMIC_DEFAULT:Array = ["assets/images/MimicLandscapeA4.png", "assets/images/MimicPortraitA4.png"];
		
		public static const MIMIC_SOURCE:String = "MimicSource";
		public static const MIMIC_SOURCE_DEFAULT:String = "";
		
		public static const USE_LOCAL_MIMIC:String = "UseLocalMimic";
		public static const USE_LOCAL_MIMIC_DEFAULT:Boolean = false;
		
		public static const MIMIC_DPI:String = "MimicDPI";
		public static const MIMIC_DPI_DEFAULT:Number = 25.4;
		
		private static var settingsXML:XML = null;
		private static var instance:SettingsMap = null;
		
		public static function get():SettingsMap
		{
			if(!instance)
			{
				instance = new SettingsMap();
				if(settingsXML)
				{
					instance.set(LOCAL_MODE_ENABLED, !(settingsXML.ConnectToMachine=="true"));
					instance.set(MACHINE_IP, settingsXML.MachineIP);
					instance.set(LOCAL_IP, LOCAL_IP_DEFAULT);
					instance.set(PRESCAN_FILE_PATH, PRESCAN_FILE_PATH_DEFAULT);
					instance.set(PRESCAN_DPI, settingsXML.PrescanDPI);
					instance.set(LOCAL_MIMIC, LOCAL_MIMIC_DEFAULT);
					instance.set(MIMIC_SOURCE, MIMIC_SOURCE_DEFAULT);
					instance.set(USE_LOCAL_MIMIC, USE_LOCAL_MIMIC_DEFAULT);
					instance.set(MIMIC_DPI, settingsXML.MimicDPI);
					instance.set(ON_TOUCHSCREEN, settingsXML.OnTouchScreen);
				}
				else
				{
					instance = new SettingsMap();
					instance.set(LOCAL_MODE_ENABLED, LOCAL_MODE_ENABLED_DEFAULT);
					instance.set(MACHINE_IP, MACHINE_IP_DEFAULT);
					instance.set(LOCAL_IP, LOCAL_IP_DEFAULT);
					instance.set(PRESCAN_FILE_PATH, PRESCAN_FILE_PATH_DEFAULT);
					instance.set(PRESCAN_DPI, PRESCAN_DPI_DEFAULT);
					instance.set(LOCAL_MIMIC, LOCAL_MIMIC_DEFAULT);
					instance.set(MIMIC_SOURCE, MIMIC_SOURCE_DEFAULT);
					instance.set(USE_LOCAL_MIMIC, USE_LOCAL_MIMIC_DEFAULT);
					instance.set(MIMIC_DPI, MIMIC_DPI_DEFAULT);
					instance.set(ON_TOUCHSCREEN, ON_TOUCHSCREEN_DEFAULT);
				}
			}
			
			return instance;
		}
	}
}