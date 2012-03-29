package integration
{
	

	[Bindable]
	public class SettingsMap
	{
		private var _observers:Vector.<ISettingsObserver>;
		
		private var _settingsMap:Object;
		
		public function SettingsMap()
		{
			_observers = new Vector.<ISettingsObserver>();
			_settingsMap = new Object();
		}
		
		public function initialiseSettings():void
		{
			_settingsMap[JobSettings.INPUT_SIDES] = 1;
			_settingsMap[JobSettings.ORIENTATION] = JobSettings.ORIENTATION_PORTRAIT;
		}
		
		public function registerObserver(observer:ISettingsObserver):void
		{
			_observers.push(observer);	
		}
		
		public function removeObserver(observer:ISettingsObserver):void
		{
			_observers.splice(_observers.indexOf(observer), 1);	
		}
		
		public function set(name:String, value:*):void
		{
			//TODO set setting in the setting map and notify all observers.
			_settingsMap[name] = value;
			//trace("Setting " + name + " has changed to " + value);
			for(var i:int = 0; i < _observers.length; i++)
				_observers[i].notifySettingChanged(name, value);
		}
		
		public function get(name:String):*
		{
			return _settingsMap[name];
		}
		
		protected function get settingsMap():Object
		{
			return _settingsMap;
		}
	}
}