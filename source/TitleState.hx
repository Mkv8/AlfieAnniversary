package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;
typedef TitleData =
{
	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var cdspin:FlxSprite;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var mustUpdate:Bool = false;

	var titleJSON:TitleData;

	public static var updateVersion:String = '';

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		Paths.currentLevel = null;

		#if MODS_ALLOWED
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		if (FileSystem.exists("modsList.txt")){
			var list:Array<String> = CoolUtil.listFromString(File.getContent("modsList.txt"));
			var foundTheTop = false;
			for (i in list){
				var dat = i.split("|");
				if (dat[1] == "1" && !foundTheTop){
					foundTheTop = true;
					Paths.currentModDirectory = dat[0];
				}

			}
		}
		#end

		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/gfDanceTitle.json";
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)) {
			path = "mods/images/gfDanceTitle.json";
		}
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)) {
			path = "assets/images/gfDanceTitle.json";
		}
		//trace(path, FileSystem.exists(path));
		titleJSON = Json.parse(File.getContent(path));
		#else
		var path = Paths.getPreloadPath("images/gfDanceTitle.json");
		titleJSON = Json.parse(Assets.getText(path));
		#end

		#if CHECK_FOR_UPDATES
		if(!closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];


		PlayerSettings.init();

		curWacky = getIntroText();

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		//initialized = false;
		//closedState = false;

		FlxG.save.bind('funkin', 'ninjamuffin99');

		/*if(!initialized && FlxG.save.data != null && FlxG.save.data.fullscreen)
		{
			FlxG.fullscreen = FlxG.save.data.fullscreen;
			//trace('LOADED FULLSCREEN SETTING!!');
		}*/

		ClientPrefs.loadPrefs();

		Highscore.load();

		FlxG.mouse.visible = false;

		if(FlxG.save.data.hasWatchedCredits == true) {
			LockManager.hasWatchedCredits = true;
		}


		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add(function(exitCode) {
				DiscordClient.shutdown();
			});
			#end
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				startIntro();
			});
		}
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;
	var megamix:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

				FlxG.sound.music.fadeIn(4, 0, 0.7);
			}
		}

		Conductor.changeBPM(titleJSON.bpm);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		bg.loadGraphic(Paths.image('bgg', 'preload'));
		//bg.screenCenter(XY);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var confetti:FlxBackdrop = new FlxBackdrop(Paths.image('confettititle'), 0.2, 0, true, true);
		confetti.velocity.set(20, 60);
		confetti.updateHitbox();
		//confetti.screenCenter(XY);
		confetti.alpha = 1;
		confetti.antialiasing = ClientPrefs.globalAntialiasing;
		add(confetti);

		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();

		cdspin = new FlxSprite(-400, -40);
		cdspin.loadGraphic(Paths.image('titleCD', 'preload'));
		cdspin.scale.set(0.9, 0.9);
		cdspin.antialiasing = ClientPrefs.globalAntialiasing;
		add(cdspin);

		megamix = new FlxSprite(355, 500);
		//megamix.loadGraphic(Paths.image('megamix', 'preload'));
		megamix.frames = Paths.getSparrowAtlas('megamix');
		megamix.animation.addByPrefix('bump', 'megamix', 24, false);
		megamix.animation.play('bump');
		megamix.scale.set(0.7, 0.7);
		megamix.antialiasing = ClientPrefs.globalAntialiasing;
		add(megamix);

		logoBl = new FlxSprite(565, 60);

		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/logoBumpin.png";
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "mods/images/logoBumpin.png";
		}
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "assets/images/logoBumpin.png";
		}
		//trace(path, FileSystem.exists(path));
		logoBl.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path),File.getContent(StringTools.replace(path,".png",".xml")));
		#else

		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		#end

		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		swagShader = new ColorSwap();
		/*gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);

		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/gfDanceTitle.png";
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "mods/images/gfDanceTitle.png";
		//trace(path, FileSystem.exists(path));
		}
		if (!FileSystem.exists(path)){
			path = "assets/images/gfDanceTitle.png";
		//trace(path, FileSystem.exists(path));
		}
		gfDance.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path),File.getContent(StringTools.replace(path,".png",".xml")));
		#else

		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		#end
			gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		//add(gfDance);
		gfDance.shader = swagShader.shader;*/
		logoBl.scale.set(0.90, 0.90);
		add(logoBl);
		logoBl.shader = swagShader.shader;

		titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/titleEnter.png";
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "mods/images/titleEnter.png";
		}
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "assets/images/titleEnter.png";
		}
		//trace(path, FileSystem.exists(path));
		titleText.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path),File.getContent(StringTools.replace(path,".png",".xml")));
		#else
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		#end
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter(X);
		//add(titleText);

		//var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		//logo.screenCenter();
		//logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSpriteExtra().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if(cdspin != null)
		{
			cdspin.angle += 2 * 60 * elapsed;
		}




		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		// EASTER EGG

		if (!transitioning && skippedIntro)
		{
			if(pressedEnter)
			{
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate) {
						MusicBeatState.switchState(new OutdatedState());
					} else {
						MusicBeatState.switchState(new MainMenuState());
					}
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	function getIntroText():Array<String>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		//var firstArray:Array<String> = ["Wow--you got the rarest screen--youre so lucky--i should reward you--lemme think of something--hmmmmm-- --oh sorry--am i wasting your time--my bad--wasnt my intention--just gotta--think of something cool--hmmmm-- --oh wait--I know--Ill just do this"];
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return FlxG.random.getObject(swagGoodArray);
	}

	function noop() {}

	function getIntroCommands() {
		var commands:Array<Void->Void> = [];

		commands[1] = () -> {
			#if PSYCH_WATERMARKS
			createCoolText(['Psych Engine by'], 15);
			#else
			createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			#end
		};

		commands[3] = () -> {
			#if PSYCH_WATERMARKS
			addMoreText('Shadow Mario', 15);
			addMoreText('RiverOaken', 15);
			addMoreText('bb-panzu', 15);
			#else
			addMoreText('present');
			#end
		};

		commands[4] = () -> {
			deleteCoolText();
		};


		commands[5] = () -> {
			#if PSYCH_WATERMARKS
			createCoolText(['Not associated', 'with'], -40);
			#else
			createCoolText(['In association', 'with'], -40);
			#end
		};

		commands[7] = () -> {
			addMoreText('newgrounds', -40);
			ngSpr.visible = true;
		};

		commands[8] = () -> {
			deleteCoolText();
			ngSpr.visible = false;
		};

		var idx = 9;

		for(i=>wacky in curWacky) {
			commands[idx] = () -> {
				deleteCoolText();
				createCoolText(curWacky.slice(Std.int(Math.max(0, i - 4)), i+1));
			};
			//idx += 2;
			idx += (curWacky.length > 5) ? 3 : 2;

		}

		if(curWacky.length == 2) {
			idx -= 1;
		}

		commands[idx++] = () -> {
			deleteCoolText();
		};
		commands[idx++] = () -> {
			addMoreText('FNF');
		};
		commands[idx++] = () -> {
			addMoreText('Vs Alfie');
		};
		commands[idx++] = () -> {
			addMoreText('Megamix');
		};
		commands[idx++] = () -> {
			skipIntro();
		};

		return commands;
	}

	var commands:Array<Void->Void> = null;

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null && megamix != null)
		{
			logoBl.animation.play('bump', true);
			megamix.animation.play('bump', true);
		}

		/*if(gfDance != null) {
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}*/

		if(!closedState) {
			if(commands == null) {
				commands = getIntroCommands();
			}

			sickBeats++;
			if(commands[sickBeats] != null) {
				commands[sickBeats]();
			}
		}
	}

	var skippedIntro:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
