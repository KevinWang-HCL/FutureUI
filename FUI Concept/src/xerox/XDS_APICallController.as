package xerox
{
	import integration.SettingsMap;
	
	public class XDS_APICallController
	{
		public static const STATUS_MACHINE_CONNECTED:String= "Status_MachineConnected";
		public static const STATUS_MACHINE_CONNECTED_DEFAULT:Boolean = false;
		
		public static const STATUS_MACHINE_INITIALIZED:String= "Status_MachineInitialized";
		public static const STATUS_MACHINE_INITIALIZED_DEFAULT:Boolean = false;
		
		public static const NUM_MACHINE_INIT_CALLS:String = "NUM_MachineInitCalls";
		public static const NUM_MACHINE_INIT_CALLS_DEFAULT:int = 0;
		
		public static const NUM_MACHINE_GETCONFIG_CALLS:String = "NUM_MachineGetConfigCalls";
		public static const NUM_MACHINE_GETCONFIG_CALLS_DEFAULT:int = 0;
		
		public static const STATUS_CONFIGFILE_LOADED:String= "Status_ConfigFileLoaded";
		public static const STATUS_CONFIGFILE_LOADED_DEFAULT:Boolean = false;

		public static const STATUS_MACHINE_SYNC_COMPLETED:String= "Status_MachineSyncCompleted";
		public static const STATUS_MACHINE_SYNC_COMPLETED_DEFAULT:Boolean = false;
		
		public static const STATUS_DADH_RAISED:String= "Status_DadhRaised";
		public static const STATUS_DADH_RAISED_DEFAULT:Boolean = false;
		
		public static const STATUS_DADH_WITHDOC:String= "Status_DadhWithDoc";
		public static const STATUS_DADH_WITHDOC_DEFAULT:Boolean = false;
		
		private static var instance:SettingsMap = null;
		
		public static function get():SettingsMap
		{
			if(!instance)
			{
				instance = new SettingsMap();
				instance.set(STATUS_MACHINE_CONNECTED, STATUS_MACHINE_CONNECTED_DEFAULT);
				instance.set(STATUS_MACHINE_INITIALIZED, STATUS_MACHINE_INITIALIZED_DEFAULT);
				instance.set(NUM_MACHINE_INIT_CALLS, NUM_MACHINE_INIT_CALLS_DEFAULT);
				instance.set(NUM_MACHINE_GETCONFIG_CALLS, NUM_MACHINE_GETCONFIG_CALLS_DEFAULT);
				instance.set(STATUS_CONFIGFILE_LOADED, STATUS_CONFIGFILE_LOADED_DEFAULT);
				instance.set(STATUS_MACHINE_SYNC_COMPLETED, STATUS_MACHINE_SYNC_COMPLETED_DEFAULT);
				instance.set(STATUS_DADH_RAISED, STATUS_DADH_RAISED_DEFAULT);
				instance.set(STATUS_DADH_WITHDOC, STATUS_DADH_WITHDOC_DEFAULT);
			}
			
			return instance;
		}
		
	}
}