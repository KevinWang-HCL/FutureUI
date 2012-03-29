package widgets
{
	import com.adobe.webapis.flickr.methodgroups.Upload;
	
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	import integration.ApplicationSettings;

	public class FlickrApp extends AppBase
	{
		public function FlickrApp()
		{
			super();
			display = "Flickr";
		}
		
		private var flickrLogin:FlickrConnect = null;
		private var uploader:Upload = null;
		private var file:File;
		private var fileToOpen:File = File.documentsDirectory;
		private var consumerKey:String = null;
		private var consumerSecret:String = null;
		private var authToken:String = null;
		
		[Bindable]
		public var pubImage:Boolean = false;
		
		private var _imageTitle:String = "";
		[Bindable]
		public function get imageTitle():String
		{
			return _imageTitle;
		}
		
		public function set imageTitle(value:String):void
		{
			_imageTitle = value;
		}
		
		private function uploadFile(strFile:String):void
		{
			if (strFile != null && strFile != "" && imageTitle != "")
			{
				trace("upload started " + strFile);
				file = new File(strFile);
				file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteHandler);
				file.addEventListener(ProgressEvent.PROGRESS, onProgress);
				
				uploader.upload(file, imageTitle, "description", "tags", pubImage);
			}
		}
		
		private function onProgress(event:ProgressEvent):void
		{
			
		}
		private function uploadCompleteHandler(event:DataEvent):void
		{
			/* pBar.visible = false; */
			trace("upload done");
			var xData:XML = new XML(event.data);
			trace(xData);
			if(xData[0].attribute("stat") == "ok"){
				trace("Upload Successful");
			}else {
				trace("Upload Failed");
			}
		}
		
		public override function onActivated() : void
		{
			super.onActivated();
			
			if (flickrLogin == null && consumerKey != null &&
				consumerSecret != null && authToken != null)
			{
				flickrLogin = new FlickrConnect(consumerKey, consumerSecret, authToken);
				uploader = new Upload(flickrLogin.flickr);
				
				appReadyToStart = true;
			}
		}
		
		public override function onLoadSetting(xmlData:XML): void
		{
			consumerKey = xmlData.@consumerKey;
			consumerSecret = xmlData.@consumerSecret;
			//authToken = null;
			authToken = xmlData.@authToken;
		}
		
		public override function onStart():void
		{
			//uploadFile("file:///c:/11.png");
			//uploadFile("file://" + File.userDirectory.nativePath + "/shared/photos/scans/preview.XSM/00000001.jpg");
			uploadFile(ApplicationSettings.get().get(ApplicationSettings.PRESCAN_FILE_PATH));
		}
		
		protected function button1_clickHandler(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			if (flickrLogin)
				flickrLogin.onCloseAuthWindow(null);
		}
	}
}