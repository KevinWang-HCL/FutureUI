package xerox
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.filesystem.*;
	import flash.filesystem.FileStream;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.utils.*;
	
	public class XDS_ServerSocket extends Sprite
	{
		private var serverSocket:ServerSocket = new ServerSocket();
		private var clientSocket:Socket;
		public var strHost:String = new String;
		public var numPort:Number = new Number;
		public var xmlData:XML = new XML;

		public static const DATATYPE_XML:int = 0x01;
		public static const DATATYPE_PHOTO:int = 0x02;
		
		public function XDS_ServerSocket()
		{
		}
		
		private function onConnect( event:ServerSocketConnectEvent ):void
		{
			clientSocket = event.socket;
			
			clientSocket.addEventListener( ProgressEvent.SOCKET_DATA, onClientSocketData );

			dispatchEvent(new XRX_EventType('SerSocketAction',false,false,'StateChangeConnected', clientSocket.remoteAddress));
			
			trace("Connection from: " + clientSocket.remoteAddress + ":" + clientSocket.remotePort );
			
		}
		
		private function processServerDataPackage( buffer:ByteArray ):void
		{
			// convert the downloaded data into an XML object
			buffer.position = 0;
			var dataType:uint = buffer.readUnsignedByte();

			//-----------------------------------------------------------------------------
			// Package Area
			//-----------------------------------------------------------------------------
			//| LEN_PKG_LENGTH(4) | DATA AREA                                     |     
			//-----------------------------------------------------------------------------
			// Data Area
			//-----------------------------------------------------------------------------
			//| LEN_DATA_TYPE(1) = 0x01 (XML)  | XML doc                                  |      
			//-------------------------------------------------------------------------------------	
			//| LEN_DATA_TYPE(1) = 0x02 (Photo)| LEN_PHOTO_NAME(2) | PHOTO NAME AREA | PHOTO DATA |      
			//-------------------------------------------------------------------------------------
			
			if(dataType==DATATYPE_XML){
				
				var xmlBuffer:ByteArray = new ByteArray();
				buffer.readBytes(xmlBuffer, 0, buffer.length-1);
				xmlData = XML(xmlBuffer.toString());
				trace('dispatchEvent(new XRX_DataEvent)');
				dispatchEvent(new XRX_DataEvent(XRX_DataEvent.SERVER_EVENT_OCCURRED, xmlData));
				
			}else if(dataType==DATATYPE_PHOTO){
				//read name len
				var imageNameLen:ByteArray = new ByteArray();
				buffer.readBytes(imageNameLen, 0, 2);
				var nameLen:int = 0;
				nameLen = ((imageNameLen[0] & 0xFF00) << 8)
					+ (imageNameLen[1] & 0xFF);
				
				//read name
				var imageNameBuffer:ByteArray = new ByteArray();
				buffer.readBytes(imageNameBuffer, 0, nameLen);
				var imageName:String = imageNameBuffer.toString();
				trace( imageName );

				//read data
				var imageDataBuffer:ByteArray = new ByteArray();
				buffer.readBytes(imageDataBuffer, 0, buffer.length-2-nameLen-1);
				
				var stream:FileStream = new FileStream;
				var prefsFile:File = File.applicationStorageDirectory;
				prefsFile = prefsFile.resolvePath(imageName+".jpg");
				stream.openAsync(prefsFile, FileMode.WRITE);
				stream.writeBytes( imageDataBuffer, 0, imageDataBuffer.length);
				stream.close();
			}
			
		}
		
		
		private var newMessage:Boolean = true; // 'true' means that there are no partial messages outstanding, this is a new message
		// 'false' means a message length has been received but NOT the full expected data
		private var messageLength:int = new int; // length of expected data as stated by four-byte byteArray
		
		private function onClientSocketData(e:ProgressEvent):void {
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
				var dataBuffer:ByteArray = new ByteArray();
				e.target.readBytes(dataBuffer, 0, messageLength);
				processServerDataPackage( dataBuffer );
				
				newMessage = true;
				
				// are there still bytes left in the socket, i.e. is there another message sent or partly sent?
				if(e.target.bytesAvailable > 0)
				{
					onClientSocketData(e);
				}
			}
			else
			{
				newMessage = false;
			}
		}
		
		public function bind( host:String, port:int ):void
		{
			strHost = host;
			numPort = port
			if( serverSocket.bound ) 
			{
				serverSocket.close();
				serverSocket = new ServerSocket();
				
			}
			serverSocket.bind( port, host );
			serverSocket.addEventListener( ServerSocketConnectEvent.CONNECT, onConnect );
			serverSocket.listen();
			trace( "Bound to: " + serverSocket.localAddress + ":" + serverSocket.localPort );
		}
		
		public function send( event:Event ):void
		{
			try
			{
				if( clientSocket != null && clientSocket.connected )
				{
					clientSocket.writeUTFBytes( "aaa" );
					clientSocket.flush(); 
					trace( "Sent message to " + clientSocket.remoteAddress + ":" + clientSocket.remotePort );
				}
				else trace("No socket connection.");
			}
			catch ( error:Error )
			{
				trace( error.message );
			}
		}
	}	
}