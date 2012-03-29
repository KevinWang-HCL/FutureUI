package widgets
{
	import com.swfjunkie.tweetr.Tweetr;
	import com.swfjunkie.tweetr.events.TweetEvent;
	import com.swfjunkie.tweetr.oauth.OAuth;
	
	import flash.events.DataEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import integration.ApplicationSettings;
	
	public class TwitterApp extends AppBase
	{
		public function TwitterApp()
		{
			super();
			display = "Twitter";
		}
		private var twitterUserName:String = null;
		private var twitterPassword:String = null;
		
		public var twitterMessage:String = "";
		
		/*
		private var twitterObj:Tweetr = null;
		private var twitterOauth:OAuth = new OAuth();  
		
		private var file:File;
		private var fileToOpen:File = File.documentsDirectory;
		
		protected function onTwitterComplete(event : TweetEvent) : void
		{
		trace("onTwitterComplete");
		}
		
		protected function onTwitterFailed(event : TweetEvent) : void
		{
		trace("onTwitterFailed " + event.info);
		appReadyToStart = false;
		}
		
		public override function onActivated() : void
		{
		super.onActivated();
		if (twitterObj == null)
		{
		twitterObj = new Tweetr;
		
		twitterObj.addEventListener(TweetEvent.COMPLETE, onTwitterComplete);
		twitterObj.addEventListener(TweetEvent.FAILED, onTwitterFailed);
		
		twitterObj.oAuth = twitterOauth;
		appReadyToStart = true;
		}
		}
		
		public override function onLoadSetting(xmlData:XML): void
		{
		twitterOauth.consumerKey = xmlData.@consumerKey;
		twitterOauth.consumerSecret = xmlData.@consumerSecret;
		twitterOauth.oauthToken = xmlData.@oauthToken;
		twitterOauth.oauthTokenSecret = xmlData.@oauthTokenSecret;
		}
		
		private function onProgress(event:ProgressEvent):void
		{	
		trace("upload onProgress");
		}
		private function uploadCompleteHandler(event:DataEvent):void
		{
		trace("upload done");
		}
		
		private function fileSelected(event:Event):void 
		{
		file = new File(fileToOpen.url);
		file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteHandler);
		file.addEventListener(ProgressEvent.PROGRESS, onProgress);
		twitterObj.updateProfileImage(file);
		}
		
		public override function onStart():void
		{
		if (twitterObj && twitterMessage.text != null && twitterMessage.text != "")
		{
		var imgFilter:FileFilter = new FileFilter("Images", "*.jpg;*.gif;*.png");
		fileToOpen.browseForOpen("Open", [imgFilter]);
		fileToOpen.addEventListener(Event.SELECT, fileSelected);
		
		//twitterObj.updateStatus(twitterMessage.text);
		//twitterObj.uploadImage(twitterMessage.text, "file:///c:/11.png");
		//twitterObj.updateProfileImage(fileRef);
		}
		}
		*/			
		
		public override function onActivated() : void
		{
			super.onActivated();
			appReadyToStart = true;
		}
		public override function onLoadSetting(xmlData:XML): void
		{
			twitterUserName = xmlData.@twitterUserName;
			twitterPassword = xmlData.@twitterPassword;
		}
		
		private function fileIoErrorHandler(event:IOErrorEvent):void 
		{			
			trace("Error");			
		}						
		
		private function fileHttpResponseStatusHandler(event:HTTPStatusEvent):void 
		{			
			trace("http response status : ", event.status);			
		}						
		
		private function fileProgressHandler(event:ProgressEvent):void 
		{			
			var p:Number = Math.floor((event.bytesLoaded / event.bytesTotal) * 100);				
			trace(p.toString() + " % uploaded...");			
		}
		
		private function fileUploadCompleteDataHandler(event:DataEvent = null):void 
		{			
			var rsp:XML = new XML(event.data);				
			if(rsp.@stat == "ok" || rsp.@status == "ok" ) 
			{				
				trace("upload to twitter done.");
			} 
			else if(rsp.@status == "fail") 
			{				
				trace("upload failed");				
			}			
		}						
		
		public override function onStart():void
		{
			if (twitterUserName != null && twitterPassword != null)
			{
				var _file:File;			
				//_file = File.applicationDirectory.resolvePath("c:\\11.png");	
				_file = new File(ApplicationSettings.get().get(ApplicationSettings.PRESCAN_FILE_PATH));
				if(_file.exists) 
				{
					_file.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, fileHttpResponseStatusHandler);		
					
					_file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, fileUploadCompleteDataHandler);	
					_file.addEventListener(ProgressEvent.PROGRESS, fileProgressHandler);					
					_file.addEventListener(IOErrorEvent.IO_ERROR,  fileIoErrorHandler);					
					if(_file.size >= 4194304) 
					{			
						trace("Sorry, the file is too big.");
						return;
					} 
					else 
					{
						var u:String = (twitterMessage.length > 1) ? "http://twitpic.com/api/uploadAndPost" : "http://twitpic.com/api/upload";
						var r:URLRequest = new URLRequest(u);
						r.contentType = "multipart/form-data";
						r.method = URLRequestMethod.POST;
						var v:URLVariables = new URLVariables();
						v.username = twitterUserName;
						v.password = twitterPassword;
						if(twitterMessage.length > 1)
							v.message = twitterMessage;
						r.data = v;
						_file.upload(r, "media"); 					
					}				
				}
			}
		}
	}
}