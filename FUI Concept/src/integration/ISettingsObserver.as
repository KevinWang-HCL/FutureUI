package integration
{
	public interface ISettingsObserver
	{
		function notifySettingChanged(settingName:String, newValue:*):void;
	}
}