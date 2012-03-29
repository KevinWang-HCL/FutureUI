// ActionScript file
// XDS_Socket connects to a Flash binary socket, and sends and receives XML in the same form as the DXS_Viewer application
package xerox
{
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.*;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class XDS_Socket extends Sprite
	{
		private var socket:Socket;
		public var xmlData:XML = new XML;
		public var strLastHost:String = new String;
		public var numLastPort:Number = new Number;
		
		// socket may be disconnected and need to reconnect
		// event handlers should not need to be recreated
		private var booNewConnection:Boolean = true;
		private var booConnectAndSend:Boolean = false;
		private var strBufferedData:String = "";
		
		public function XDS_Socket():void {
			socket = new Socket();
			socket.addEventListener(Event.CONNECT, connectHandler);
			
			//  handle asynchronous errors in these handlers
			socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		}
			
		public function connect(host:String, port:int):void {
			try {
				socket.connect (host, port );
				strLastHost = host; // store host name and port in case the connection is lost
				numLastPort = port;
			} catch(ioError:IOError) {
				//  handle synchronous errors here 
				trace("ioError: " + ioError);
			} catch(secError:SecurityError) {
				// and here
				trace("secError: " + secError);
			}
		}
		
		private function connectHandler(e:Event):void {
			if(booNewConnection == true) // this is the first time the socket has been connected
			{
				trace("Socket connected to server.");
				booNewConnection = false;
			}
			else if(booConnectAndSend==true) // have reconnected in order to send data (connection was lost)
			{
				trace("Socket reconnected. Sending buffered data.");
				booConnectAndSend=false;
				send(strBufferedData);
			}
			socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
			socket.addEventListener(Event.CLOSE, closeHandler);
			socket.removeEventListener(Event.CONNECT, connectHandler);
			
			dispatchEvent(new XRX_EventType('SocketAction',false,false,'StateChangeConnected')); // tell Main to tell the UI to update its state
		}
		
		private function closeHandler(e:Event):void {
			trace("Server Socket is Closed");
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
			socket.removeEventListener(Event.CLOSE, closeHandler);
			socket.addEventListener(Event.CONNECT, connectHandler);
			dispatchEvent(new XRX_EventType('SocketAction',false,false,'StateChangeDisconnected')); // tell Main to tell the UI to update its state
		}
		
		private var newMessage:Boolean = true; // 'true' means that there are no partial messages outstanding, this is a new message
		// 'false' means a message length has been received but NOT the full expected data
		private var messageLength:int = new int; // length of expected data as stated by four-byte byteArray
		
		private function dataHandler(e:ProgressEvent):void {
			//trace("Data received from socket.");
			
			// is this a new message? if so, look for message length
			if (newMessage == true)
			{
				// if so, have we got at least 4 bytes?
				if ( e.target.bytesAvailable >= 4)
				{
					// find the length of the expected message
					//trace ("newMessage == true. Bytes available: ");
					//trace( e.target.bytesAvailable );
					var bytes:ByteArray = new ByteArray();
					e.target.readBytes(bytes, 0, 4); // read the 4 bytes which give the length of the incoming data
					
					// the following method turns the four byte byteArray back into an integer
					// from http://snippets.dzone.com/posts/show/93
					messageLength = (bytes[0] << 24)
						+ ((bytes[1] & 0xFF) << 16)
						+ ((bytes[2] & 0xFF) << 8)
						+ (bytes[3] & 0xFF);
					//trace("message length: ");
					//trace(messageLength);
				}
				// if there are not at least four bytes, quit the function - wait for more data to be received				
				else
				{
					trace("New message. Fewer than 4 bytes received.");
					trace("Number of bytes: " + e.target.bytesAvailable);
					return;
				}
			}
			
			// is the complete message available? i.e. are bytesAvailable >= message length?
			if ( e.target.bytesAvailable >= messageLength)
			{
				//trace( "full message available." );
				var data:String = socket.readUTFBytes(messageLength); // now read the data - only take the bytes required for this message
				try {
					// convert the downloaded data into an XML object
					xmlData = XML(data);
					//trace('dispatchEvent(new XRX_DataEvent)');
					dispatchEvent(new XRX_DataEvent(XRX_DataEvent.EVENT_OCCURRED, xmlData));
				} catch (e:TypeError) {
					//Could not convert the data, probably because of a format error
					trace("Could not parse the XML\n\n");
					trace(e.message);
					trace("data: " + data);
				}
				newMessage = true;
				
				// are there still bytes left in the socket, i.e. is there another message sent or partly sent?
				if(e.target.bytesAvailable > 0)
				{
					dataHandler(e);
				}
			}
			else
			{
				newMessage = false;
			}
		}
		
		public function send(data:String):void {
			// sends the data to the socket
			// the data must be preceded by its length
			
			if(socket.connected==false)
			{
				if((strLastHost==null) || (isNaN(numLastPort))) {
					trace("Hostname and port values are not available.");
				}
				else {
					trace("Socket is closed. Attempting to reconnect...");
					strBufferedData = data; // store the data to send it after reconnection
					booConnectAndSend = true; // inform the connectHandler that there is buffered data to be sent
					socket.connect(strLastHost, numLastPort);
				}
			}
			else if(socket.connected==true)
			{
				// step 1: encode the data length in the byteArray 'bytes'
				var bytes:ByteArray = new ByteArray();
				var x:int = new int;
				x = data.length;
	
				bytes[3]=x & (255);                 //use an 8 bit mask (i.e. 11111111) to determine least significant bit
				x=x>>8;                             //right shift 8 bits to determine the next byte.
				bytes[2]=x & (255);
				x=x>>8;
				bytes[1]=x & (255);
				x=x>>8;
				bytes[0]=x & (255);
				
				// step 2: encode the data in the byteArray 'messageBytes'
				var messageBytes:ByteArray = new ByteArray();
				messageBytes.writeUTFBytes(data); // writeUTFBytes doesn't append any extra characters to the start of the data
				
				// step 3: write the length, then the data, to the socket, and send it on
				socket.writeBytes(bytes); // write the byteArray that specifies message length
				socket.writeBytes(messageBytes); // then the message itself
				socket.flush(); // then send it all to the socket
				strBufferedData = ""; // clear out any buffered data, just to save memory
				//trace('Data sent to Socket: \n' + data);
			}
		}
		
		public function closeConnection():void {
			socket.close();
			trace("Socket was closed by the user");
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
			socket.removeEventListener(Event.CLOSE, closeHandler);
			socket.addEventListener(Event.CONNECT, connectHandler);
			dispatchEvent(new XRX_EventType('SocketAction',false,false,'StateChangeDisconnected')); // tell Main to tell the UI to update its state
		}
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			trace("securityErrorHandler: " + event);
		}
			

	}
}