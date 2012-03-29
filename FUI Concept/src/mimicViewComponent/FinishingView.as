package mimicViewComponent
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import integration.CopySettings;
	
	import mx.events.ResizeEvent;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.core.SpriteVisualElement;
	
	public class FinishingView extends Group
	{
		private static const EMPTY_BITMAP:BitmapData = new BitmapData(269, 190, false, 0xFFFFFF);
		public static const DEFAULT_PAPER_TYPE:PaperType = new PaperType("FinishViewDefaultA4");
		public static const MIMIC_CLICK_EVENT:String = "mimicClickEvent";
		private var _currentMaxWidth:int, _currentMaxHeight:int;
		
		private var _foldArray:Array;
		private var _currentFold:Fold;
		
		private var _bitmapTexture:BitmapData;
		private var _currPaperType:PaperType;
		private var _instructionLabel:Label;
		
		
		public function FinishingView()
		{
			_foldArray = new Array();
			_foldArray[CopySettings.FOLD_NONE] = new NoFold();
			_foldArray[CopySettings.FOLD_SINGLE] = new SingleFold();
			_foldArray[CopySettings.FOLD_Z] = new ZFold();
			_foldArray[CopySettings.FOLD_HALF_Z] = new HalfZFold();
			_foldArray[CopySettings.FOLD_C] = new CFold();
			this.addEventListener(Event.RESIZE, onResize);
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			_bitmapTexture = EMPTY_BITMAP;
			setPaperType(new PaperType("finish view default"));
			
			_instructionLabel = new Label();
			_instructionLabel.visible = false;
			_instructionLabel.text = "Tap preview to edit";
			_instructionLabel.setStyle("fontSize", 20);
			this.addElement(_instructionLabel);
		}
		
		/*private function onResize(event:ResizeEvent):void
		{
			_currentMaxWidth = 269 * (this.height / 252);
			_currentMaxHeight = 208 * (this.height / 252);
			if(_currentFold)
			{
				_currentFold.handleContainerResize(this)
				render();
				_instructionLabel.x = (this.width - _instructionLabel.width) / 2.0;
				_instructionLabel.top = _currentFold.container.y + _currentFold.container.height + 8; 
				_instructionLabel.visible = true;
			}
			
		}*/
		
		private function onResize(event:ResizeEvent):void
		{
			_currentMaxWidth = 328 * (this.height / 295); //old: 252
			_currentMaxHeight = 254 * (this.height / 295); //old: 252
			if(_currentFold)
			{
				_currentFold.handleContainerResize(this)
				render();
				_instructionLabel.x = (this.width - _instructionLabel.width) / 2.0;
				_instructionLabel.top = _currentFold.container.y + _currentFold.container.height + (10 * (this.height / 295)); 
				_instructionLabel.visible = true;
			}
		}
		
		public function setPaperType(paperType:PaperType):void
		{
			_currPaperType = paperType;
		}
		
		public function setFold(fold:int, rerender:Boolean):void
		{
			if(_currentFold)
				_currentFold.remove(this);
			_currentFold = _foldArray[fold];
			_currentFold.apply(this);
		}
		
		public function render():void
		{
			if(_currentFold)
			{
				_currentFold.remove(this);
				_currentFold.apply(this);
			}
			else
			{
				(_foldArray[CopySettings.FOLD_NONE] as Fold).apply(this);
				_currentFold = _foldArray[CopySettings.FOLD_NONE];
			}
		}

		public function get currentPaperType():PaperType
		{
			return _currPaperType;
		}
		
		public function get bitmapTexture():BitmapData
		{
			return _bitmapTexture;
		}
		
		public function set bitmapTexture(value:BitmapData):void
		{
			_bitmapTexture = value;
			if(_currentFold)
			{
				_currentFold.remove(this);
				_currentFold.apply(this);
			}
			else
			{
				_foldArray[CopySettings.FOLD_NONE].apply(this);
				_currentFold = _foldArray[CopySettings.FOLD_NONE];
			}
			_instructionLabel.x = (this.width - _instructionLabel.width) / 2.0;
			//_instructionLabel.top = _currentFold.container.y + _currentFold.container.height + 8;
			_instructionLabel.top = _currentFold.container.y + _currentFold.container.height + (10 * (this.height / 295));
			_instructionLabel.visible = true;
		}
		
		public function getMaximumMimicWidth():int
		{
			return _currentMaxWidth;
		}
		
		public function getMaximumMimicHeight():int
		{
			return _currentMaxHeight;
		}
		
		public static function calcMimicDimensionsForPaperType(paperType:PaperType, maxMimicWidth:int, maxMimicHeight:int):Point
		{
			var dims:Point = new Point();
			if(paperType.orientation == PaperType.LANDSCAPE)
			{
				dims.x = maxMimicWidth;
				dims.y = maxMimicWidth * (paperType.heightMillimeters / paperType.widthMillimeters);
			}
			else
			{
				dims.x = maxMimicHeight * (paperType.widthMillimeters / paperType.heightMillimeters);
				dims.y = maxMimicHeight;
			}
			
			
			return dims;
		}
	}
	
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.PerspectiveProjection;
import flash.geom.Point;
import flash.geom.Vector3D;

import mimicViewComponent.FinishingView;
import mimicViewComponent.PaperType;

import spark.core.SpriteVisualElement;
import spark.filters.DropShadowFilter;

class Fold extends EventDispatcher
{
	[Bindable]
	protected var dsf:DropShadowFilter = new spark.filters.DropShadowFilter(1, 90, 0x888888, 1, 4, 4, 1, 1, false);
	
	protected var _container:SpriteVisualElement;
	
	public function Fold()
	{
		
	}
	
	protected function compileLightedTexture(originalImg:BitmapData, gradientProps:Object, view:FinishingView):BitmapData
	{
		var temp:Sprite = new Sprite();
		var dims:Point = FinishingView.calcMimicDimensionsForPaperType(view.currentPaperType, view.getMaximumMimicWidth(), view.getMaximumMimicHeight());
		
		var g:Graphics = temp.graphics;
		var m:Matrix = new Matrix();
		m.scale( dims.x / originalImg.width, dims.y / originalImg.height );
		g.beginBitmapFill(originalImg, m, false, true);
		g.drawRect(0, 0, dims.x, dims.y);
		g.endFill();
		
		var gm:Matrix = new Matrix();
		gm.createGradientBox(dims.x, dims.y, 0, 0, 0);
		g.beginGradientFill(gradientProps.gradType, gradientProps.colours, gradientProps.alphas, gradientProps.ratios, gm);
		g.drawRect(0, 0, dims.x, dims.y);
		g.endFill();
		
		//Draw the gradiented & scaled image to a new bitmap data object. Without the 0xFF 
		//as the fill colour for the base bitmap, the alpha channel won't be drawn properly (should
		//look into why this is).
		var lightedImage:BitmapData = new BitmapData(temp.width, temp.height, true, 0xFF);
		lightedImage.draw(temp);
		return lightedImage;
	}
	
	public function apply(finishingView:FinishingView):void
	{	
	}
	
	public function remove(finishingView:FinishingView):void
	{
	}
	
	public function handleContainerResize(view:FinishingView):void
	{
		
	}
	
	public function dispatchClickEvent(evt:MouseEvent):void
	{
		//have to use the container object to dispatch the event because
		//the fold object itself will not sit in the displaylist
		_container.dispatchEvent(new Event(FinishingView.MIMIC_CLICK_EVENT, true));
	}
	
	public function get container():SpriteVisualElement
	{
		return _container;
	}
}


class NoFold extends Fold
{
	private var _foldObj:Bitmap;
	private var _sprite:Sprite;
	
	public function NoFold()
	{
		
	}
	
	public override function apply(view:FinishingView):void
	{
		_sprite = new Sprite();
		var dims:Point = FinishingView.calcMimicDimensionsForPaperType(view.currentPaperType, view.getMaximumMimicWidth(), view.getMaximumMimicHeight());
		
		var g:Graphics = _sprite.graphics;
		var m:Matrix = new Matrix();
		m.scale( dims.x / view.bitmapTexture.width, dims.y / view.bitmapTexture.height );
		g.beginBitmapFill(view.bitmapTexture, m, false, true);
		g.drawRect(0, 0, dims.x, dims.y);
		g.endFill();
		
		_container = new SpriteVisualElement();
		_container.x = (view.width - _sprite.width) / 2.0;
		_container.y = (view.height - _sprite.height) / 6.0;
		_container.width = _sprite.width;
		_container.height = _sprite.height;
		_container.filters = [dsf];
		_container.transform.perspectiveProjection = new PerspectiveProjection();
		_container.transform.perspectiveProjection.fieldOfView = 60;
		_container.addChild(_sprite);
		_container.addEventListener(MouseEvent.CLICK, dispatchClickEvent);
		view.addElement(_container);
	}
	
	public override function remove(view:FinishingView):void
	{
		view.removeElement(_container);
	}
	
	public override function handleContainerResize(view:FinishingView):void
	{
		_container.x = (view.width - _container.width) / 2.0;
		_container.y = (view.height - _container.height) / 6.0;
	}
	
}

class SingleFold extends Fold
{
	private static const _gradType:String = GradientType.LINEAR;
	private static const _colours:Array = [0xBBBBBB, 0xBBBBBB, 0x000000, 0xBBBBBB, 0xFFFFFF];
	private static const _alphas:Array = [0.2, 0.2, 0.1, 0.1, 0.2];
	private static const _ratios:Array = [0.0, 127, 128, 129, 255.0];
	private static const FOLD_ANGLE:Number = 120;
	
	private var _leftContainer:SpriteVisualElement;
	private var _rightContainer:SpriteVisualElement;
	
	public override function apply(view:FinishingView):void
	{
		var lightedTex:BitmapData = compileLightedTexture(view.bitmapTexture,
															{gradType:_gradType, colours:_colours, alphas:_alphas, ratios:_ratios},
															view);
		
		var segmentWidth:Number = lightedTex.width / 2.0;
		
		//Create left half of fold as a sprite.
		var leftSegment:Sprite = new Sprite();
		var leftG:Graphics = leftSegment.graphics;
		leftG.beginBitmapFill(lightedTex, null, false, false);
		leftG.drawRect(0, 0, segmentWidth, lightedTex.height);
		leftG.endFill();
		
		//Create right half of fold as a sprite
		var transMat:Matrix = new Matrix();
		transMat.tx = -segmentWidth;
		var rightSegment:Sprite = new Sprite();
		var rightG:Graphics = rightSegment.graphics;
		rightG.beginBitmapFill(lightedTex, transMat, false, false);
		rightG.drawRect(0, 0, segmentWidth, lightedTex.height);
		rightG.endFill();
		
		//Create container to hold both sprites.
		_container = new SpriteVisualElement();
		_container.width = lightedTex.width;
		_container.height = lightedTex.height;
		_container.addEventListener(MouseEvent.CLICK, dispatchClickEvent);
		_container.x = (view.width - _container.width) / 2.0;
		_container.y = (view.height - _container.height) / 6.0;
		_container.addChild(leftSegment);
		_container.addChild(rightSegment);
		_container.filters = [dsf];
		//Set up the sprite container's perpective projection with a centre point
		//at the centre of the container.
		_container.transform.perspectiveProjection = new PerspectiveProjection();
		_container.transform.perspectiveProjection.fieldOfView = 60;
		_container.transform.perspectiveProjection.projectionCenter = new Point(_container.width / 2.0, _container.height / 2.0);

		//Rotate the 2 segments of the fold.
		leftSegment.z = 1;
		leftSegment.transform.matrix3D.appendTranslation(-segmentWidth / 2.0, 0, 0);
		leftSegment.transform.matrix3D.appendRotation(-90 + (FOLD_ANGLE / 2.0), Vector3D.Y_AXIS);
		leftSegment.transform.matrix3D.appendTranslation(segmentWidth / 2.0, 0, 0);
		leftSegment.x = _container.width / 2.0 - newWidth;
		rightSegment.z = 1;
		rightSegment.transform.matrix3D.appendTranslation(-segmentWidth / 2.0, 0, 0);
		rightSegment.transform.matrix3D.appendRotation(90 - (FOLD_ANGLE / 2.0), Vector3D.Y_AXIS);
		rightSegment.transform.matrix3D.appendTranslation(segmentWidth / 2.0, 0, 0);
		rightSegment.x = _container.width / 2.0;
		
		var newWidth:Number = (segmentWidth * Math.sin((FOLD_ANGLE* Math.PI) / 360.0));
		var dx:Number = segmentWidth - newWidth;
		leftSegment.x += dx;
		
		view.addElement(_container);
	}
	
	public override function remove(view:FinishingView):void
	{
		view.removeElement(_container);
	}	
	
	public override function handleContainerResize(view:FinishingView):void
	{
		_container.x = (view.width - _container.width) / 2.0;
		_container.y = (view.height - _container.height) / 6.0;
	}
}

class ZFold extends Fold
{
	private static const _gradType:String = GradientType.LINEAR;
	private static const _colours:Array = [0xBBBBBB, 0xBBBBBB, 0x000000, 0xBBBBBB, 0xFFFFFF, 0x888888, 0xBBBBBB, 0xBBBBBB];
	private static const _alphas:Array = [0.2,   0.2, 0.1, 0.1, 0.2, 0.1,   0.1,   0.1];
	private static const _ratios:Array = [  0,    83,   85,  87,  168, 170, 171, 255];
	private static const FOLD_ANGLE:Number = 100;
	
	public override function apply(view:FinishingView):void
	{
		var lightedTex:BitmapData = compileLightedTexture(view.bitmapTexture,
			{gradType:_gradType, colours:_colours, alphas:_alphas, ratios:_ratios},
			view);
		var translationMatrix:Matrix = new Matrix();
		
		var segmentWidth:Number = lightedTex.width / 3.0;
		
		var left:Sprite = new Sprite();
		left.graphics.beginBitmapFill(lightedTex);
		left.graphics.drawRect(0, 0, segmentWidth, lightedTex.height);
		left.graphics.endFill();
		
		translationMatrix.tx = -segmentWidth;
		var middle:Sprite = new Sprite();
		middle.graphics.beginBitmapFill(lightedTex, translationMatrix);
		middle.graphics.drawRect(0, 0, lightedTex.width / 3.0, lightedTex.height);
		middle.graphics.endFill();
		
		translationMatrix.tx = -segmentWidth * 2.0;
		var right:Sprite = new Sprite();
		right.graphics.beginBitmapFill(lightedTex, translationMatrix);
		right.graphics.drawRect(0, 0, segmentWidth, lightedTex.height);
		right.graphics.endFill();
		
		var rotatedSegmentWidth:Number = segmentWidth * Math.sin(FOLD_ANGLE * Math.PI / 360.0);
		
		_container = new SpriteVisualElement();
		_container.x = (view.width - lightedTex.width) / 2.0;
		_container.y = (view.height - lightedTex.height) / 6.0;
		_container.width = lightedTex.width;
		_container.height = lightedTex.height;
		_container.addEventListener(MouseEvent.CLICK, dispatchClickEvent);
		_container.addChild(left);
		_container.addChild(middle);
		_container.addChild(right);
		_container.filters = [dsf];
		view.addElement(_container);
		//Set up the sprite container's perpective projection with a centre point
		//at the centre of the container.
		_container.transform.perspectiveProjection = new PerspectiveProjection();
		_container.transform.perspectiveProjection.fieldOfView = 60;
		_container.transform.perspectiveProjection.projectionCenter = new Point(_container.width / 2.0, _container.height / 2.0);
		
		left.z = 1;
		left.transform.matrix3D.appendTranslation(-segmentWidth / 2.0, -lightedTex.height / 2.0, 0.0);
		left.transform.matrix3D.appendRotation(-90 + (FOLD_ANGLE / 2.0), Vector3D.Y_AXIS);
		left.transform.matrix3D.appendTranslation(segmentWidth / 2.0, lightedTex.height / 2.0, 0.0);
		left.x = _container.width / 2.0 - (rotatedSegmentWidth * 1.5);
		
		middle.z = 1;
		middle.transform.matrix3D.appendTranslation(-segmentWidth / 2.0, -lightedTex.height / 2.0, 0.0);
		middle.transform.matrix3D.appendRotation(90 - (FOLD_ANGLE / 2.0), Vector3D.Y_AXIS);
		middle.transform.matrix3D.appendTranslation(segmentWidth / 2.0, lightedTex.height / 2.0, 0.0);
		middle.x = (_container.width - rotatedSegmentWidth) / 2.0;
		
		var newDepth:Number = rotatedSegmentWidth / Math.tan( FOLD_ANGLE * Math.PI / 360.0);
		right.z = 1;
		right.transform.matrix3D.appendTranslation(0.0, 0.0, -newDepth / 2.0);
		right.x = (_container.width + rotatedSegmentWidth) / 2.0;
	}
	
	public override function remove(view:FinishingView):void
	{
		view.removeElement(_container);
	}		
	
	public override function handleContainerResize(view:FinishingView):void
	{
		_container.x = (view.width - _container.width) / 2.0;
		_container.y = (view.height - _container.height) / 6.0;
	}
}

class HalfZFold extends Fold
{
	private static const _gradType:String = GradientType.LINEAR;
	private static const _colours:Array = [0xBBBBBB, 0xBBBBBB, 0x888888, 0xBBBBBB, 0xBBBBBB, 0x000000, 0xBBBBBB, 0xFFFFFF];
	private static const _alphas:Array = [0.1,   0.1, 0.2, 0.2, 0.2, 0.1,   0.1,   0.2];
	private static const _ratios:Array = [  0,    126,   128,  129,  190, 192, 193, 255];
	private static const FOLD_ANGLE:Number = 90;
	
	public override function apply(view:FinishingView):void
	{
		var lightedTex:BitmapData = compileLightedTexture(view.bitmapTexture,
			{gradType:_gradType, colours:_colours, alphas:_alphas, ratios:_ratios},
			view);
		var translationMatrix:Matrix = new Matrix();
		
		var left:Sprite = new Sprite();
		left.graphics.beginBitmapFill(lightedTex);
		left.graphics.drawRect(0, 0, lightedTex.width / 2.0, lightedTex.height);
		left.graphics.endFill();
		
		translationMatrix.tx = -lightedTex.width / 2.0;
		var middle:Sprite = new Sprite();
		middle.graphics.beginBitmapFill(lightedTex, translationMatrix);
		middle.graphics.drawRect(0, 0, lightedTex.width / 4.0, lightedTex.height);
		middle.graphics.endFill();
		
		translationMatrix.tx = -lightedTex.width * 0.75;
		var right:Sprite = new Sprite();
		right.graphics.beginBitmapFill(lightedTex, translationMatrix);
		right.graphics.drawRect(0, 0, lightedTex.width / 4.0, lightedTex.height);
		right.graphics.endFill();
		
		_container = new SpriteVisualElement();
		_container.x = (view.width - lightedTex.width) / 2.0;
		_container.y = (view.height - lightedTex.height) / 6.0;
		_container.width = lightedTex.width;
		_container.height = lightedTex.height;
		_container.addEventListener(MouseEvent.CLICK, dispatchClickEvent);
		_container.addChild(left);
		_container.addChild(middle);
		_container.addChild(right);
		_container.filters = [dsf];
		view.addElement(_container);
		//Set up the sprite container's perpective projection with a centre point
		//at the centre of the container.
		_container.transform.perspectiveProjection = new PerspectiveProjection();
		_container.transform.perspectiveProjection.fieldOfView = 60;
		_container.transform.perspectiveProjection.projectionCenter = new Point(_container.width / 2.0, _container.height / 2.0);
		
		var foldedSegmentWidth:Number = lightedTex.width / 4.0;
		var totalWidth:Number = (lightedTex.width / 2.0) + (foldedSegmentWidth * 2.0);
		left.z = 1;
		var leftDepth:Number = foldedSegmentWidth * Math.cos(FOLD_ANGLE * Math.PI / 360.0);
		left.transform.matrix3D.appendTranslation(0.0, 0.0, -leftDepth / 2.0); //Divided by two because the folded segments are actually rotated around their centre point.
		left.x = (lightedTex.width - totalWidth) / 2.0;
		
		var rotatedSegmentWidth:Number = foldedSegmentWidth * Math.sin(FOLD_ANGLE * Math.PI / 360.0); 
		
		middle.z = 1;
		middle.transform.matrix3D.appendTranslation(-foldedSegmentWidth / 2.0, -lightedTex.height / 2.0, 0.0);
		middle.transform.matrix3D.appendRotation(-90 + (FOLD_ANGLE / 2.0), Vector3D.Y_AXIS);
		middle.transform.matrix3D.appendTranslation(foldedSegmentWidth / 2.0, lightedTex.height / 2.0, 0.0);
		middle.x = (_container.width + (_container.width - totalWidth)) / 2.0;
		
		right.z = 1;
		right.transform.matrix3D.appendTranslation(-foldedSegmentWidth / 2.0, -lightedTex.height / 2.0, 0.0);
		right.transform.matrix3D.appendRotation(90 - (FOLD_ANGLE / 2.0), Vector3D.Y_AXIS);
		right.transform.matrix3D.appendTranslation(foldedSegmentWidth / 2.0, lightedTex.height / 2.0, 0.0);
		right.x = middle.x + rotatedSegmentWidth;
		
	}
	
	public override function remove(view:FinishingView):void
	{
		view.removeElement(_container);	
	}	
	
	public override function handleContainerResize(view:FinishingView):void
	{
		_container.x = (view.width - _container.width) / 2.0;
		_container.y = (view.height - _container.height) / 6.0;
	}
}


class CFold extends Fold
{
	private static const _gradType:String = GradientType.LINEAR;
	private static const _colours:Array = [0xBBBBBB, 0xBBBBBB, 0x000000, 0xBBBBBB, 0xBBBBBB, 0x000000, 0xBBBBBB, 0xFFFFFF];
	private static const _alphas:Array = [0.2,   0.2, 0.1, 0.15,  0.15, 0.1, 0.1, 0.2];
	private static const _ratios:Array = [  0,  63,  64,  65,  191, 192, 193, 255];
	private static const FOLD_ANGLE:Number = 130;
	
	public override function apply(view:FinishingView):void
	{
		var lightedTex:BitmapData = compileLightedTexture(view.bitmapTexture,
															{gradType:_gradType, colours:_colours, alphas:_alphas, ratios:_ratios},
															view);
		var translationMatrix:Matrix = new Matrix();
		
		var foldedSegmentWidth:Number = lightedTex.width / 4.0;
		
		var left:Sprite = new Sprite();
		left.graphics.beginBitmapFill(lightedTex);
		left.graphics.drawRect(0, 0, foldedSegmentWidth, lightedTex.height);
		left.graphics.endFill();
		
		translationMatrix.tx = -(lightedTex.width / 4.0);
		var middle:Sprite = new Sprite();
		middle.graphics.beginBitmapFill(lightedTex, translationMatrix);
		middle.graphics.drawRect(0, 0, foldedSegmentWidth * 2.0, lightedTex.height);
		middle.graphics.endFill();
		
		translationMatrix.tx = -lightedTex.width * 0.75;
		var right:Sprite = new Sprite();
		right.graphics.beginBitmapFill(lightedTex, translationMatrix);
		right.graphics.drawRect(0, 0, foldedSegmentWidth, lightedTex.height);
		right.graphics.endFill();
		
		_container = new SpriteVisualElement();
		_container.x = (view.width - lightedTex.width) / 2.0;
		_container.y = (view.height - lightedTex.height) / 6.0;
		_container.width = lightedTex.width;
		_container.height = lightedTex.height;
		_container.addEventListener(MouseEvent.CLICK, dispatchClickEvent);
		_container.addChild(left);
		_container.addChild(middle);
		_container.addChild(right);
		_container.filters = [dsf];
		view.addElement(_container);
		//Set up the sprite container's perpective projection with a centre point
		//at the centre of the container.
		_container.transform.perspectiveProjection = new PerspectiveProjection();
		_container.transform.perspectiveProjection.fieldOfView = 60;
		_container.transform.perspectiveProjection.projectionCenter = new Point(_container.width / 2.0, _container.height / 2.0);
		
		//Angle between the folded segment and a line perpendicular to the flat segment.
		var paperSegAngle:Number = FOLD_ANGLE - 90;
		var totalWidth:Number = (lightedTex.width / 2.0) + (foldedSegmentWidth * 2.0);
		var rotatedSegmentWidth:Number = foldedSegmentWidth * Math.sin(paperSegAngle * Math.PI / 180.0);
		
		left.z = 1;
		left.transform.matrix3D.appendTranslation(-foldedSegmentWidth / 2.0, -lightedTex.height / 2.0, 0.0);
		left.transform.matrix3D.appendRotation(-90 + paperSegAngle, Vector3D.Y_AXIS);
		left.transform.matrix3D.appendTranslation(foldedSegmentWidth / 2.0, lightedTex.height / 2.0, 0.0);
		left.x = (_container.width / 2.0) - foldedSegmentWidth - rotatedSegmentWidth; 
		
		var newDepth:Number = foldedSegmentWidth * Math.cos(paperSegAngle * Math.PI / 180.0);
		middle.z = 1;
		middle.transform.matrix3D.appendTranslation(0.0, 0.0, newDepth / 2.0);
		middle.x = (_container.width / 2.0) - foldedSegmentWidth;
		
		right.z = 1;
		right.transform.matrix3D.appendTranslation(-foldedSegmentWidth / 2.0, -lightedTex.height / 2.0, 0.0);
		right.transform.matrix3D.appendRotation(90 - paperSegAngle, Vector3D.Y_AXIS);
		right.transform.matrix3D.appendTranslation(foldedSegmentWidth / 2.0, lightedTex.height / 2.0, 0.0);
		right.x = (_container.width / 2.0) + foldedSegmentWidth;
	}
	
	public override function remove(view:FinishingView):void
	{
		view.removeElement(_container);
	}	
	
	public override function handleContainerResize(view:FinishingView):void
	{
		_container.x = (view.width - _container.width) / 2.0;
		_container.y = (view.height - _container.height) / 6.0;
	}
}
