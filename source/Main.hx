package;

import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.filters.ShaderFilter;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import shaders.FlashShader;

#if mac
@:bitmap("assets/macbackground.png")
class MacBackground extends BitmapData {}
#end

#if linux
@:bitmap("assets/linuxbackground.png")
class LinuxBackground extends BitmapData {}
#end

class Main extends Sprite
{
	public static var instance:Main;
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	//var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsVar:FPS;

	public static var macBackground:Bitmap;
	public static var linuxBackground:Bitmap;

	public var flashShader = new FlashShader();

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		instance = this;

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		//if (zoom == -1)
		//{
		//    var ratioX:Float = stageWidth / gameWidth;
		//    var ratioY:Float = stageHeight / gameHeight;
		//    zoom = Math.min(ratioX, ratioY);
		//    gameWidth = Math.ceil(stageWidth / zoom);
		//    gameHeight = Math.ceil(stageHeight / zoom);
		//}

		#if !debug
		//initialState = TitleState;
		#end

		#if mac
		macBackground = new Bitmap(new MacBackground(0, 0));
		macBackground.smoothing = true;
		macBackground.visible = false;
		addChild(macBackground);
		#end

		#if linux
		linuxBackground = new Bitmap(new LinuxBackground(0, 0));
		linuxBackground.smoothing = true;
		linuxBackground.visible = false;
		addChild(linuxBackground);
		#end

		ClientPrefs.loadDefaultKeys();
		// fuck you, persistent caching stays ON during sex
		FlxGraphic.defaultPersist = true;
		// the reason for this is we're going to be handling our own cache smartly
		addChild(new FlxGame(gameWidth, gameHeight, initialState, 1, framerate, framerate, skipSplash, startFullscreen));

		#if !mobile
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		fpsVar.visible = ClientPrefs.showFPS;
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		#end

		filters = [new ShaderFilter(flashShader)];

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		stage.addEventListener(Event.RESIZE, onResize);

		onResize();
	}

	function onResize(event:Event = null) {
		#if !windows
		var width = stage.stageWidth;
		var height = stage.stageHeight;

		var bgWidth = stage.stageWidth;
		var bgHeight = stage.stageHeight;

		var ratio:Float =  bgWidth  / bgHeight;

		bgHeight =  height;
		bgWidth =  Math.floor(height * ratio);

		trace(ratio, scaleY, bgWidth, bgHeight);
		var bg = 
			#if mac macBackground #end 
			#if linux linuxBackground #end 
			#if windows null /*how tf would this happen*/ #end;
		bg.width = bgWidth;
		bg.height = bgHeight;

		bg.x = 0.5 * (width - bg.width);
		bg.y = height - bg.height;
		#end
	}
}