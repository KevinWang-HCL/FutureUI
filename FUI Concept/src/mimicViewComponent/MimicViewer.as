package mimicViewComponent
{
	import assets.embedded.Finishing_Images;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.events.Event;
	import flash.events.ShaderEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	
	import integration.ApplicationSettings;
	import integration.CopySettings;
	import integration.ISettingsObserver;
	
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.ResizeEvent;
	import mx.events.StateChangeEvent;
	import mx.states.State;
	import mx.utils.ObjectProxy;
	
	import spark.components.BusyIndicator;
	import spark.components.SkinnableContainer;
	import spark.layouts.BasicLayout;
	
	[Event(name="mimicGenerationStartEvent", type="flash.events.Event")]
	[Event(name="mimicGenerationFinishedEvent", type="flash.events.Event")]
	[Event(name="mimicViewValidatedEvent", type="flash.events.Event")]
	[Event(name="localMimicChangedEvent", type="flash.events.Event")]
	[Event(name="mimicEditViewReady", type="flash.events.Event")]
	public class MimicViewer extends SkinnableContainer implements ISettingsObserver
	{
		/* 
		 * Lots and lots of constants, most acting as enumerated types.
		 */
		private static const DEFAULT_MIMIC_IMAGE:BitmapData = new BitmapData(269, 190, false);
		
		private static const EMPTY_IMAGE:BitmapData = new BitmapData(1, 1);
		
		public static const MIMIC_STATE:String = "MimicState";
		public static const EDIT_STATE:String = "EditState";
		
		//[Embed(source="assets/shaders/layerCombiner3_1.pbj", mimeType="application/octet-stream")]
		[Embed(source="assets/shaders/layerCombinerFinalV4.pbj", mimeType="application/octet-stream")]
		private static var layerCombinerShaderData:Class;
		
		[Embed(source="assets/shaders/ColourChannelChooserV2.pbj", mimeType="application/octet-stream")]
		private static const colourChannelShaderSource:Class;
		
		//Associative map of mimic settings (i.e. landscape/portrait, staple finish, holepunch finish, etc)
		private var _mimicSettings:ObjectProxy;
		private var _availablePaperTypes:Vector.<PaperType>;
		private var _localMimicImages:Array;
		private var _scaledPunchImages:Array;
		private var _scaledStapleImages:Array;
		
		private var _finishingView:FinishingView;
		private var _imageEditView:ImageEditView;
		private var _imageEditViewImageReady:Boolean;
		
		private var _validationIndicator:BusyIndicator;
		private var _mimicViewValid:Boolean;
		private var _paperStateValid:Boolean;
		private var _foldStateValid:Boolean;
		private var _mimicTextureValid:Boolean;
		
		private var _imageSource:String = null;
		private var _imageLoader:Loader;
		
		public function MimicViewer()
		{
			_availablePaperTypes = new Vector.<PaperType>;
			
			this.setStyle("borderWeight", 0);
			this.setStyle("backgroundAlpha", 0.0);
			
			//Initialise states.
			var mimicState:State = new State();
			mimicState.name = MIMIC_STATE;
			var editState:State = new State();
			editState.name = EDIT_STATE;
			this.states = [mimicState, editState];
			this.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, onStateChange);
			
			this.layout = new BasicLayout();
		
			_imageLoader = new Loader();		
				_imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
				
			_scaledPunchImages = new Array();
			_scaledStapleImages = new Array();
				
			this.currentState = MIMIC_STATE;
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			this.addEventListener(Event.RESIZE, onResize);
			_mimicSettings = new ObjectProxy();
			initialiseMimicSettings();	
			CopySettings.get().registerObserver(this);
			_localMimicImages = new Array();
			_localMimicImages[PaperType.LANDSCAPE] = (new Finishing_Images.LocalMimicImageLandscape).bitmapData;
			_localMimicImages[PaperType.PORTRAIT] = (new Finishing_Images.LocalMimicImagePortrait).bitmapData;
			createScaledFinishingImages();
		}
		
		/* **************************************************
		 * **** EVENT LISTENERS AND OVERRIDDEN FUNCTIONS ****
		 * **************************************************/
		private function onCreationComplete(event:FlexEvent):void
		{
			if(ApplicationSettings.get().get(ApplicationSettings.USE_LOCAL_MIMIC))
			{
				imageSource = "local";
			}
		}
		
		private function createScaledFinishingImages():void
		{
			var scale:Number = ApplicationSettings.get().get(ApplicationSettings.MIMIC_DPI) / 50;
			_scaledPunchImages[CopySettings.HOLEPUNCH_NONE] = EMPTY_IMAGE.clone();
			_scaledPunchImages[CopySettings.HOLEPUNCH_2_HOLES] = (new Finishing_Images.Holes2Class).bitmapData;
			_scaledPunchImages[CopySettings.HOLEPUNCH_3_HOLES] = (new Finishing_Images.Holes3Class).bitmapData;
			_scaledPunchImages[CopySettings.HOLEPUNCH_4_HOLES] = (new Finishing_Images.Holes4Class).bitmapData;
			_scaledPunchImages[CopySettings.HOLEPUNCH_4_SWEDISH] = (new Finishing_Images.Holes4SwedishClass).bitmapData;
			
			_scaledStapleImages[CopySettings.STAPLE_NONE] = EMPTY_IMAGE.clone();
			_scaledStapleImages[CopySettings.STAPLE_1_LEFT] = (new Finishing_Images.Staple1LeftClass).bitmapData;
			_scaledStapleImages[CopySettings.STAPLE_2] = (new Finishing_Images.Staple2Class).bitmapData;
			_scaledStapleImages[CopySettings.STAPLE_3] = (new Finishing_Images.Staple3Class).bitmapData;
			_scaledStapleImages[CopySettings.STAPLE_4] = (new Finishing_Images.Staple4Class).bitmapData;
			/*_scaledStapleImages[CopySettings.STAPLE_NONE] = EMPTY_IMAGE.clone();
			_scaledStapleImages[CopySettings.STAPLE_1_LEFT] = createScaledImage((new Finishing_Images.Staple1LeftClass).bitmapData, scale, scale);
			_scaledStapleImages[CopySettings.STAPLE_2] = createScaledImage((new Finishing_Images.Staple2Class).bitmapData, scale, scale);
			_scaledStapleImages[CopySettings.STAPLE_3] = createScaledImage((new Finishing_Images.Staple3Class).bitmapData, scale, scale);
			_scaledStapleImages[CopySettings.STAPLE_4] = createScaledImage((new Finishing_Images.Staple4Class).bitmapData, scale, scale);*/
		}
		
		private function createScaledImage(original:BitmapData, scaleV:Number, scaleH:Number):BitmapData
		{
			var newData:BitmapData = new BitmapData(original.width * scaleV, original.height * scaleH, true);
			var m:Matrix = new Matrix();
			m.scale(scaleV, scaleH);
			newData.draw(original, m, null, null, null, false);
			return newData;
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			_finishingView = new FinishingView();
				_finishingView.x = 0; _finishingView.y = 0;
				_finishingView.width = 1024;
				_finishingView.height = 252;
				this.addElement(_finishingView);
				_mimicViewValid = false;
				_paperStateValid = true;
				_foldStateValid = true;
				_mimicTextureValid = true;
				
			_imageEditView = new ImageEditView();
				_imageEditView.x = 0; _imageEditView.y = 0;
				_imageEditView.width = 1024;
				_imageEditView.height = 252;
				_imageEditView.addEventListener(ImageEditView.VIEW_READY_EVENT, imageEditViewReady);
				this.addElement(_imageEditView);	
				_imageEditViewImageReady = false;
				
			_validationIndicator = new BusyIndicator();
				_validationIndicator.width = 64;
				_validationIndicator.height = 64;
				_validationIndicator.x = (this.width - 64.0) / 2.0;
				_validationIndicator.y = (this.height - 64.0) / 2.0;
				_validationIndicator.visible = false;
				this.addElement(_validationIndicator);
		}
		
		private function onResize(evt:ResizeEvent):void
		{
			_validationIndicator.x = (this.width - 64.0) / 2.0;
			_validationIndicator.y = (this.height - 64.0) / 2.0;
			_validationIndicator.setStyle("symbolColor", "black");
			_validationIndicator.setStyle("rotationInterval", 50);
			_imageEditView.height = this.height;
			_finishingView.height = this.height
		}
		
		private function onStateChange(evt:StateChangeEvent):void
		{
			//TODO Should look into some sort of transition between the components
			//     as opposed to a straight up swap of components.
			if(evt.newState == MIMIC_STATE)
			{
				_imageEditView.visible = false;
				_finishingView.visible = true;
				if(!_mimicViewValid)
					validateMimicView();
			}
			else if(evt.newState == EDIT_STATE)
			{
				_finishingView.visible = false;
				_imageEditView.visible = true;
			}
		}
		
		
		private function getColourChannelEnumValue(channelName:String):int
		{
			//autocolour = 0, colour = 1, grayscale = 2, red = 3, green = 4, blue = 5, cyan = 6, yellow = 7, magenta = 8.
			//This is defined in the pixel bender shader.
			switch(channelName)
			{
				case CopySettings.COLOUR_AUTO:
					return 0;
				case CopySettings.COLOUR_FULL:
					return 1;
				case CopySettings.COLOUR_GRAYSCALE:
					return 2;
				case CopySettings.COLOUR_RED:
					return 3;
				case CopySettings.COLOUR_GREEN:
					return 4;
				case CopySettings.COLOUR_BLUE:
					return 5;
				case CopySettings.COLOUR_CYAN:
					return 6;
				case CopySettings.COLOUR_MAGENTA:
					return 7;
				case CopySettings.COLOUR_YELLOW:
					return 8;
				default:
					return 0;
			}
		}
		
		public function notifySettingChanged(name:String, value:*):void
		{
			if(name == CopySettings.FOLD_TYPE)
			{
				_mimicSettings.foldType = value;	
			}
			else if(name == CopySettings.STAPLE_TYPE)
			{
				_mimicSettings.stapleType = value;
			}
			else if(name == CopySettings.HOLEPUNCH_TYPE)
			{
				_mimicSettings.punchType = value;
			}
			else if(name == CopySettings.PAPER_TYPE)
			{
				_mimicSettings.paperType = (CopySettings.get().get(CopySettings.MIMIC_FORMATTED_PAPER_TYPES))[value];
			}
			else if(name == CopySettings.COLOUR_TYPE)
			{
				_mimicSettings.displayColourChannel = getColourChannelEnumValue(value);
			}
		}
		
		/* ************************************************
		 * **** CLASS SPECIFIC FUNCTIONS ******************
		 * ************************************************/
		
		private function initialiseMimicSettings():void
		{
			_mimicSettings.foldType = CopySettings.FOLD_NONE;
			_mimicSettings.stapleType = CopySettings.STAPLE_NONE;
			_mimicSettings.punchType = CopySettings.HOLEPUNCH_NONE;
			_mimicSettings.defaultPrintBorder = 3; //3 millimetres. Machine dependent so should be configurable.
			_mimicSettings.scale = [1.0, 1.0]; //2-tuple representing x and y scale.	
			_mimicSettings.margin = [3.0, 3.0];
			_mimicSettings.paperType = (CopySettings.get().get(CopySettings.MIMIC_FORMATTED_PAPER_TYPES)[0]) as PaperType;
			_mimicSettings.orientation = 1;
			_mimicSettings.displayColourChannel = 0; //auto-colour
			_mimicSettings.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onMimicSettingChanged);
		}
		
		private function onMimicSettingChanged(evt:PropertyChangeEvent):void
		{
			if(evt.property == "paperType")
			{
				trace("ABCDEF: " + evt.newValue + ", " + _mimicSettings.paperType);
				if(ApplicationSettings.get().get(ApplicationSettings.USE_LOCAL_MIMIC))
					setLocalMimicAsSource(false);
				_paperStateValid = false;
				_mimicTextureValid = false;
			}
			else if(evt.property == "foldType")
			{
				_foldStateValid = false;
			}
			else if(evt.property == "stapleType")
			{
				_mimicTextureValid = false;
			}
			else if(evt.property == "punchType")
			{
				_mimicTextureValid = false;
			}
			else if(evt.property == "displayColourChannel")
			{
				_mimicTextureValid = false;
			}
			else if(evt.property == "scale" || evt.property == "margin" || evt.property == "orientation")
				_mimicTextureValid = false;
		}
		
		/**
		 * Function to populate the list of available paper types based on 
		 * which paper types are in the MFD trays. This list of available paper
		 * types should come in as a 2 dimensional array, where each sub array
		 * contains information about the paper in one tray in the following format:
		 * [name, width, height, type, colour].
		 * Name is a temporary attribute included for convenience.
		 **/
		public function populateAvailablePaperTypes(availablePapers:Array):void
		{
			_availablePaperTypes = new Vector.<PaperType>();
			for(var i:int = 0; i < availablePapers.length; i++)
			{
				_availablePaperTypes.push(availablePapers[i]);
			}
		}

		/**
		 * Function to handle the image once it has been loaded.
		 * This function assumes that the user is in mimic view when
		 * the mimic image is loaded.
		 */
		private function imageLoaded(event:Event):void
		{
			_imageEditViewImageReady = false;
			
			var prescanDPI:int = ApplicationSettings.get().get(ApplicationSettings.PRESCAN_DPI);
			trace("IMAGE LOADED: " + prescanDPI + " :: " + event.target.content.bitmapData.width + ", " + event.target.content.bitmapData.height);	
			_mimicSettings.originalImageDimensions = new Array();
			_mimicSettings.originalImageDimensions[0] = (event.target.content.bitmapData.width / prescanDPI) * 25.4;
			_mimicSettings.originalImageDimensions[1] = (event.target.content.bitmapData.height / prescanDPI) * 25.4;
			
			_imageEditView.image = event.target.content.bitmapData;
			//setMimicViewTexture(event.target.content.bitmapData.clone());
			trace("IMAGE FINISHING LOADING AND HANDLING.");
		}
		
		private function imageEditViewReady(event:Event):void
		{
			trace("IMAGE EDIT VIEW READY");
			if(ApplicationSettings.get().get(ApplicationSettings.USE_LOCAL_MIMIC))
				this.dispatchEvent(new Event("localMimicChangedEvent"));
			this.dispatchEvent(new Event("mimicEditViewReady"));
			_imageEditViewImageReady = true;
		}
		
		public function validateMimicView():void
		{
			if(!_paperStateValid)
			{
				trace("SETTING PAPER STATE");
				//We only want to rerender straight away if the texture is valid,
				//else it's more efficient to wait until the texture is validated to 
				//re-render
				_finishingView.setPaperType(_mimicSettings.paperType);
				_paperStateValid = true;
			}
			
			if(!_foldStateValid)
			{
				trace("SETTING FOLD STATE");
				//We only want to rerender the fold if the mimic texture is valid, because if the mimic texture
				//gets validated then we re-render the fold at the end anyway.
				_finishingView.setFold(CopySettings.get().get(CopySettings.FOLD_TYPE), _mimicTextureValid);
				_foldStateValid = true;
			}
			
			if(_imageSource != null && !_mimicTextureValid)
			{
				trace("SETTING MIMIC VIEW TEXTURE.");
				setMimicViewTexture(_imageEditView.finalBitmapData());
				_mimicTextureValid = true;
			}
			
			_mimicViewValid = true;
			this.dispatchEvent(new Event("mimicViewValidatedEvent"));
		}
		
		//Calculate the size of the mimic in pixels when scaled within the 
		//paper 'image'. Returns a 2-tuple, containing the width and height
		//values.
		private function calculateMimicImageSize(imageData:BitmapData, currPaperType:PaperType, mimicDPI:Number):Array
		{
			trace("CALCULATING MIMIC SIZE: [" + imageData.width + ", " + imageData.height + "], " + currPaperType + ", " + mimicDPI);
			var fitToSize:Array = new Array();
			var scanOrientation:int = currPaperType.orientation;
			//var scanOrientation:int = (imageData.width > imageData.height) ? PaperType.LANDSCAPE : PaperType.PORTRAIT; //0 - landscape
			
			var imgWidthMM:Number = imageData.width / mimicDPI * 25.4;
			var imgHeightMM:Number = imageData.height / mimicDPI * 25.4;

			if(currPaperType.orientation == scanOrientation)
			{
				//Get the size in millimeters (minus the margins) that the image will take up on the page.
				//fitToSize[0] = (currPaperType.widthMillimeters - ((_mimicSettings.margin as Array)[0] * 2.0)) * (_mimicSettings.scale as Array)[0];
				//fitToSize[1] = (currPaperType.heightMillimeters - ((_mimicSettings.margin as Array)[1] * 2.0)) * (_mimicSettings.scale as Array)[1];
				fitToSize[0] = (imgWidthMM - ((_mimicSettings.margin as Array)[0] * 2.0)) * (_mimicSettings.scale as Array)[0];
				fitToSize[1] = (imgHeightMM - ((_mimicSettings.margin as Array)[1] * 2.0)) * (_mimicSettings.scale as Array)[1];
			}
			else if(currPaperType.orientation == PaperType.LANDSCAPE) //Image orientation must be portrait
			{
				//The height will be the longest edge of the image, so use the paper's height (minus margins)
				//fitToSize[1] = (currPaperType.heightMillimeters - ((_mimicSettings.margin as Array)[1] * 2.0)) * (_mimicSettings.scale as Array)[1];
				fitToSize[1] = (imgHeightMM - ((_mimicSettings.margin as Array)[1] * 2.0)) * (_mimicSettings.scale as Array)[1];
				fitToSize[0] = (fitToSize[1] * (imageData.height / imageData.width)) * (_mimicSettings.scale as Array)[0];
			}
			else if(currPaperType.orientation == PaperType.PORTRAIT) //Image orientation must be landscape
			{
				//fitToSize[0] = (currPaperType.widthMillimeters - ((_mimicSettings.margin as Array)[0] * 2.0)) * (_mimicSettings.scale as Array)[0];
				fitToSize[0] = (imgWidthMM - ((_mimicSettings.margin as Array)[0] * 2.0)) * (_mimicSettings.scale as Array)[0];
				fitToSize[1] = (fitToSize[0] * (imageData.width / imageData.height)) * (_mimicSettings.scale as Array)[1];
			}
			
			//Convert the size in millimeters into pixels.
			fitToSize[0] = Math.round((fitToSize[0] / 25.4) * mimicDPI);
			fitToSize[1] = Math.round((fitToSize[1] / 25.4) * mimicDPI);

			return fitToSize;
		}
		
		private function setMimicViewTexture(originalImageData:BitmapData):void
		{
			//Throw up the busy indicator showing that the mimic has started generating.
			_validationIndicator.visible = true;
			
			var currPaperType:PaperType = _mimicSettings.paperType as PaperType;
			var paperData:BitmapData = currPaperType.bitmapData;

			//Scale the mimic image down to a new (lower and more efficient to work with) DPI.
			var m:Matrix = new Matrix();
			var prescanDPI:Number = ApplicationSettings.get().get(ApplicationSettings.PRESCAN_DPI);
			var mimicDPI:Number = ApplicationSettings.get().get(ApplicationSettings.MIMIC_DPI);
			var scale:Number =  mimicDPI / prescanDPI;
			m.scale(scale, scale);
			var imageData:BitmapData = new BitmapData((originalImageData.width / prescanDPI) * mimicDPI,
													  (originalImageData.height / prescanDPI) * mimicDPI);
			imageData.draw(originalImageData, m, null, null, null, true);
			var fitToSize:Array = calculateMimicImageSize(imageData, currPaperType, mimicDPI);
			
			var target:BitmapData = new BitmapData(paperData.width, paperData.height);
			
			
			var shaderJobB:ShaderJob = new ShaderJob(new Shader(new colourChannelShaderSource()), target);
			shaderJobB.shader.data.channel.value = [_mimicSettings.displayColourChannel];
			shaderJobB.shader.data.src.input = imageData;
			
			shaderJobB.addEventListener(Event.COMPLETE, function(evt:ShaderEvent):void {
				var shaderJobA:ShaderJob = new ShaderJob(new Shader(new layerCombinerShaderData()), target);
				shaderJobA.shader.data.paperImg.input = paperData;
				shaderJobA.shader.data.paperSize.value = [paperData.width, paperData.height];
				shaderJobA.shader.data.scanImg.input = target;
				shaderJobA.shader.data.scanSize.value = [imageData.width, imageData.height];
				shaderJobA.shader.data.scaledSize.value = fitToSize;
				shaderJobA.shader.data.scanOrientation.value = [currPaperType.orientation];
				shaderJobA.shader.data.margins.value = [_mimicSettings.margin[0] / 25.4 * mimicDPI, _mimicSettings.margin[1] / 25.4 * mimicDPI];
				
				//Punch options
				var showPunch:int = (_mimicSettings.punchType == CopySettings.HOLEPUNCH_NONE) ? 0 : 1;
				shaderJobA.shader.data.showPunch.value = [showPunch];
				
				var holeImg:BitmapData = _scaledPunchImages[_mimicSettings.punchType];
				shaderJobA.shader.data.punchImg.input = holeImg;
				shaderJobA.shader.data.punchImgSize.value = [holeImg.width, holeImg.height];
				//Staple options
				var showStaple:int = (_mimicSettings.stapleType == CopySettings.STAPLE_NONE) ? 0 : ((_mimicSettings.stapleType == CopySettings.STAPLE_1_LEFT) ? 2 : 1);
				shaderJobA.shader.data.showStaple.value = [showStaple];
				
				var stapleImg:BitmapData = _scaledStapleImages[_mimicSettings.stapleType];
				shaderJobA.shader.data.stapleImg.input = stapleImg;
				shaderJobA.shader.data.stapleImgSize.value = [stapleImg.width, stapleImg.height];
				
				shaderJobA.addEventListener(Event.COMPLETE, function(evt:ShaderEvent):void {
					_finishingView.bitmapTexture = target;
					if(!_finishingView.visible)
						_finishingView.visible = true;
					//At this point the mimic has (almost) finished being validated. We can 
					//probably hide the indicator now. May have to be done on the finishing view
					//ready event.
					_validationIndicator.visible = false;
				});
				shaderJobA.start(false);
			});
			
			shaderJobB.start(false);
			
			
		}
		
		public function invalidateMimicTexture():void
		{
			_mimicTextureValid = false;
		}
		
		public function invalidateFoldState():void
		{
			_foldStateValid = false;
		}
		
		public function invalidatePaperState():void
		{
			_paperStateValid = false;
		}
		
		public function invalidateMimicView():void
		{
			_mimicViewValid = false;
		}
		
		/* ************************************************
		 * **** PROPERTY GETTERS AND SETTERS **************
		 * ************************************************/
		public function get mimicSettings():ObjectProxy
		{
			return _mimicSettings;
		}

		public function set mimicSettings(value:ObjectProxy):void
		{
			_mimicSettings = value;
		}
		
		public function get imageEditView():ImageEditView
		{
			return _imageEditView;
		}
		
		public function get finishingView():FinishingView
		{
			return _finishingView;
		}
		
		public function get availablePaperTypes():Vector.<PaperType>
		{
			return _availablePaperTypes;
		}

		public function set availablePaperTypes(value:Vector.<PaperType>):void
		{
			_availablePaperTypes = value;
		}

		public function get imageSource():*
		{
			return _imageSource;
		}

		public function set imageSource(value:*):void
		{
			if(value == null)
			{
				_imageSource = "empty";
				setMimicViewTexture(DEFAULT_MIMIC_IMAGE);
			}
			else if(value is String)
			{
				if(value == "local")
				{
					setLocalMimicAsSource(true);
					this.dispatchEvent(new Event("mimicEditViewReady"));
				}
				else
				{
					_imageSource = value;
					var request:URLRequest = new URLRequest(value);
					_imageLoader.load(new URLRequest(value));
				}
			}
			else
			{
				setLocalMimicAsSource(true);
			}
		}

		private function setLocalMimicAsSource(validate:Boolean):void
		{
			var ori:int = (_mimicSettings.paperType as PaperType).orientation;
			_imageSource = "local";
			_imageEditViewImageReady = false;
			_imageEditView.image = _localMimicImages[ori];
			
			if(validate)
				setMimicViewTexture(_localMimicImages[ori].clone());
		}
		
		public function get pluginList():ImageEditPluginList
		{
			return _imageEditView.pluginList;
		}
		
		public function reset():void
		{
			_imageEditView.resetState();
		}
		
	}
}