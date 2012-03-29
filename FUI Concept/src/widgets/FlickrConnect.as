package widgets
{
	import com.adobe.webapis.flickr.*;
	import com.adobe.webapis.flickr.events.*;
	import com.adobe.webapis.flickr.methodgroups.*;
	
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.events.CloseEvent;
	
	public class FlickrConnect
	{
		public var flickr:FlickrService;
		private var frob:String;
		
		public function FlickrConnect(key:String, secret:String, auth_token:String = null)
		{
			flickr = new FlickrService(key);//enter Flickr API key
			flickr.secret = secret;
			
			if(auth_token != null)
			{
				flickr.token = auth_token;
			}
			else
			{
				flickr.addEventListener(FlickrResultEvent.AUTH_GET_FROB, getFrobResponse);
				flickr.auth.getFrob();
			}
		}
		private function getFrobResponse(event:FlickrResultEvent):void
		{
			if(event.success)
			{
				frob = String(event.data.frob);
				var auth_url:String = flickr.getLoginURL(frob, AuthPerm.DELETE);//generates a login URL
				navigateToURL(new URLRequest(auth_url), "_blank"); //opens the browser and asks for your verification
			}
		}
		public function onCloseAuthWindow(event:CloseEvent):void

		{
			trace("onCloseAuthWindow");
			flickr.addEventListener(FlickrResultEvent.AUTH_GET_TOKEN, getTokenResponse);

			flickr.auth.getToken(frob);

		}
		private function getTokenResponse(event:FlickrResultEvent):void
		{
			trace("getTokenResponse");
			if(event.success)
			{
				var authResult:AuthResult = AuthResult(event.data.auth);
				flickr.token = authResult.token;
				trace(flickr.token);
			}
		}
	}
}