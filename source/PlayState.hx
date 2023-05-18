package;

import lime.app.Application;
import shaders.MacNoteAlphaShader;
import flixel.util.FlxDestroyUtil;
import shaders.VCRShader;
import shaders.OldTVShader;
#if (linux || mac)
import shaders.OldTVShaderLinux;
#end
import shaders.TransparentHudShader;
import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import flixel.addons.display.FlxBackdrop;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.Shader;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.util.FlxSave;
#if ACHIEVEMENTS_ALLOWED
import Achievements;
#end
import StageData;
import FunkinLua;
import DialogueBoxPsych;
#if sys
import sys.FileSystem;
#end

import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxBitmapFont;

using StringTools;

enum PositionsType {
	DownScroll(middleScroll:Bool);
	UpScroll(middleScroll:Bool);
}

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var origWinX:Null<Float> = null;
	public static var origWinY:Null<Float> = null;
	public static var origWinWidth:Null<Float> = null;
	public static var origWinHeight:Null<Float> = null;
	public static var origWinFullScreen:Null<Bool> = null;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var functions:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var functions:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	public var modchartTexts:Map<String, ModchartText> = new Map();
	public var modchartSaves:Map<String, FlxSave> = new Map();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;
	public var noteSplashGloballyDisabled:Bool = false;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var ectSONGS:Array<SwagSong> = [];
	public static var bihNum = 0;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;
	public var frontChars:Array<Character> = [];

	public var notes:FlxTypedGroup<Note>;
	public var noteglow:FlxTypedGroup<NoteGlow>;
	public var allNotes:Array<Note> = [];
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];
	private var rateTween:FlxTween=null;
	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var comboLayer:FlxTypedGroup<FlxSprite>;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponent2Strums:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	private var curSong:String = "";
	public var formattedSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var ratingText:FlxBitmapText;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	public var isMinimizeBroken:Bool = false;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var casette:FlxSprite;
	var cassound:FlxSound;
	var deathsound:FlxSound;
	var playing:FlxSprite;
	var songtitle:FlxSprite;
	var darkenscreen:FlxSprite;

	// map stuff
	var town:BGSprite;
	var vignette:BGSprite;
	var redglow:BGSprite;
	var scanlines:BGSprite;
	var black:BGSprite;
	var blackOverlay:BGSprite;
	var oldstripes:BGSprite;
	var rainweak:FlxBackdrop;
	var rainsmall:FlxBackdrop;
	var remixadd:BGSprite;
	var remixThings:FlxBackdrop;
	var rainbig:FlxBackdrop;
	var darksparks:FlxBackdrop;
	var eyes:BGSprite;
	var circles:BGSprite;
	var blackbg:FlxSpriteExtra;


	var week1old:BGSprite;
	var week1:BGSprite;
	var mansionbg:BGSprite;
	var mansiontop:BGSprite;
	var flowers1:BGSprite;
	var flowers2:BGSprite;
	var flowers3:BGSprite;
	var flowers4:BGSprite;
	var sun:BGSprite;
	var bells:FlxBackdrop;

	var light1:BGSprite;
	var light2:BGSprite;
	var ballsowo:BGSprite;

	private var upperBlackBar:FlxSpriteExtra;
    private var bottomBlackBar:FlxSpriteExtra;

	var animemap:BGSprite;
	var animemultiply:BGSprite;
	var animeoverlay:BGSprite;
	var animeadd:BGSprite;
	var animevfx:BGSprite;
	var animesmoke:BGSprite;


	var bge:BGSprite;

	var candlebg:BGSprite;
	var candlelitpaintings:FlxSprite;
	//var hcandlebg:BGSprite;
	//var acandlebg:BGSprite;
	//var lcandlebg:BGSprite;
	//var ecandlebg:BGSprite;
	var brokencandlebg:BGSprite;
	var candleglow:BGSprite;
	var candledark:BGSprite;
	var candlespotlight:BGSprite;
	var candlebells:FlxBackdrop;
	var funkyassoverlay:BGSprite;
	var cshaders:Array<BitmapFilter> = [new ShaderFilter(new VCRShader())];

	var ourplebg:BGSprite;
	var ourplelight:BGSprite;
	var ourpletheory:BGSprite;
	var ourplelogo:BGSprite;

	var ourpleguy:Character;
	var phoneguy:Character;
	var markiplier:Character;
	var cryingchild:Character;

	var goatmultiply:BGSprite;
	var goatadd:BGSprite;
	var goatstage1:BGSprite;
	var goatstageblank:BGSprite;
	var goatstage3:BGSprite;
	var goatold:BGSprite;

	var monitors:BGSprite;

	var skabg:BGSprite;
	var skacrowd:BGSprite;
	var skagf:BGSprite;
	var skamultiply:BGSprite;
	var skaOverlay:BGSprite;
	var skaclock:BGSprite;
	var skafunky:BGSprite;

	var bkiss:BGSprite;
	var bkissmultiply:BGSprite;
	var bkissoverlay:BGSprite;
	var kissuhoh:BGSprite;
	var munchoverlay:BGSprite;

	var waterfall:BGSprite;
	var wateradd:BGSprite;
	var watermultiply:BGSprite;
	var wateroverlay:BGSprite;

	var pastabg:BGSprite;
	var pastaoverlay:BGSprite;
	var pastatable:BGSprite;
	var hemmiter:HeartEmmiter;

	public var grayscale = new shaders.Grayscale();
	public var grayscaleFilter:ShaderFilter;

	var fakeweek:BGSprite;
	var coming4u:BGSprite;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	public var tweeningZoom:Bool = false;

	// (neo) i coded in the list as you wanted :)
	public static var list = "1- make kisston's week (heart attack song) be locked until you play the other songs

	2- after kisston's week is unlocked and you press to play it, it sends you to a menu that gives you a small description for kisston  (see image). The assets for this menu are on shared/images

	3- make the crowd on skalloween bg, spooks and GOATED bop to the beat

	4- make the gf on the skalloween bg bop ot the beat if possible (since its a fake gf kinda)

	5- implement that shader that you wrote";

	//thanks neo thats exactly what i wanted <3


	var spritesToDestroy:Array<FlxBasic> = [];

	public var sectionMiddleScroll:Bool = false;
	public static var ratingPosition:PositionsType = null;
	public function setRatingPositionFromName(songName:String):Void
	{
		songName = songName.toLowerCase();
		var middleScroll:Bool = ClientPrefs.middleScroll;
		if(ClientPrefs.downScroll){
			ratingPosition = DownScroll(middleScroll);
		}
		else{
			ratingPosition = UpScroll(middleScroll);
		}
	}

	public function shake(sprite:FlxSprite, intensity:Float = 0.025){
		sprite.offset.x += FlxG.random.float(-intensity * sprite.width, intensity * sprite.width);
		sprite.offset.y += FlxG.random.float(-intensity * sprite.height, intensity * sprite.height);
	}

	public function setRatingPositions() {
		var high_position_y 	= 130;				//For upscroll
		var low_position_y 		= FlxG.height-180;	//For downscroll
		var middle_scroll_offset= -360; 		//Negative values for "left of center"

		ratingText.screenCenter(X);

		switch (ratingPosition) {
			case DownScroll(middleScroll):
				//trace('Downscroll; Middle:$middleScroll!');
				if (!middleScroll && !sectionMiddleScroll){
					ratingText.y = low_position_y;
				}
				else {
					ratingText.x += middle_scroll_offset;
					ratingText.y = high_position_y;
				}
			case UpScroll(middleScroll):
				//trace('Upscroll; Middle:$middleScroll!');
				if (!middleScroll && !sectionMiddleScroll){
					ratingText.y = high_position_y;
				}
				else {
					ratingText.x += middle_scroll_offset;
					ratingText.y = low_position_y;
				}

		}
	}

	override public function create()
	{
		grayscaleFilter = new ShaderFilter(grayscale);
		FunkinLua.hscript = null;
		Paths.clearStoredMemory();

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		#end

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		#if ACHIEVEMENTS_ALLOWED
		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}
		#end

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		//camGame.bgColor = FlxColor.fromRGB(2, 3, 5);

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		upperBlackBar = new FlxSpriteExtra(0, 0).makeSolid(FlxG.width, Math.floor(FlxG.height / 2), FlxColor.BLACK);
        upperBlackBar.y = 0 - upperBlackBar.height;
        upperBlackBar.active = false;
        bottomBlackBar = new FlxSpriteExtra(0, 0).makeSolid(FlxG.width, Math.floor(FlxG.height / 2), FlxColor.BLACK);
        bottomBlackBar.y = FlxG.height;// + bottomBlackBar.height;
        bottomBlackBar.active = false;

        upperBlackBar.cameras = [camHUD];
        bottomBlackBar.cameras = [camHUD];

        add(upperBlackBar);
        add(bottomBlackBar);

		Note.swagWidth = 160 * 0.7;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		if (SONG.song.contains("Pastanight") || SONG.song == "Pasta Night")//hardcoding cus i do noooooot give a fuckaroni
		{
			SONG.song = "Pasta Night";
			SONG.bpm = 130;
			SONG.speed = 2.05;
			SONG.stage = "pasta";
			Note.swagWidth = 160 * 0.7 * 0.9;
			switch(PlayState.bihNum)
			{
				case 0:
					SONG.player1 = "pkiss"; SONG.player2 = "pfilip"; SONG.gfVersion = "palfie";
				case 1:
					SONG.player2 = "pkiss"; SONG.player1 = "pfilip"; SONG.gfVersion = "palfie";
				case 2:
					SONG.player2 = "pkiss"; SONG.gfVersion = "pfilip"; SONG.player1 = "palfie";
			}
		}

		curSong = SONG.song;
		formattedSong = Paths.formatToSongPath(SONG.song);

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);


		vignette = new BGSprite('vignette', -2, -8, 1, 1);
		vignette.updateHitbox();
		vignette.cameras = [camHUD];
		vignette.screenCenter(XY);
		vignette.alpha = 0;

		if(formattedSong == 'after-dark') {
			if(!ClientPrefs.lowQuality) {
				redglow = new BGSprite('red glow', -2, -8, 1, 1);
				redglow.updateHitbox();
				redglow.cameras = [camHUD];
				redglow.screenCenter(XY);
				redglow.blend = SCREEN;
				redglow.alpha = 0;

				scanlines = new BGSprite('scanlines', -2, -8, 1, 1);
				scanlines.updateHitbox();
				scanlines.cameras = [camHUD];
				scanlines.screenCenter(XY);
				scanlines.setGraphicSize(FlxG.width, FlxG.height);
				scanlines.blend = OVERLAY;
				//scanlines.scale.set(2.5, 2.5);
				scanlines.alpha = 0;
			}


			darksparks = new FlxBackdrop(Paths.image('darksparks'), 0.2, 0, true, true);
			darksparks.velocity.set(25, -200);
			darksparks.updateHitbox();
			darksparks.screenCenter(XY);
			darksparks.antialiasing = ClientPrefs.globalAntialiasing;
			darksparks.alpha = 0;
		}

		if(formattedSong == 'candlelit-clash') {
			if(!ClientPrefs.lowQuality) {
				candledark = new BGSprite('candledark', 0, -280, 1, 1);
				candledark.updateHitbox();
				candledark.blend = MULTIPLY;
				candledark.scale.set(1.4, 1.4);
				candledark.alpha = 1;

				candleglow = new BGSprite('candleglow', 0, -280, 1, 1);
				candleglow.updateHitbox();
				candleglow.blend = ADD;
				candleglow.scale.set(1.4, 1.4);
				candleglow.alpha = 1;
			}

			candlespotlight = new BGSprite('candlespotlight', 0, -280, 1, 1);
			candlespotlight.updateHitbox();
			candlespotlight.scale.set(1.4, 1.4);
			candlespotlight.alpha = 1;

			if(!ClientPrefs.lowQuality) {
				funkyassoverlay = new BGSprite('FUNKY', 0, 0, 1, 1);
				funkyassoverlay.updateHitbox();
				funkyassoverlay.setGraphicSize(FlxG.width, FlxG.height);
				funkyassoverlay.cameras = [camOther];
				funkyassoverlay.screenCenter(XY);
				funkyassoverlay.alpha = 0;

				add(funkyassoverlay);
			}

		}

		if(formattedSong == 'forest-fire') {
			if(!ClientPrefs.lowQuality) {
				oldstripes = new BGSprite('oldtimeyeffect', -1, -1, 1, 1);
				oldstripes.updateHitbox();
				oldstripes.cameras = [camHUD];
				oldstripes.screenCenter(XY);
				oldstripes.alpha = 0;
			}
		}

		blackOverlay = new BGSprite('black', 1, 1, 1, 1);
		blackOverlay.scale.set(5.5, 5.5);
		blackOverlay.updateHitbox();
		blackOverlay.cameras = [camHUD];
		blackOverlay.screenCenter(XY);
		blackOverlay.alpha = 0;

		if(formattedSong == 'spectral-sonnet') {
			if(!ClientPrefs.lowQuality) {
				rainweak = new FlxBackdrop(Paths.image('smallestdrops'), 0.2, 0, true, true);
				rainweak.velocity.set(1500, 5000);
				rainweak.updateHitbox();
				rainweak.screenCenter(XY);
				rainweak.antialiasing = ClientPrefs.globalAntialiasing;
				rainweak.alpha = 0;

				rainsmall = new FlxBackdrop(Paths.image('smalldrops'), 0.2, 0, true, true);
				rainsmall.velocity.set(1200, 4000);
				rainsmall.updateHitbox();
				rainsmall.screenCenter(XY);
				rainsmall.antialiasing = ClientPrefs.globalAntialiasing;
				rainsmall.alpha = 0;

				rainbig = new FlxBackdrop(Paths.image('bigdrops'), 0.2, 0, true, true);
				rainbig.velocity.set(1000, 3000);
				rainbig.updateHitbox();
				rainbig.screenCenter(XY);
				rainbig.antialiasing = ClientPrefs.globalAntialiasing;
				rainbig.alpha = 0;

				remixadd = new BGSprite('remixadd', -830, -720, 1, 1);
				remixadd.alpha = 0;
				remixadd.blend = SCREEN;
				remixadd.scale.set(1.40, 1.40);

				remixThings = new FlxBackdrop(Paths.image('remixflyingstuff'), 0.2, 0, true, true);
				remixThings.x = -830;
				remixThings.y = -720;
				remixThings.velocity.set(0, -400);
				remixThings.updateHitbox();
				//remixThings.screenCenter(XY);
				remixThings.antialiasing = ClientPrefs.globalAntialiasing;
				remixThings.alpha = 0;
				remixThings.scale.set(1.40, 1.40);
			}

		}

		if(formattedSong == 'goated') {
			if(!ClientPrefs.lowQuality) {
				light1 = new BGSprite('light1', -1000, -500, 1, 1);
				light1.alpha = 0;
				light1.blend = SCREEN;
				//add(light1);

				light2 = new BGSprite('light2', -1000, -500, 1, 1);
				light2.alpha = 0;
				light2.blend = SCREEN;
				//add(light2);

				ballsowo = new BGSprite('balls', -1000, -500, 1, 1);
				ballsowo.alpha = 0.00001;
				//add(ballsowo);
			}
		}

		if(formattedSong == 'spooks') {
			if(!ClientPrefs.lowQuality) {
				animeadd = new BGSprite('add05', 1, 1, 1, 1);
				animeadd.alpha = 0.07;
				animeadd.blend = ADD;
				//add(animeadd);

				animemultiply = new BGSprite('multiply45', 1, 1, 1, 1);
				animemultiply.alpha = 0.45;
				animemultiply.blend = MULTIPLY;
				//add(animemultiply);

				animeoverlay = new BGSprite('overlay50', 1, 1, 1, 1);
				animeoverlay.alpha = 0.45;
				animeoverlay.blend = OVERLAY;
				//add(animeoverlay);

				animevfx = new BGSprite('animedots', 1, 1, 1, 1);
				animevfx.alpha = 0.0001;

				light1 = new BGSprite('animelight1', 1, 1, 1, 1);
				light1.alpha = 0.0001;
				light1.blend = OVERLAY;

				light2 = new BGSprite('animelight2', 1, 1, 1, 1);
				light2.alpha = 0.0001;
				light2.blend = ADD;

				animesmoke = new BGSprite('animesmoke', 1, 1, 1, 1);
				animesmoke.alpha = 0.0001;
			}

			scanlines = new BGSprite('scanlines2', 1, 1, 1, 1);
			scanlines.updateHitbox();
			scanlines.cameras = [camHUD];
			scanlines.screenCenter(XY);
			scanlines.blend = OVERLAY;
			scanlines.scale.set(1.8, 1.8);
			scanlines.alpha = 0;
		}
		if(formattedSong == 'goat-remake') {
			if (!ClientPrefs.lowQuality) {
				goatadd = new BGSprite('goatadd8', -1530, -720, 1, 1);
				goatadd.alpha = 0;
				goatadd.blend = ADD;
				//add(light1);

				goatmultiply = new BGSprite('goatmultiply53', -1530, -720, 1, 1);
				goatmultiply.alpha = 0;
				goatmultiply.blend = MULTIPLY;
				//add(light2);
			}

		}

		if(formattedSong == 'interrupted') {
			if(!ClientPrefs.lowQuality) {
				ourpletheory = new BGSprite('ourpletheory', 0, 0, 1, 1);
				ourpletheory.alpha = 0;
				ourplelogo = new BGSprite('ourplelogo', 0, 0, 1, 1);
				ourplelogo.alpha = 0;

				ourpletheory.antialiasing = false;
				ourplelogo.antialiasing = false;
				ourplelogo.setGraphicSize(FlxG.width, FlxG.height);
				ourpletheory.setGraphicSize(FlxG.width, FlxG.height);
				ourplelogo.screenCenter(XY);
				ourpletheory.screenCenter(XY);
				ourpletheory.cameras = [camHUD];
				ourplelogo.cameras = [camHUD];
			}

			scanlines = new BGSprite('scanline', -2, -8, 1, 1);
			scanlines.updateHitbox();
			scanlines.cameras = [camOther];
			scanlines.screenCenter(XY);
			scanlines.setGraphicSize(FlxG.width, FlxG.height);
			scanlines.blend = OVERLAY;
			//scanlines.scale.set(2.5, 2.5);
			scanlines.alpha = 1;

		}

		if(formattedSong == 'all-saints-scramble') {
			if (!ClientPrefs.lowQuality) {
				skaOverlay = new BGSprite('skaadd10', -600, -300, 1, 1);
				skaOverlay.updateHitbox();
				skaOverlay.alpha = 0.12;
				skaOverlay.blend = ADD;

				skamultiply = new BGSprite('skamultiply100', -600, -300, 1, 1);
				skamultiply.updateHitbox();
				skamultiply.alpha = 1;
				skamultiply.blend = MULTIPLY;
			}

			skaclock = new BGSprite('skaclock', 0, -420, 1, 1, ['clock'], false);
			skaclock.updateHitbox();
			skaclock.screenCenter(XY);
			skaclock.alpha = 0.0001;
			skaclock.animation.pause();
			skaclock.cameras = [camOther];
			skaclock.animation.curAnim.curFrame = 1;
			skaclock.scale.set(1, 1);

			camGame.setFilters([grayscaleFilter]);
			camHUD.setFilters([grayscaleFilter]);
			grayscale.apply = 0;

			if (!ClientPrefs.lowQuality) {
				skafunky = new BGSprite('skafunky', 0, 0, 1, 1);
				skafunky.updateHitbox();
				skafunky.setGraphicSize(FlxG.width, FlxG.height);
				skafunky.cameras = [camOther];
				skafunky.screenCenter(XY);
				skafunky.alpha = 0;
				add(skafunky);
			}
			blackOverlay.cameras = [camOther];

		}

		if(formattedSong == 'heart-attack') {
			if(!ClientPrefs.lowQuality) {
				bkissoverlay = new BGSprite('cupid/bkissOverlay47', -600, -300, 1, 1);
				bkissoverlay.updateHitbox();
				bkissoverlay.alpha = 0.30;
				bkissoverlay.blend = OVERLAY;

				bkissmultiply = new BGSprite('cupid/bkissMultiply100', -600, -300, 1, 1);
				bkissmultiply.updateHitbox();
				bkissmultiply.alpha = 1;
				bkissmultiply.blend = MULTIPLY;

				funkyassoverlay = new BGSprite('cupid/kissoverlay', 0, 0, 1, 1);
				funkyassoverlay.updateHitbox();
				funkyassoverlay.setGraphicSize(FlxG.width, FlxG.height);
				funkyassoverlay.cameras = [camHUD];
				funkyassoverlay.screenCenter(XY);
				funkyassoverlay.alpha = 0;
				funkyassoverlay.blend = ADD;

				munchoverlay = new BGSprite('cupid/munchoverlay', 0, 0, 1, 1);
				munchoverlay.updateHitbox();
				munchoverlay.setGraphicSize(FlxG.width, FlxG.height);
				munchoverlay.cameras = [camHUD];
				munchoverlay.screenCenter(XY);
				munchoverlay.alpha = 0;
				munchoverlay.blend = ADD;

				kissuhoh = new BGSprite('cupid/kissuhoh', 0, 0, 1, 1);
				kissuhoh.updateHitbox();
				kissuhoh.setGraphicSize(FlxG.width, FlxG.height);
				kissuhoh.cameras = [camHUD];
				kissuhoh.screenCenter(XY);
				kissuhoh.blend = MULTIPLY;
				kissuhoh.alpha = 0;

				skaclock = new BGSprite('transformationkisston', 0, 0, 1, 1, ['transition10', 'transition20'], false);
				skaclock.updateHitbox();
				skaclock.screenCenter(XY);
				skaclock.alpha = 0.0001;
				skaclock.animation.play('transition10');
				skaclock.animation.pause();
				skaclock.cameras = [camOther];
				skaclock.animation.curAnim.curFrame = 1;
				skaclock.scale.set(1.20, 1.20);
			}


		}

		if(formattedSong == 'jelly-jamboree') {

			if (!ClientPrefs.lowQuality) {
				wateradd = new BGSprite('kaikai/waterfalladd', -600, -300, 1, 1);
				wateradd.updateHitbox();
				wateradd.alpha = 0.0001;
				wateradd.blend = ADD;

				watermultiply = new BGSprite('kaikai/waterfallmultiply', -600, -300, 1, 1);
				watermultiply.updateHitbox();
				watermultiply.alpha = 1;
				watermultiply.blend = MULTIPLY;

				wateroverlay = new BGSprite('kaikai/waterfalloverlay', -600, -300, 1, 1);
				wateroverlay.updateHitbox();
				wateroverlay.alpha = 0.0001;
				wateroverlay.blend = SCREEN;

				wateradd.scale.set(1.15, 1.15);
				watermultiply.scale.set(1.15, 1.15);
				wateroverlay.scale.set(1.15, 1.15);
			}

			FlxG.game.setFilters(cshaders);
			FlxG.game.filtersEnabled = false;

			camGame.setFilters([grayscaleFilter]);
			camHUD.setFilters([grayscaleFilter]);
			grayscale.apply = 0;


			scanlines = new BGSprite('scanline', 1, 1, 1, 1);
			scanlines.updateHitbox();
			scanlines.cameras = [camHUD];
			scanlines.screenCenter(XY);
			scanlines.blend = OVERLAY;
			scanlines.scale.set(1.8, 1.8);
			scanlines.alpha = 0;
		}

		if(formattedSong == 'minimize')
		{
			if (!ClientPrefs.flashing) {
			coming4u = new BGSprite('comingNoFlash', 0, -420, 1, 1, ['comingblack'], false);
			} else {
			coming4u = new BGSprite('comingforyou', 0, -420, 1, 1, ['comingblack'], false);
			}

			coming4u.updateHitbox();
			//coming4u.setGraphicSize(FlxG.width, FlxG.height);
			coming4u.cameras = [camOther];
			coming4u.screenCenter(X);
			coming4u.alpha = 1;
			coming4u.x += 115;
			add(coming4u);
			coming4u.animation.pause();
			coming4u.animation.curAnim.curFrame = 1;

		}

		if(formattedSong == 'pasta-night') {
			pastaoverlay = new BGSprite('pasta/pastaoverlay', -960, 540, 1, 1);
			pastaoverlay.alpha = 0.5;
			pastaoverlay.scale.set(1.075, 1.075);

			pastaoverlay.blend = BlendMode.ADD;

			watermultiply = new BGSprite('pasta/pastaoverlay', -960, 540, 1, 1);
			watermultiply.alpha = 0.6;
			watermultiply.scale.set(1.075, 1.075);

			watermultiply.blend = BlendMode.MULTIPLY;

		}

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		setRatingPositionFromName(songName);

		curStage = PlayState.SONG.stage;
		//trace('stage is: ' + curStage);
		if(PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1) {
			switch (songName)
			{
				default:
					curStage = 'stage';
			}
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100]
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}

			case 'siivagunner':

				week1 = new BGSprite('week1', -1030, -580, 0.9, 0.9);
				week1.updateHitbox();
				week1.scale.set(1.10, 1.10);
				add(week1);

				deathsound = new FlxSound().loadEmbedded(Paths.sound("fnf_loss_sfx"));
				add(deathsound);

				black = new BGSprite('black', -2000, -800, 1, 1);
				black.scale.set(2, 2);
				black.updateHitbox();
				black.screenCenter(XY);
				add(black);
				black.alpha = 0;


			case 'erect':
				bge = new BGSprite('erectBG', -1000, -500, 1, 1, ['boppin'], false);
				bge.updateHitbox();
				add(bge);
				bge.antialiasing = true;

				black = new BGSprite('black', -1000, -500, 1, 1);
				black.scale.set(2.5, 2.5);
				black.updateHitbox();
				black.screenCenter(XY);
				add(black);
				black.alpha = 0;

			case 'hotline':
				var bgh:BGSprite = new BGSprite('HotlineBG', -600, -100, 1, 1);
				bgh.updateHitbox();
				bgh.antialiasing = true;
				bgh.scale.set(1.5, 1.5);
				add(bgh);


			case 'dark':
				var bg = new FlxSpriteExtra(-100, -100).makeSolid(FlxG.width * 3, FlxG.height * 3, 0xFF0A0808);
				bg.updateHitbox();
				bg.screenCenter(XY);
				add(bg);
				bg.antialiasing = true;

				eyes = new BGSprite('iSeeYou', 0, 0, 1, 1, ['eyes'], false);
				eyes.updateHitbox();
				eyes.screenCenter(XY);
				eyes.scale.set(1.05, 1.05);
				add(eyes);
				eyes.antialiasing = true;
				eyes.alpha = 0.00001;

				circles = new BGSprite('circles', 0, 0, 1, 1);
				circles.updateHitbox();
				circles.screenCenter(XY);
				circles.scale.set(1.05, 1.05);
				circles.alpha = 0.00001;
				add(circles);

				if (!ClientPrefs.lowQuality) {
					var shaders:Array<BitmapFilter> = [
						new ShaderFilter(new VCRShader()),
						#if !(mac || linux) new ShaderFilter(new OldTVShader()) #end
						#if (linux || mac) new ShaderFilter(new OldTVShaderLinux()) #end
					];

					//camHUD.setFilters(shaders);
					//camHUD.filtersEnabled = true;
					//camGame.setFilters(shaders);
					//camGame.filtersEnabled = true;
					//camOther.setFilters(shaders);
					//camOther.filtersEnabled = true;

					FlxG.game.setFilters(shaders);
					FlxG.game.filtersEnabled = true;
				}

			case 'shillton': //Forest Fire
				town = new BGSprite('bgold', -2000, -800, 1, 1);
				town.updateHitbox();
				add(town);

				black = new BGSprite('black', -2000, -800, 1, 1);
				black.scale.set(5.5, 5.5);
				black.updateHitbox();
				black.screenCenter(XY);
				add(black);
				black.alpha = 0;



			case 'candlelit': //candlelit clash

				candlebg = new BGSprite('candlebg', 0, -280, 1, 1);
				candlebg.updateHitbox();
				candlebg.scale.set(1.4, 1.4);
				add(candlebg);

				candlelitpaintings = new FlxSprite(0, -280);
				candlelitpaintings.frames = Paths.getSparrowAtlas("candlelitpaintings");
				candlelitpaintings.moves = false;
				candlelitpaintings.active = false;
				candlelitpaintings.animation.addByPrefix("acandlebg", "acandlebg", 0, false);
				candlelitpaintings.animation.addByPrefix("ecandlebg", "ecandlebg", 0, false);
				candlelitpaintings.animation.addByPrefix("hcandlebg", "hcandlebg", 0, false);
				candlelitpaintings.animation.addByPrefix("lcandlebg", "lcandlebg", 0, false);
				candlelitpaintings.alpha = 0.000001;
				candlelitpaintings.updateHitbox();
				candlelitpaintings.scale.set(1.4, 1.4);
				candlelitpaintings.antialiasing = candlebg.antialiasing;
				add(candlelitpaintings);

				if(!ClientPrefs.lowQuality) {
					brokencandlebg = new BGSprite('candlebgbroken', 0, -280, 1, 1);
					brokencandlebg.updateHitbox();
					brokencandlebg.scale.set(1.4, 1.4);
					add(brokencandlebg);
					brokencandlebg.alpha = 0.00001;

					black = new BGSprite('black', 0, 0, 1, 1);
					black.scale.set(3.5, 3.5);
					black.updateHitbox();
					black.screenCenter(XY);
					add(black);
					black.alpha = 0.00001;

					candlebells = new FlxBackdrop(Paths.image('bells'), 0.4, 0, true, false);
					candlebells.velocity.set(100, 0);
					candlebells.scale.set(1.4, 1.4);
					candlebells.updateHitbox();
					candlebells.antialiasing = ClientPrefs.globalAntialiasing;
					candlebells.x -= 0;
					candlebells.y -= 800;

					//bells.screenCenter();
					candlebells.alpha = 0.00001;
					add(candlebells);
				}


				if (!ClientPrefs.lowQuality) {
					FlxG.game.setFilters(cshaders);
					FlxG.game.filtersEnabled = false;
				}


			case 'mansiontop':

				mansionbg = new BGSprite('bgremix', -830, -720, 1, 1);
				mansiontop = new BGSprite('groundremix', -830, -720, 1, 1);
				mansionbg.scale.set(1.40, 1.40);
				mansiontop.scale.set(1.40, 1.40);

				flowers1 = new BGSprite('remixstuff1', -830, -720, 1, 1);
				flowers2 = new BGSprite('remixstuff2', -830, -720, 1, 1);
				flowers3 = new BGSprite('remixstuff3', -830, -720, 1, 1);
				flowers4 = new BGSprite('remixstuff4', -830, -720, 1, 1);
				flowers1.scale.set(1.40, 1.40);
				flowers2.scale.set(1.40, 1.40);
				flowers3.scale.set(1.40, 1.40);
				flowers4.scale.set(1.40, 1.40);
				flowers1.alpha = 0;
				flowers2.alpha = 0;
				flowers3.alpha = 0;
				flowers4.alpha = 0;

				add(mansionbg);
				add(mansiontop);
				add(flowers1);
				add(flowers2);
				add(flowers3);
				add(flowers4);

				blackbg = new FlxSpriteExtra(-1, -1).makeSolid(FlxG.width * 3, FlxG.height * 3, 0xFF0A0808);
				blackbg.updateHitbox();
				blackbg.screenCenter(XY);
				blackbg.blend = MULTIPLY;
				blackbg.alpha = 0;
				add(blackbg);
				blackbg.antialiasing = true;
				blackbg.scale.set(1.40, 1.40);


				week1old = new BGSprite('weekold', -1030, -580, 0.9, 0.9);
				week1old.scale.set(1.10, 1.10);
				week1old.alpha = 1;
				add(week1old);

				sun = new BGSprite('SunRemix', -830, -720, 1, 1);
				sun.scale.set(1.40, 1.40);
				sun.alpha = 0;
				add(sun);

				bells = new FlxBackdrop(Paths.image('bellthing'), 0.4, 0, true, true);
				bells.velocity.set(180, 0);
				bells.updateHitbox();
				bells.x -= 830;
				bells.y -= 720;
				bells.antialiasing = ClientPrefs.globalAntialiasing;
				bells.alpha = 0;
				add(bells);


			case '90s': //spooks
				animemap = new BGSprite('map90s', 1, 1, 1, 1, ['boppin'], false);
				animemap.updateHitbox();
				add(animemap);
				animemap.antialiasing = true;

				blackbg = new FlxSpriteExtra(-1, -1).makeSolid(FlxG.width * 3, FlxG.height * 3, 0xFF0A0808);
				blackbg.updateHitbox();
				blackbg.screenCenter(XY);
				blackbg.blend = MULTIPLY;
				blackbg.alpha = 0;
				add(blackbg);

				if (!ClientPrefs.lowQuality) {
					var shaders:Array<BitmapFilter> = [new ShaderFilter(new VCRShader())];

					FlxG.game.setFilters(shaders);
					FlxG.game.filtersEnabled = true;
				}

			case 'newstage': //goat remake
				goatstage1 = new BGSprite('stage1', -1530, -720, 1, 1);
				goatstageblank = new BGSprite('stage2blank', -1530, -720, 1, 1);

				monitors = new BGSprite('monitors', -985, -505, 1, 1, ["ace", "filip", "sarvente", "tankman", "senapi", "parents", "zardy", "whitty"], false);
				monitors.animation.play('tankman', true);
				monitors.visible = false;

				goatstage3 = new BGSprite('stage3', -1530, -720, 1, 1);
				goatold = new BGSprite('stageold', -1530, -720, 1, 1);

				add(goatstage1);
				add(goatstageblank);

				add(monitors);

				add(goatstage3);
				add(goatold);


			case 'ourple': //interrupted
				ourplebg = new BGSprite('ourplebgmap', -830, -720, 1, 1);
				ourplelight = new BGSprite('ourplelight', -830, -720, 1, 1);
				ourplebg.antialiasing = false;
				ourplelight.antialiasing = false;
				ourplebg.alpha = 0.00001;
				add(ourplebg);
				add(ourplelight);
				ourplebg.scale.set(1.10, 1.10);
				ourplelight.scale.set(1.10, 1.10);

			case 'skalloween': //all saints
				skabg = new BGSprite('skabbg', -600, -300, 1, 1);
				skagf = new BGSprite('skagf', 800, 200, 1, 1, ['GF Dancing Beat0'], false);
				skacrowd = new BGSprite('skacrowdbop', -590, 875, 1, 1, ['skacrowdbop0'], false);


				add(skabg);
				add(skagf);
			case 'kpark': //heart attack
				bkiss = new BGSprite('cupid/bkiss', -600, -300, 1, 1);

				add(bkiss);

			case 'waterfall':
				waterfall = new BGSprite('kaikai/waterfall', -600, -300, 1, 1);
				waterfall.scale.set(1.15, 1.15);
				add(waterfall);

			case 'fake':
				fakeweek = new BGSprite('fakeweek', -600, -300, 1, 1);
				fakeweek.scale.set(1.10, 1.10);
				add(fakeweek);

				#if mac
				Main.macBackground.visible = false;
				#end

			case 'pasta':
				pastabg = new BGSprite('pasta/pastaground', -960, 540, 1, 1, ['pastabg0'], false);
				pastabg.scale.set(1.075, 1.075);
				add(pastabg);

				pastatable = new BGSprite('pasta/table', -960, 1400, 1, 1);
				pastatable.scale.set(1.075, 1.075);

		}
		add(gfGroup);
		add(dadGroup);
		add(boyfriendGroup);
		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		if(curStage == '90s') {
			if (!ClientPrefs.lowQuality) {
				add(animemultiply);
				add(animeadd);
				add(animeoverlay);
				add(animevfx);
				add(light1);
				add(light2);
				add(animesmoke);
			}
			add(scanlines);
			scanlines.alpha = 0.15;
			add(blackOverlay);
		}
		if(curStage == 'newstage') {
			if (!ClientPrefs.lowQuality) {
				add(goatmultiply);
				add(goatadd);
			}
			dadGroup.alpha = 0;
		}

		if(curStage == 'ourple') {
			add(blackOverlay);
			blackOverlay.alpha = 1;
			if (!ClientPrefs.lowQuality) {
				add(ourpletheory);
				add(ourplelogo);
			}
			add(scanlines);
			scanlines.alpha = 0.5;
			boyfriendGroup.alpha = 0.0001;

		}

		if(curStage == 'skalloween') {
			if (!ClientPrefs.lowQuality) {
				add(skamultiply);
				add(skaOverlay);
			}
			add(skacrowd);
			add(vignette);
			add(blackOverlay);
			add(skaclock);
			blackOverlay.alpha = 1;
		}

		if(curStage == 'kpark') {
			if (!ClientPrefs.lowQuality) {
				add(bkissmultiply);
				add(bkissoverlay);
				add(kissuhoh);
			}
			add(blackOverlay);
			blackOverlay.cameras = [camOther];
			if (!ClientPrefs.lowQuality) {
				add(skaclock);
			}
		}

		if(curStage == 'waterfall') {
			if (!ClientPrefs.lowQuality) {
				add(watermultiply);
				add(wateradd);
				add(wateroverlay);
			}
			add(blackOverlay);
			add(scanlines);
			scanlines.alpha = 0.12;
			blackOverlay.alpha = 1;
		}
		if(curStage == 'fake') {
			add(blackOverlay);
		}
		if(curStage == 'pasta') {
			add(pastatable);
		}

		if(curStage == 'dark') {
			black = new BGSprite('black', 0, 0, 1, 1);
			black.scale.set(2.5, 2.5);
			add(black);



		}
		if(curStage == 'hotline') {
		black = new BGSprite('black', 0, 0, 1, 1);
		black.scale.set(2.5, 2.5);
		add(black);

		}

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end


		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		callOnLuas('onCreate', []);


		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		gf = new Character(0, 0, gfVersion);
		startCharacterPos(gf);
		gf.scrollFactor.set(0.95, 0.95);
		gfGroup.add(gf);
		startCharacterLua(gf.curCharacter);

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.x += gf.cameraPosition[0];
		camPos.y += gf.cameraPosition[1];

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			gf.visible = false;
		}

		switch(curStage)
		{
			case 'newstage':
				boyfriend.color = 0xFF000000;
				gf.color = 0xFF000000;
			case "pasta":
				boyfriend.flipX = false; dad.flipX = false; gf.flipX = false;
				gf.scrollFactor.set(1, 1);
				gfSpeed = 2;
				switch(PlayState.bihNum)
				{
					case 0:
						boyfriend.setPosition(-927 ,939); dad.setPosition(-297, 916); gf.setPosition(433, 996);
						boyfriend.healthIcon = "icon-kisstonpasta"; dad.healthIcon = "icon-alfiefilippasta";
						boyfriend.healthColorArray= [246,221,201]; dad.healthColorArray= [234,145,58];
					case 1:
						dad.setPosition(-927 ,939); boyfriend.setPosition(-297, 916); gf.setPosition(433, 996);
						sectionMiddleScroll = true; // lol
						boyfriend.healthIcon = "icon-filippasta"; dad.healthIcon = "icon-alfiekisspasta";
						boyfriend.healthColorArray= [255,205,1]; dad.healthColorArray= [255,169,166];
					case 2:
						dad.setPosition(-927 ,939); gf.setPosition(-297, 916); boyfriend.setPosition(433, 996);
						boyfriend.healthIcon = "icon-alfiepasta"; dad.healthIcon = "icon-filipkisspasta";
						boyfriend.healthColorArray= [179,32,61]; dad.healthColorArray= [255,197,146];
				}
				var chars= ["pkissF","palfieF"];

				for (i in 0...2)
				{
					var char = new Character(0, 0, chars[i]);
					char.copying = true;
					add(char);
					frontChars.push(char);
				}

			bells = new FlxBackdrop(Paths.image('pausebells2'), 0.2, 0, true, true);
			bells.velocity.set(240, 100);
			bells.updateHitbox();
			bells.screenCenter(XY);
			bells.antialiasing = ClientPrefs.globalAntialiasing;
			bells.alpha = 0.0;
			bells.cameras = [camHUD];
			add(bells);
		}

		if(curStage == 'pasta') {
			add(pastaoverlay);
			add(watermultiply);
			add(blackOverlay);
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');

		if (SONG.song == 'mansion-match')
		{
			timeTxt = new FlxFixedText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
			timeTxt.setFormat(Paths.font("porque.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			timeTxt.scrollFactor.set();
			timeTxt.alpha = 0;
			timeTxt.borderSize = 2;
			timeTxt.visible = showTime;
			timeTxt.scale.set(0.8, 0.8);
		}
		else
		{
			timeTxt = new FlxFixedText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
			timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			timeTxt.scrollFactor.set();
			timeTxt.alpha = 0;
			timeTxt.borderSize = 2;
			timeTxt.visible = showTime;
		}
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800000; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		comboLayer = new FlxTypedGroup<FlxSprite>();
		comboLayer.cameras = [camHUD];
		add(comboLayer);


		ratingText = new FlxBitmapText(
			FlxBitmapFont.fromAngelCode(
				Paths.image('font/menuOutline_B'),
				Paths.getTextFromFile("images/font/menuOutline.fnt")
			)
		);
		ratingText.pixelPerfectRender = true;
    	ratingText.letterSpacing = 0;

		setRatingPositions();
		ratingText.updateHitbox();
		ratingText.scale.set(0.6,0.6);
		comboLayer.add(ratingText);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		opponent2Strums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		healthBar.numDivisions = 800000;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();
		if (formattedSong == 'goat-remake')
		{
			iconP2.alpha = 0;
			healthBar.color = 0xFF000000;
			healthBar.alpha = ClientPrefs.healthBarAlpha;
			iconP1.color = 0xFF000000;
			iconP1.alpha = ClientPrefs.healthBarAlpha;
		}

		if (formattedSong == 'interrupted')
		{
			iconP2.alpha = 0;
			iconP1.alpha = 0;
			healthBar.alpha = 0;

		}

		if (formattedSong == 'spectral-sonnet-beta')
		{

		}

		if (formattedSong == 'minimize' && curStage == 'fake')
		{
			iconP2.alpha = 0;
			iconP1.alpha = 0;
			healthBar.alpha = 0;
			camHUD.alpha = 0.00001;
			dad.alpha = 0.00001;
		}

		if (formattedSong == 'after-dark' && curStage == 'dark')
		{
			camHUD.alpha = 0.00001;
		}

		if (formattedSong == 'mansion-match')
		{
			scoreTxt = new FlxFixedText(0, healthBarBG.y + 36, FlxG.width, "", 20);
			scoreTxt.setFormat(Paths.font("porque.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.scrollFactor.set();
			scoreTxt.borderSize = 1.25;
			scoreTxt.visible = !ClientPrefs.hideHud;
			scoreTxt.scale.set(0.8, 0.8);
		}
		else
		{
			scoreTxt = new FlxFixedText(0, healthBarBG.y + 36, FlxG.width, "", 20);
			scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.scrollFactor.set();
			scoreTxt.borderSize = 1.25;
			scoreTxt.visible = !ClientPrefs.hideHud;
		}

		add(scoreTxt);

		if (formattedSong == 'mansion-match')
		{
		botplayTxt = new FlxFixedText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("porque.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		botplayTxt.scale.set(0.8, 0.8);
		}

		else
		{
		botplayTxt = new FlxFixedText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		}

		add(botplayTxt);

		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		noteglow.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		startingSong = true;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		var daSong:String = Paths.formatToSongPath(curSong);

		var data = new Map<String, Array<String>>();

		data.set("bopeebo", ["NowPOld", "ForestTitle"]);
		data.set("forest-fire", ["NowPOld", "ForestTitle"]);
		data.set("spectral-sonnet", ["NowP", "Sremititle"]);
		data.set("spectral-sonnet-beta", ["NowP", "Siivatitle"]);
		data.set("goated", ["NowP", "GOATED"]);
		data.set("after-dark", ["NowPdark", "AFTER DARK"]);
		data.set("mansion-match", ["NowPhotline", "hotlinetitle"]);
		data.set("candlelit-clash", ["NowP", "CandleTitle"]);
		data.set("goat-remake", ["NowP", "GoatTitle"]);
		data.set("interrupted", ["NowPdark", "ourpletitle"]);
		data.set("all-saints-scramble", ["NowP", "skatitle"]);
		data.set("spooks", ["NowP90s", "90stitle"]);
		data.set("heart-attack", ["NowP", "ktitle"]);
		data.set("jelly-jamboree", ["NowP", "kaititle"]);
		data.set("minimize", ["NowP", "minustitle"]);
		data.set("pasta-night", ["NowP", "pastatitle"]);


		var shouldShowCassette:Bool = false;

		if (isStoryMode && !seenCutscene)
		{
			shouldShowCassette = true;

			switch (daSong)
			{

				/*default:
					startCountdown();*/
			}
			seenCutscene = true;
		}
		else if (!isStoryMode)
		{
			shouldShowCassette = true;
		}
		else
		{
			startCountdown();
		}

		if(shouldShowCassette && data.exists(daSong)) {
			var casData = data.get(daSong);

			darkenscreen = new FlxSpriteExtra(-FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom).makeSolid(FlxG.width * 3, FlxG.height * 3, 0xFF000000);
			darkenscreen.alpha = 0.4;
			darkenscreen.scrollFactor.set();
			//darkenscreen.scale.set(1.20, 1.20);
			add(darkenscreen);

			cassound = new FlxSound().loadEmbedded(Paths.sound("CasAudio"));
			casette = new FlxSprite(-700, 200);
			casette.frames = Paths.getSparrowAtlas('casette', 'shared');
			casette.animation.addByPrefix('play', "CasettePlay0", 40, false);
			//casette.animation.play('play');
			casette.scrollFactor.set(1, 1);
			casette.scale.set(0.55, 0.55);
			casette.cameras = [camOther];
			casette.antialiasing = ClientPrefs.globalAntialiasing;

			playing = new FlxSprite(500, 200);
			playing.loadGraphic(Paths.image(casData[0], 'shared'));
			playing.scrollFactor.set(1, 1);
			playing.active = false;
			playing.scale.set(0.85, 0.85);
			playing.cameras = [camOther];
			playing.alpha = 0;
			playing.antialiasing = ClientPrefs.globalAntialiasing;

			songtitle = new FlxSprite(500, 200);
			songtitle.loadGraphic(Paths.image(casData[1], 'shared'));
			songtitle.scrollFactor.set(1, 1);
			songtitle.active = false;
			songtitle.scale.set(0.85, 0.85);
			songtitle.cameras = [camOther];
			songtitle.alpha = 0;
			songtitle.antialiasing = ClientPrefs.globalAntialiasing;

			add(playing);
			add(songtitle);
			add(cassound);
			add(casette);

			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				casette.animation.play('play');
				cassound.play(true);
			});

			new FlxTimer().start(1.7, function(tmr:FlxTimer)
			{
				playing.alpha = 1;
			});

			new FlxTimer().start(2.3, function(tmr:FlxTimer)
			{
				songtitle.alpha = 1;
			});

			new FlxTimer().start(4.5, function(tmr:FlxTimer)
			{
				FlxTween.tween(casette, {alpha: 0}, 0.5);
				FlxTween.tween(playing, {alpha: 0}, 0.5);
				FlxTween.tween(songtitle, {alpha: 0}, 0.5);
				FlxTween.tween(darkenscreen, {alpha: 0}, 0.5);

			});


			new FlxTimer().start(5, function(tmr:FlxTimer)
			{
				startCountdown(); trace('this should wait a bit');
				remove(casette);
				remove(playing);
				remove(songtitle);
				remove(cassound);
			});
		} else {
			startCountdown();
		}

		/*if (daSong == 'after-dark')
		{
			black = new BGSprite('black', 0, 0, 1, 1);
			black.scale.set(2.5, 2.5);
			add(black);
		}*/

		/*if (daSong == 'mansion-match')
		{
			black = new BGSprite('black', 0, 0, 1, 1);
			black.scale.set(2.5, 2.5);
			add(black);
			new FlxTimer().start(7, function(tmr:FlxTimer)
			{
				remove(black, true);
				black.destroy();
			});
		}*/

		if (daSong == 'candlelit-clash')
		{
			if(!ClientPrefs.lowQuality) {
				add(candledark);
				add(candleglow);
			}
			dad.alpha = 0.000001;
		}

		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');
		CoolUtil.precacheMusic('breakfast');

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter().replace("icon-", ""));
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;
		callOnLuas('onCreatePost', []);
		callOnLuas('setUpdate', []);
		callOnLuas('setUpdatePost', []);
		function reorderCharacters(input:Array<Character>){
			for(character in input){
				if(character!=null){
					var t = character.getPosition();
					dadGroup.remove(character, true);
					dadGroup.add(character);
					character.setPosition(t.x,t.y);
					t.put();
				}
			}

		}

		ourpleguy = dadMap.get("guy");
		phoneguy = dadMap.get("phone");
		markiplier = dadMap.get("ourplemark");
		cryingchild = dadMap.get("crying");
		if(formattedSong == 'interrupted'){
			//trace(formattedSong);
			reorderCharacters([markiplier,phoneguy,ourpleguy,cryingchild]);
		}

		super.create();

		Paths.clearUnusedMemory();
		CustomFadeTransition.nextCamera = camOther;
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes)
			{
				if(note.isSustainNote && !note.isHoldEnd)
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if(note.isSustainNote && !note.isHoldEnd)
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function addTextToDebug(text:String, ?color:FlxColor = FlxColor.WHITE) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors() {

		if(formattedSong == "spectral-sonnet-beta") {return;}

		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(!gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush)
		{
			for (lua in luaArray)
			{
				if(lua.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName))
			#else
			if(OpenFlAssets.exists(fileName))
			#end
			{
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSpriteExtra(-FlxG.width, -FlxG.height).makeSolid(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
				startAndEnd();
			}
			return;
		}
		else
		{
			FlxG.log.warn('Couldnt find video file: ' + fileName);
			startAndEnd();
		}
		#end
		startAndEnd();
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			generateStaticArrows(0, formattedSong == "after-dark");
			generateStaticArrows(1, formattedSong == "after-dark");

			if(formattedSong == 'pasta-night')
			{
				generateStaticArrows(2, formattedSong == "after-dark");
				hemmiter = new HeartEmmiter(playerStrums.members[2].x,
				playerStrums.members[0].y);
				hemmiter.cameras = [camHUD];
				add(hemmiter);
			}

			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', 'set', 'go']);
			introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var antialias:Bool = ClientPrefs.globalAntialiasing;
			if(isPixelStage) {
				introAlts = introAssets.get('pixel');
				antialias = false;
			}

			var swagCounter:Int = 0;

			if (skipCountdown) {
				Conductor.songPosition = 0;
				Conductor.songPosition -= Conductor.crochet ;
				swagCounter = 3;
			}
			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (tmr.loopsLeft % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
				{
					gf.dance();
				}
				if(tmr.loopsLeft % 2 == 0) {
					if (boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing'))
					{
						boyfriend.dance();
					}
					if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
					{
						dad.dance();
					}
				}
				else if(dad.danceIdle && dad.animation.curAnim != null && !dad.stunned && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing"))
				{
					dad.dance();
				}

				// head bopping for bg characters on Mall

				/*if(curStage == '90s') {
					animemap.dance(true);}*/

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						add(countdownReady);
						FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						add(countdownSet);
						FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3:
						if (!skipCountdown){
						countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						add(countdownGo);
						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						}
				}

				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = note.multAlpha;
					if(ClientPrefs.middleScroll && !note.mustPress) {
						note.alpha *= 0.5;
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter().replace("icon-", ""), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);

		if(curStage == 'hotline') {
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				remove(black, true);
				black.destroy();
			});
		}
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		Conductor.changeBPM(SONG.bpm);

		curSong = SONG.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		noteglow = new FlxTypedGroup<NoteGlow>();
		add(noteglow);

		notes = new FlxTypedGroup<Note>();
		notes.active = false;
		add(notes);

		loadNotes(SONG.notes,"default");
		if(formattedSong == 'pasta-night')
		{
			loadNotes(ectSONGS[0].notes,"opp");
			loadNotes(ectSONGS[1].notes,"opp2");
		}

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file))
		#else
		if (OpenFlAssets.exists(file))
		#end
		{
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (event in SONG.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function loadNotes(noteData:Array<SwagSection>, hitSection:String) {
		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Null<Bool> = section.mustHitSection;
				var thirdGottaHit = false;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				switch(hitSection)
				{
					case "opp":
						gottaHitNote = false;
					case "opp2":
						gottaHitNote = false;
						thirdGottaHit = true;
				}

				var oldNote:Note = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.mustPressByThird = thirdGottaHit;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				oldNote = swagNote;

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				allNotes.push(swagNote);

				if (swagNote.notData != -1 && swagNote.mustPress)
				{
					var noteg:NoteGlow = new NoteGlow(swagNote);
					noteglow.add(noteg);
				}

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.mustPressByThird = thirdGottaHit;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);
						allNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}

						oldNote = sustainNote;
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				noteTypeMap.set(swagNote.noteType, true);
			}
		}
		unspawnNotes.sort(sortByShit);
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
		}

		eventPushedMap.set(event.event, true);
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			//case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
			//	return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int, afterDarkSpot:Bool = false):Void
	{
		var targetAlpha:Float = 1;
		if ((player == 0 || player == 2) && ClientPrefs.middleScroll) targetAlpha = 0.35;

		if(afterDarkSpot && (player == 0)) {
			targetAlpha = 0.1;
		}
		if(afterDarkSpot && (player == 1)) {
			targetAlpha = 1;
		}

		var middleScroll = afterDarkSpot || ClientPrefs.middleScroll;

		for (i in 0...4)
		{
			var babyArrow:StrumNote = new StrumNote(middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !afterDarkSpot)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1) {
				playerStrums.add(babyArrow);
			} else if (player == 0){
				opponentStrums.add(babyArrow);
			} else if (player == 2)
				opponent2Strums.add(babyArrow);

			if(player == 0 || afterDarkSpot || player == 2) {
				if(middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				else if ((player == 0 || player == 2) && curStage == "pasta")
					babyArrow.alpha = 0.35;
			}

			strumLineNotes.add(babyArrow);
			if(afterDarkSpot) babyArrow.player = 0;
			babyArrow.postAddedToGroup();
			if(afterDarkSpot) babyArrow.player = player;

		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if(formattedSong == 'pasta-night')
			{
				if (hemmiter.timer != null && !hemmiter.timer.finished)
					hemmiter.timer.active = false;
			}
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if(formattedSong == 'pasta-night')
			{
				if (hemmiter.timer != null && !hemmiter.timer.finished)
					hemmiter.timer.active = true;
			}
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = true;
				}
			}

			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter().replace("icon-", ""), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter().replace("icon-", ""));
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter().replace("icon-", ""), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter().replace("icon-", ""));
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter().replace("icon-", ""));
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null || freeze) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;


	public static var maxLuaFPS = 30;
	var fpsElapsed:Array<Float> = [0,0,0];
	var numCalls:Array<Float> = [0,0,0];
	var setUpdater:Float->Void = null;
	var setUpdaterPost:Float->Void = null;
	var freeze = false;
	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/
		// (whatify) Workaround for luajit memory leak at higher fps
		// (neo) this is bad :(

		/*var object = boyfriend;
		if (FlxG.keys.pressed.A) {object.x --;}
        if (FlxG.keys.pressed.D){object.x ++;}
        if (FlxG.keys.pressed.S){object.y ++;}
        if (FlxG.keys.pressed.W){object.y--;}
		if (FlxG.keys.justPressed.SPACE){trace(object);}*/

		if(ClientPrefs.capLua60fps) {
			if(ClientPrefs.framerate <= maxLuaFPS){

				callOnLuas('onUpdate', [elapsed]);
			}
			else {
				numCalls[0]+=1;
				fpsElapsed[0]+=elapsed;
				if(numCalls[0] >= Std.int(ClientPrefs.framerate/maxLuaFPS)){
					//trace("New Update");
					callOnLuas('onUpdate', [fpsElapsed[0]]);
					fpsElapsed[0]=0;
					numCalls[0]=0;
				}
			}
		} else {
			callOnLuas('onUpdate', [elapsed]);
		}
		if(setUpdater!=null){
			setUpdater(elapsed);
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			#if ACHIEVEMENTS_ALLOWED
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
			#end
		}

		if (formattedSong == "pasta-night")
		{
			switch(PlayState.bihNum)
			{
				case 0:
					frontChars[0].copyChar(boyfriend); frontChars[1].copyChar(gf);
				case 1:
					frontChars[0].copyChar(dad); frontChars[1].copyChar(gf);
				case 2:
					frontChars[0].copyChar(dad); frontChars[1].copyChar(boyfriend);
			}
		}


		super.update(elapsed);

		if(ratingName == '?') {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName;
		} else {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
		}

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				if(FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					vocals.pause();
				}
				openSubState(new PauseSubState());

				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter().replace("icon-", ""));
				#end
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		var lerpVal = CoolUtil.boundTo(1 - (elapsed * 9), 0, 1);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, lerpVal);
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, lerpVal);
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		if (health > 2)
			health = 2;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (!freeze)
		{
			if (startingSong)
			{
				if (startedCountdown)
				{
					Conductor.songPosition += elapsed * 1000;
					if (Conductor.songPosition >= 0)
						startSong();
				}
			}
			else
			{
				Conductor.songPosition += elapsed * 1000;

				if (!paused)
				{
					if(updateTime) {
						var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
						if(curTime < 0) curTime = 0;
						songPercent = (curTime / songLength);

						var songCalc:Float = (songLength - curTime);
						if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

						var secondsTotal:Int = Math.floor(songCalc / 1000);
						if(secondsTotal < 0) secondsTotal = 0;

						if(ClientPrefs.timeBarType != 'Song Name')
							timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
					}
				}

				// Conductor.lastSongPos = FlxG.sound.music.time;
			}
		}


		if (camZooming)
		{
			var lerpVal = CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1);
			if(!tweeningZoom) {
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, lerpVal);
			}
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, lerpVal);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000;//shit be werid on 4:3
			if(songSpeed < 1) time /= songSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.update(elapsed);

			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if(!daNote.mustPress) strumGroup = opponentStrums;
				if(daNote.mustPressByThird) strumGroup = opponent2Strums;

				var strum = strumGroup.members[daNote.noteData];

				var strumX:Float = strum.x;
				var strumY:Float = strum.y;
				var strumAngle:Float = strum.angle;
				var strumDirection:Float = strum.direction;
				var strumAlpha:Float = strum.alpha;
				var strumScroll:Bool = strum.downScroll;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if (strumScroll) //Downscroll
				{
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}
				else //Upscroll
				{
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if(daNote.copyAlpha)
					daNote.alpha = strumAlpha;

				if(daNote.mustPress)
				{
				    if (daNote.copyX && !alfiefucking)
						daNote.x = strumX + Math.cos(angleDir) * daNote.distance;
				}
				else
				{
					if (daNote.copyX)
						daNote.x = strumX + Math.cos(angleDir) * daNote.distance;
				}

				if (daNote.mustPress && daNote.notData != -1 && Math.abs(daNote.distance) < 500)
					daNote.move(playerStrums.members[daNote.noteData].x);

				if(daNote.copyY)
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
					if(strumScroll && daNote.isSustainNote)
					{
						if (daNote.isHoldEnd) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
							if(PlayState.isPixelStage) {
								daNote.y += 8;
							} else {
								daNote.y -= 19;
							}
						}
						daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					opponentNoteHit(daNote);
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit)) {
						goodNoteHit(daNote);
					}
				}

				if(daNote.isSustainNote) {
					daNote.flipY = strumScroll;
				}

				var center:Float = strumY + Note.swagWidth / 2;
				if(strum.sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
					(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (strumScroll)
					{
						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					destroyNote(daNote);
				}
			});
		}
		checkEventNote();

		if (!inCutscene) {
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
			}
		}

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}

			if(FlxG.keys.justPressed.THREE)
			{
				freeze = !freeze;
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (freeze)
				health = 2;

			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime + 800 < Conductor.songPosition) {
						destroyNote(daNote);
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime + 800 >= Conductor.songPosition) {
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);


		if(ClientPrefs.capLua60fps) {
			//Workaround for luajit memory leak at higher fps
			if(ClientPrefs.framerate <= maxLuaFPS){
				callOnLuas('onUpdatePost', [elapsed]);
			}
			else {
			numCalls[1]+=1;
			fpsElapsed[1]+=elapsed;
			if(numCalls[1] >= Std.int(ClientPrefs.framerate/maxLuaFPS)){
				//trace("New UpdatePost");
				callOnLuas('onUpdatePost', [fpsElapsed[1]]);
				fpsElapsed[1]=0;
				numCalls[1]=0;
			}
			}
		} else {
			callOnLuas('onUpdatePost', [elapsed]);
		}

		if(setUpdaterPost!=null){
			setUpdaterPost(elapsed);
		}
		updateHealthGraphics();

		if(ratingText.visible && ratingText.alpha > 0) {
			ratingText.centerOffsets();
			if (ratingText.color == 0xFF391F16){
				shake(ratingText);
			}
		}

		switch (curStage)
		{
			case "pasta":
				snapCamFollowToPos(pastabg.x + pastabg.width/2, pastabg.y + pastabg.height/2);
		}
	}

	var iconOffset:Int = 26;

	function updateHealthGraphics()
	{
		if (health > 2)
			health = 2;

		var percent:Float = 1 - (health / 2);

		var remappedHealth:Float = healthBar.x + (healthBar.width * (percent));

		iconP1.x = remappedHealth + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = remappedHealth - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;
	}

	function destroyNote(note:Note) {
		//note.active = false;
		//note.visible = false;

		note.kill();
		notes.remove(note, true);
		//notesToDestroy.push(note);
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				var owo = new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1]);
				owo.cameras = [camOther];
				openSubState(owo);
				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter().replace("icon-", ""));
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	var alfiefucking = false;

	public function setNotex(a:Bool) {
		for(n in allNotes)
		{
			if (n.mustPress && n.notData != -1 && !n.isOnScreen(camHUD))
			{
				var strum = playerStrums.members[a ? n.notData : n.noteData];
				if (n.alive)
				n.x = strum.x + (n.isSustainNote ? n.offsetX : 0);
			}
			else if (n.mustPress && n.notData == -1 && !n.isOnScreen(camHUD))
			{
				var strum = playerStrums.members[!a ? n.notData : n.noteData];
				if (n.alive)
				n.x = strum.x + (n.isSustainNote ? n.offsetX : 0);
			}
		}
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case "alfiefuckery":
				if (bihNum != 2)
				{
					if (value1 == "on")
					{
						alfiefucking = true;
						setNotex(true);
						FlxTween.cancelTweensOf(bells);
						FlxTween.tween(bells, {alpha: 1}, 1, {ease: FlxEase.cubeOut});
						for (i in noteglow)
						{
							i.alpha = 1;
						}
					}
					else if (value1 == "off")
					{
						alfiefucking = false;
						//setNotex(false);
						FlxTween.cancelTweensOf(bells);
						FlxTween.tween(bells, {alpha: 0.0}, 0.8, {ease: FlxEase.cubeOut});
						for (i in noteglow)
						{
							i.alpha = 0;
						}
					}
				}
			case "hearts":
				if (bihNum != 0)
					hemmiter.generate(Std.parseFloat(value1), Std.parseInt(value2));
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value)) value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.playAnim(value1, true);
				char.specialAnim = true;

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.idleSuffix = value2;
				char.recalculateDanceIdle();

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Char EX':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(boyfriendMap.exists(value2)) {
								var lastAlpha:Float = boyfriend.alpha;
								boyfriend.alpha = 0.00001;
								boyfriend = boyfriendMap.get(value2);
								boyfriend.alpha = lastAlpha;
								iconP1.changeIcon(boyfriend.healthIcon);
							}
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(dadMap.exists(value2)) {
								var wasGf:Bool = dad.curCharacter.startsWith('gf');
								var lastAlpha:Float = dad.alpha;
								dad.alpha = 0.00001;
								dad = dadMap.get(value2);
								if(!dad.curCharacter.startsWith('gf')) {
									if(wasGf) {
										gf.visible = true;
									}
								} else {
									gf.visible = false;
								}
								dad.alpha = lastAlpha;
								iconP2.changeIcon(dad.healthIcon);
							}
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf.curCharacter != value2) {
							if(gfMap.exists(value2)) {
								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
						}
						setOnLuas('gfName', gf.curCharacter);
				}
				reloadHealthBarColors();
        	    #if desktop
            	if (startTimer != null && startTimer.finished)
                {
                   DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter().replace("icon-", ""), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
                }
                else
                {
                    DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter().replace("icon-", ""));
                }
                #end

			case 'Change Character':


				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf) {
									gf.visible = true;
								}
							} else {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf.curCharacter != value2) {
							if(!gfMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = gf.alpha;
							gf.alpha = 0.00001;
							gf = gfMap.get(value2);
							gf.alpha = lastAlpha;
						}
						setOnLuas('gfName', gf.curCharacter);
				}
				reloadHealthBarColors();
				#if desktop
				if (startTimer != null && startTimer.finished)
				{
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter().replace("icon-", ""), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
				}
				else
				{
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter().replace("icon-", ""));
				}
				#end

			case 'Black Bars':
                var val1:Float = Std.parseFloat(value1.trim());
                if(Math.isNaN(val1)) val1 = 0;
                if(value1.trim().endsWith("%")) val1 = (val1 / 100) * FlxG.height / 2;

                var ease:EaseFunction = FlxEase.linear;
                var duration:Float = -1;

                var v2data = value2.split(",");
                if(v2data.length >= 1) {
                    duration = Std.parseFloat(v2data[0].trim());
                    if(Math.isNaN(duration)) duration = -1;
                }
                if(v2data.length >= 2) {
                    ease = CoolUtil.getFlxEaseByString(v2data[1].trim());
                }

                FlxTween.cancelTweensOf(upperBlackBar);
                FlxTween.cancelTweensOf(bottomBlackBar);

                var upperY = 0 - upperBlackBar.height + val1;
                var bottomY = FlxG.height - val1;

                if(duration == -1) {
                    upperBlackBar.y = upperY;
                    bottomBlackBar.y = bottomY;
                } else {
                    FlxTween.tween(upperBlackBar, {y: upperY}, duration, {ease: ease});
                    FlxTween.tween(bottomBlackBar, {y: bottomY}, duration, {ease: ease});
                }

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				} 

			case 'Set Property':
				var vals:Array<String> = value1.split('.');
				if(vals.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(vals, true, true), vals[vals.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}

			case 'Set Property Bool':
				var vals:Array<String> = value1.split('.');
				if(vals.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(vals, true, true), vals[vals.length-1], value2.toLowerCase() == "true" || value2 == "1");
				} else {
					FunkinLua.setVarInArray(this, value1, value2.toLowerCase() == "true" || value2 == "1");
				}

		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (SONG.notes[id].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0];
			camFollow.y += gf.cameraPosition[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0];
			camFollow.y += dad.cameraPosition[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}
			camFollow.x -= boyfriend.cameraPosition[0];
			camFollow.y += boyfriend.cameraPosition[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		/*#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement();

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end
*/

		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}

					if(LockManager.shouldGoToCredits()) {
						LoadingState.loadAndSwitchState(new ChartCredits(), true);
					} else {
						MusicBeatState.switchState(new StoryMenuState());
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
					}

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					cancelMusicFadeTween();
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			destroyNote(daNote);
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = true;
	public var showRating:Bool = true;

	//public var consecutiveSicks:Int = 0;

	function oneLetterUppercase (a:String):String{
		return a.charAt(0).toUpperCase()+a.substr(1).toLowerCase();
	}

	static final hasTextColor = ["shit","bad"];
	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);

		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:String = Conductor.judgeNote(noteDiff);
		/*if(daRating != "sick"){
			//consecutiveSicks=0;
			ratingText.visible = false;
		}else{
			ratingText.visible = true;
		}*/

		ratingText.visible = true;
		ratingText.text = oneLetterUppercase(daRating)+" "+combo;
		ratingText.updateHitbox();

		setRatingPositions();
		ratingText.antialiasing=true;
		if(hasTextColor.indexOf(daRating)<0){
			ratingText.color = 0xFFFFFFFF;
		}
		if(rateTween!=null)
			rateTween.cancel();

		ratingText.alpha=1;
		rateTween = FlxTween.tween(ratingText, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				rateTween =null;
			},
			startDelay: Conductor.crochet * 0.002
		});

		switch (daRating)
		{
			case "shit": // shit
				totalNotesHit += 0;
				score = 50;
				shits++;
				ratingText.color = 0xFF391F16;
			case "bad": // bad
				totalNotesHit += 0.5;
				score = 100;
				bads++;
				ratingText.color = 0xFFAA350E;
			case "good": // good
				totalNotesHit += 0.75;
				score = 200;
				goods++;
			case "sick": // sick
				totalNotesHit += 1;
				sicks++;

				//consecutiveSicks++;
				if(!note.noteSplashDisabled && !noteSplashGloballyDisabled)
				{
					spawnNoteSplashOnNote(note);
				}
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating();
			}

			if(ClientPrefs.scoreZoom)
			{
				if(scoreTxtTween != null) {
					scoreTxtTween.cancel();
				}
				scoreTxt.scale.x = 1.075;
				scoreTxt.scale.y = 1.075;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						scoreTxtTween = null;
					}
				});
			}
		}

	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								destroyNote(doubleNote);
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else if (canMiss) {
					noteMissPress(key);
					callOnLuas('noteMissPress', [key]);
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				#if ACHIEVEMENTS_ALLOWED
				keysPressed[key] = true;
				#end

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			// HOLDING
			var up = controls.NOTE_UP;
			var right = controls.NOTE_RIGHT;
			var down = controls.NOTE_DOWN;
			var left = controls.NOTE_LEFT;
			var controlHoldArray:Array<Bool> = [left, down, up, right];

			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				/*#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end*/
			} else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				destroyNote(note);
			}
		});
		if(combo !=0){
			ratingText.visible = true;
			ratingText.text ="Miss 0";
			ratingText.updateHitbox();

			setRatingPositions();
			ratingText.antialiasing=true;
			ratingText.color = 0xFF391F16;

			if(rateTween!=null)
				rateTween.cancel();

			ratingText.alpha=1;
			rateTween = FlxTween.tween(ratingText, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					rateTween =null;
				},
				startDelay: Conductor.crochet * 0.002
			});

		}
		combo = 0;

		health -= daNote.missHealth * healthLoss;
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating();

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char.hasMissAnimations)
		{
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if(ClientPrefs.ghostTapping) return;

			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = "";

			var curSection:Int = Math.floor(curStep / 16);
			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim || note.noteType == 'Alt Animation') {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote || note.mustPressByThird) {
				char = gf;
			}

			char.playAnim(animToPlay, true);
			char.holdTimer = 0;
		}

		if(SONG.player2 == 'gethlyn') {
			var drain = 0.02;
			if((health - drain)/2 >= 0.5) {health-=drain;}
		  }

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.isHoldEnd) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time,note);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			destroyNote(note);
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					destroyNote(note);
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
			}
			health += note.hitHealth * healthGain;

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';

				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				//if (note.isSustainNote){ wouldn't this be fun : P. i think it would be swell

					//if(note.gfNote) {
					//  var anim = animToPlay +"-hold" + daAlt;
					//	if(gf.animation.getByName(anim) == null)anim = animToPlay + daAlt;
					//	gf.playAnim(anim, true);
					//	gf.holdTimer = 0;
					//} else {
					//  var anim = animToPlay +"-hold" + daAlt;
					//	if(boyfriend.animation.getByName(anim) == null)anim = animToPlay + daAlt;
					//	boyfriend.playAnim(anim, true);
					//	boyfriend.holdTimer = 0;
					//}
				//}else{
					if(note.gfNote) {
						gf.playAnim(animToPlay + daAlt, true);
						gf.holdTimer = 0;
					} else {
						boyfriend.playAnim(animToPlay + daAlt, true);
						boyfriend.holdTimer = 0;
					}
				//}
				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.isHoldEnd) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time,note);
			} else {
				playerStrums.members[Std.int(Math.abs(note.noteData))].playAnim('confirm', true);
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				destroyNote(note);
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	public var exiting = false;

	private var preventLuaRemove:Bool = false;
	override function destroy() {

		TransparentWindow.disableTransparent();
		Lib.application.window.borderless = false;
		Main.fpsVar.visible = true; // Transparent

		if(endingSong || exiting) {
			if(origWinFullScreen != null) Lib.application.window.fullscreen = origWinFullScreen;

			if(origWinWidth != null && origWinHeight != null) {
				Application.current.window.resize(
					Std.int(origWinWidth),
					Std.int(origWinHeight)
				);
			}
			if(origWinX != null) Lib.application.window.x = Std.int(origWinX);
			if(origWinY != null) Lib.application.window.y = Std.int(origWinY);
			origWinWidth = null;
			origWinX = null;
			origWinY = null;
			origWinHeight = null;
			origWinFullScreen = null;
		}


		preventLuaRemove = true;
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		allNotes = FlxDestroyUtil.destroyArray(allNotes);
		unspawnNotes = FlxDestroyUtil.destroyArray(unspawnNotes);
		if(modchartSprites != null) for(val in modchartSprites) val.destroy();
		if(modchartTweens != null) for(val in modchartTweens) val.destroy();
		if(boyfriendMap != null) for(val in boyfriendMap) val.destroy();
		if(dadMap != null) for(val in dadMap) val.destroy();
		if(gfMap != null) for(val in gfMap) val.destroy();

		modchartSprites = null;
		modchartTweens = null;
		boyfriendMap = null;
		dadMap = null;
		gfMap = null;

		FlxG.game.filtersEnabled = false;

		#if mac
		Main.macBackground.visible = false;
		#end

		super.destroy();

		spritesToDestroy = FlxDestroyUtil.destroyArray(spritesToDestroy);
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music == null) return;
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lastBeatHit:Int = -1;

	var eventNum:Int = 0;

	var enableCameraBopping = true;

	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		var sec = SONG.notes[Math.floor(curStep / 16)];

		if (sec != null)
		{
			if (sec.changeBPM)
			{
				Conductor.changeBPM(sec.bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', sec.mustHitSection);
			setOnLuas('altAnim', sec.altAnim);
			setOnLuas('gfSection', sec.gfSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		//comebackherelol

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (enableCameraBopping && camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			if(!tweeningZoom) {
				FlxG.camera.zoom += 0.015;
			}
			camHUD.zoom += 0.03;
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
		{
			gf.dance();
		}

		if(curBeat % 2 == 0) {
			if (boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name != null && !boyfriend.animation.curAnim.name.startsWith("sing"))
			{
				boyfriend.dance();
			}
			if (dad.animation.curAnim != null && dad.animation.curAnim.name != null && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
			{
				dad.dance();
			}
		} else if(dad.danceIdle && dad.animation.curAnim.name != null && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned) {
			dad.dance();
		}

		//shillton
		if (formattedSong == 'forest-fire' && curStage == 'shillton')
		{
			if(eventNum == 0 && curBeat >= 1) {
				eventNum++;
				if (!ClientPrefs.lowQuality) {
					add(oldstripes);
				}
				add(vignette);
				FlxTween.tween(vignette, {alpha: 1}, 1);
				FlxTween.tween(camHUD, {alpha: 0}, 1);
			}


			if(eventNum == 1 && curBeat >= 16) {
				eventNum++;
				FlxTween.tween(vignette, {alpha: 1}, 1);
				camHUD.alpha = 1;
			}

			if(eventNum == 2 && curBeat >= 79) {
				eventNum++;
				if (!ClientPrefs.lowQuality) {
					FlxTween.tween(oldstripes, {alpha: 1}, 1);
				}
				FlxTween.tween(vignette, {alpha: 0}, 1);
			}
			if(eventNum == 3 && curBeat >= 111) {
				eventNum++;
				if (!ClientPrefs.lowQuality) {
					FlxTween.tween(oldstripes, {alpha: 0}, 1);
					FlxTween.tween(black, {alpha: 0.5}, 1);
				}
				FlxTween.tween(vignette, {alpha: 1}, 1);
			}
			if(eventNum == 4 && curBeat >= 143) {
				eventNum++;
				if (!ClientPrefs.lowQuality) {
					FlxTween.tween(black, {alpha: 0}, 1);
				}
			}
			if(eventNum == 5 && curBeat >= 175) {
				eventNum++;
				if (!ClientPrefs.lowQuality) {
					FlxTween.tween(oldstripes, {alpha: 1}, 1);
				}
				FlxTween.tween(vignette, {alpha: 0}, 1);
			}
			if(eventNum == 6 && curBeat >= 207) {
				eventNum++;
				if (!ClientPrefs.lowQuality) {
					FlxTween.tween(black, {alpha: 0.5}, 1);
				}
			}
			if(eventNum == 7 && curBeat >= 271) {
				eventNum++;
				if (!ClientPrefs.lowQuality) {
					FlxTween.tween(black, {alpha: 0}, 1);
				}
			}
			if(eventNum == 8 && curBeat >= 303) {
				eventNum++;
				if (!ClientPrefs.lowQuality) {
					FlxTween.tween(oldstripes, {alpha: 0}, 1);
				}
				FlxTween.tween(vignette, {alpha: 1}, 1);
			}
		}



		if (formattedSong == 'after-dark' && curStage == 'dark')
		{
			if(eventNum == 0 && curBeat >= 8) {
				eventNum++;
				dad.alpha = 0.3;
				dad.scale.set(1.05, 1.05);
				FlxTween.tween(black, {alpha: 0}, 0.5);
				if (!ClientPrefs.lowQuality) {
					add(redglow);
					add(scanlines);
					add(vignette);
					FlxTween.tween(redglow, {alpha: 1}, 0.5);
					FlxTween.tween(scanlines, {alpha: 0.3}, 0.5);
					FlxTween.tween(vignette, {alpha: 0.5}, 0.5);
				}
				add(darksparks);
				camHUD.alpha = 1;
			}

			if(eventNum == 1 && curBeat >= 188) {
				eventNum++;
				FlxTween.tween(eyes, {alpha: 1}, 0.5);
				eyes.animation.play('eyes', true);

				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					eyes.animation.pause();
					eyes.animation.curAnim.curFrame = 72;
				});
			}

			if(eventNum == 2 && curBeat >= 256) {
				eventNum++;
				FlxTween.tween(circles, {alpha: 0.5}, 1);
				FlxTween.tween(darksparks, {alpha: 0.85}, 1);
			}

			if(eventNum == 3 && curBeat >= 640) {
				eventNum++;
				eyes.animation.curAnim.curFrame = 72;
				eyes.animation.resume();
			}

			if(eventNum == 4 && curBeat >= 704) {
				eventNum++;
				FlxTween.tween(circles, {alpha: 0}, 1);
				FlxTween.tween(darksparks, {alpha: 0}, 1);
			}

			if(eventNum == 5 && curBeat >= 774) {
				eventNum++;
				FlxTween.tween(black, {alpha: 1}, 2);
				FlxTween.tween(camHUD, {alpha: 0}, 2);
			}
		}

		//mansiontop
		if (formattedSong == 'spectral-sonnet' && curStage == 'mansiontop' && !ClientPrefs.lowQuality)
		{
			switch (curBeat)
			{
				case 1: {
					add(blackOverlay);
					add(rainweak);
					add(rainsmall);
					add(rainbig);
					add(vignette);
					add(remixadd);
					add(remixThings);
					FlxTween.tween(vignette, {alpha: 1}, 1);
				}


				case 56: {
					FlxTween.tween(blackOverlay, {alpha: 1}, 2);
				}


				case 63: {
					blackOverlay.alpha = 0;
					week1old.alpha = 0;
					vignette.alpha = 0;
				}

				case 64: {
					remove(week1old);
					remove(vignette);
					remove(blackOverlay);
				}


				case 128: {
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					rainweak.alpha = 0.5;
					rainsmall.alpha = 0.5;
					rainbig.alpha = 0.5;
				}

				case 160: {
					FlxTween.tween(flowers1, {alpha: 1}, 0.3);
					FlxTween.tween(remixadd, {alpha: 0.5}, 4);
				}

				case 164: {
					FlxTween.tween(flowers2, {alpha: 1}, 0.3);
				}

				case 168: {
					FlxTween.tween(flowers3, {alpha: 1}, 0.3);
				}

				case 172: {
					FlxTween.tween(flowers4, {alpha: 1}, 0.3);
				}

				case 208: {
					FlxTween.tween(remixThings, {alpha: 0.7}, 0.6);
				}

				case 256: {
					FlxG.camera.flash(FlxColor.BLACK,3,false);
					blackbg.alpha = 0.8;
					rainweak.alpha = 0;
					rainsmall.alpha = 0;
					remixadd.alpha = 0;
					remixThings.alpha = 0;
					rainbig.alpha = 0;
					FlxTween.tween(sun, {alpha: 1}, 1);
				}

				case 288: {
					FlxTween.tween(bells, {alpha: 1}, 1);
				}

				case 320: {
					bells.alpha = 0;
					sun.alpha = 0;
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					blackbg.alpha = 0;
				}

				case 321: {
					remove(bells);
					remove(sun);
				}

				case 353: {
					FlxTween.tween(remixadd, {alpha: 0.5}, 2.7);

				}

				case 360: {
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					blackbg.alpha = 0.35;
					rainweak.alpha = 0.5;
					rainsmall.alpha = 0.5;
					rainbig.alpha = 0.5;
					remixThings.alpha = 0.7;
				}

				case 448: {
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					FlxTween.tween(blackbg, {alpha: 0}, 5);
					FlxTween.tween(rainweak, {alpha: 0}, 5);
					FlxTween.tween(rainsmall, {alpha: 0}, 5);
					FlxTween.tween(rainbig, {alpha: 0}, 5);
					FlxTween.tween(remixadd, {alpha: 0}, 5);
					FlxTween.tween(remixThings, {alpha: 0}, 5);


				}

			}

		}



		//mansiontop
		if (formattedSong == 'spectral-sonnet' && curStage == 'mansiontop' && ClientPrefs.lowQuality)
		{
			switch (curBeat)
			{
				case 1:
				{
					add(blackOverlay);
					add(vignette);
					FlxTween.tween(vignette, {alpha: 1}, 1);
				}


				case 56:
				{
					FlxTween.tween(blackOverlay, {alpha: 1}, 2);

				}


				case 63:
				{
					blackOverlay.alpha = 0;
					week1old.alpha = 0;
					vignette.alpha = 0;
				}

				case 64:
				{
					remove(week1old);
					remove(vignette);
					remove(blackOverlay);
				}
				case 160: {
					FlxTween.tween(flowers1, {alpha: 1}, 0.3);
					FlxTween.tween(flowers2, {alpha: 1}, 0.3);
					FlxTween.tween(flowers3, {alpha: 1}, 0.3);
					FlxTween.tween(flowers4, {alpha: 1}, 0.3);

				}

			}
		}



		if (formattedSong == 'spectral-sonnet-beta' && curStage == 'siivagunner')
		{
			switch (curBeat)
			{
				case 210:
				{
					trace('hello??');
					new FlxTimer().start(0.35, function(tmr:FlxTimer){
						black.alpha = 1;
						dad.alpha = 0;
						gf.alpha = 0;
						remove(dad);
						remove(gf);
						boyfriend.playAnim('dies',true, false);
						deathsound.play(true);
						boyfriend.specialAnim = true;
						camHUD.alpha = 0;
					});

				}
			}
		}

		if (formattedSong == 'goated' && curStage == 'erect' && !ClientPrefs.lowQuality)
		{
			switch (curBeat)
			{
				case 1:
				{
					add(ballsowo);
					add(light1);
					add(light2);

				}
				case 256 | 456:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					black.alpha = 0.5;
					ballsowo.alpha = 1;
					light1.alpha = 1;
				}



				case 262 | 278 | 294 | 310 | 326 | 342 | 358 | 374 | 472 | 488 | 504 | 520 | 536 | 552 | 568 | 584 | 600 | 616:
				{
					light2.alpha = 1;
					light1.alpha = 0;

				}

				case 270 | 286 | 302 | 318 | 334 | 350 | 366 | 480 | 496 | 512 | 528 | 544 | 560 | 576 | 592 | 608:
				{
					light2.alpha = 0;
					light1.alpha = 1;

				}

				case 384 | 624:
				{
					FlxTween.tween(black, {alpha: 0}, 1);
					FlxTween.tween(ballsowo, {alpha: 0}, 1);
					FlxTween.tween(light1, {alpha: 0}, 1);
					FlxTween.tween(light2, {alpha: 0}, 1);
				}

			}
		}

		if (formattedSong == 'goated' && curStage == 'erect' && ClientPrefs.lowQuality)
			{
				switch (curBeat)
				{
					case 256 | 456:
					{
						FlxG.camera.flash(FlxColor.WHITE,1,false);
						black.alpha = 0.5;

					}


					case 384 | 624:
					{
						FlxTween.tween(black, {alpha: 0}, 1);
					}

				}
			}

		if (formattedSong == 'candlelit-clash' && curStage == 'candlelit')
		{

			switch (curBeat)
			{

				case 14:
				{
					FlxTween.tween(dad, {alpha: 1}, 0.4);
					upperBlackBar.exists = false;
					bottomBlackBar.exists = false;
				}

				case 148:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					candlelitpaintings.animation.play("hcandlebg");
					candlelitpaintings.alpha = 1;
					//hcandlebg.alpha = 1;
				}

				case 212:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					if (!ClientPrefs.lowQuality) {
						brokencandlebg.alpha = 1;
						FlxG.game.filtersEnabled = true;
						candledark.alpha = 0;
						candleglow.alpha = 0;
					}
				}

				case 276:
				{
					if (!ClientPrefs.lowQuality) {
						FlxG.camera.flash(FlxColor.WHITE,1,false);
						brokencandlebg.alpha = 0;
						FlxG.game.filtersEnabled = false;
						candledark.alpha = 1;
						candleglow.alpha = 1;
					}

				}

				case 308:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					//acandlebg.alpha = 1;
					candlelitpaintings.animation.play("acandlebg");
					candlelitpaintings.alpha = 1;
					//remove(hcandlebg);
				}

				case 340:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					if (!ClientPrefs.lowQuality) {
					FlxTween.tween(candlebells, {alpha: 1}, 2);}
					FlxTween.tween(black, {alpha: 0.4}, 2);

				}

				case 435:
				{
					if (!ClientPrefs.lowQuality) {
					FlxTween.tween(candlebells, {alpha: 0}, 3);}
					FlxTween.tween(black, {alpha: 0}, 2);
				}

				case 468:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					//remove(acandlebg);
					candlelitpaintings.alpha = 0;
				}

				case 632:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					//ecandlebg.alpha = 1;
					candlelitpaintings.animation.play("ecandlebg");
					candlelitpaintings.alpha = 1;
				}

				case 728:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					add(candlespotlight);
				}

				case 776:
				{
					FlxTween.tween(candlespotlight, {alpha: 0}, 2);
				}

				case 800:
				{
					remove(candlespotlight);
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					//remove(ecandlebg);
					//lcandlebg.alpha = 1;
					candlelitpaintings.animation.play("lcandlebg");
					candlelitpaintings.alpha = 1;

				}
				case 957:
				{
					upperBlackBar.exists = true;
					bottomBlackBar.exists = true;
				}
				case 976:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					//remove(lcandlebg);
					candlelitpaintings.alpha = 0;
				}

				case 1132:
				{
					if (!ClientPrefs.lowQuality) {
					FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);}
				}
				case 1133:
				{
					if (!ClientPrefs.lowQuality) {
						countdownReady = new FlxSprite().loadGraphic(Paths.image('ready'));
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();
						countdownReady.screenCenter();
						countdownReady.scale.set(0.8, 0.8);
						countdownReady.cameras = [camOther];
						add(countdownReady);
						FlxTween.tween(countdownReady, {alpha: 0}, 0.3, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady, true);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);}
				}
				case 1134:
				{
					if (!ClientPrefs.lowQuality) {
						countdownSet = new FlxSprite().loadGraphic(Paths.image('set'));
						countdownSet.scrollFactor.set();
						countdownSet.screenCenter();
						countdownSet.cameras = [camOther];
						countdownSet.scale.set(0.8, 0.8);
						add(countdownSet);
						FlxTween.tween(countdownSet, {alpha: 0}, 0.3, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet, true);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);}
				}
				case 1135:
				{
					if (!ClientPrefs.lowQuality) {
						countdownGo = new FlxSprite().loadGraphic(Paths.image('go'));
						countdownGo.scrollFactor.set();
						countdownGo.updateHitbox();
						countdownGo.screenCenter();
						countdownGo.cameras = [camOther];
						countdownGo.scale.set(0.8, 0.8);
						add(countdownGo);
						FlxTween.tween(countdownGo, {alpha: 0}, 0.3, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo, true);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
					}
				}

				case 1136:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					if (!ClientPrefs.lowQuality) {
					FlxTween.tween(funkyassoverlay, {alpha: 1}, 0.5);}
				}

				case 1200:
				{
					if (!ClientPrefs.lowQuality) {
					FlxTween.tween(funkyassoverlay, {alpha: 0}, 1);}
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					dad.alpha = 0.6;
				}

				case 1232:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					FlxTween.tween(dad, {alpha: 0}, 2.5);
				}
			}
		}


		if (formattedSong == 'goat-remake' && curStage == 'newstage')
		{

			switch (curBeat)
			{

				case 8:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);

					goatold.alpha = 0;
					if (!ClientPrefs.lowQuality) {
						goatmultiply.alpha = 1;
						goatadd.alpha = 1;
					}

					dadGroup.alpha = 1;
					iconP2.alpha = 1;
					healthBar.color = 0xFFFFFFFF;
					healthBar.alpha = ClientPrefs.healthBarAlpha;
					boyfriend.color = 0xFFFFFFFF;
					iconP1.color = 0xFFFFFFFF;
					iconP1.alpha = ClientPrefs.healthBarAlpha;
					gf.color = 0xFFFFFFFF;
				}

				case 72:
				{
					monitors.visible = true;
				}
				case 104:
				{
					monitors.animation.play('senapi');
				}
				case 120:
				{
					monitors.animation.play('parents');
				}
				case 136:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					goatold.alpha = 1;
					if (!ClientPrefs.lowQuality) {
						goatmultiply.alpha = 0;
						goatadd.alpha = 0;
						add(vignette);
						vignette.alpha = 1;
					}
					healthBar.color = 0xFF000000;
					healthBar.alpha = ClientPrefs.healthBarAlpha;
					boyfriend.color = 0xFF000000;
					dad.color = 0xFF000000;
					iconP2.color = 0xFF000000;
					iconP1.color = 0xFF000000;
					iconP2.alpha = ClientPrefs.healthBarAlpha;
					iconP1.alpha = ClientPrefs.healthBarAlpha;
					gf.color = 0xFF000000;
				}
				case 168:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					//remove(goatold);
					goatold.alpha = 0;
					if (!ClientPrefs.lowQuality) {
						goatmultiply.alpha = 1;
						goatadd.alpha = 1;
						remove(vignette);
					}
					healthBar.color = 0xFFFFFFFF;

					boyfriend.color = 0xFFFFFFFF;
					iconP1.color = 0xFFFFFFFF;
					gf.color = 0xFFFFFFFF;
					dad.color = 0xFFFFFFFF;
					iconP2.color = 0xFFFFFFFF;
					healthBar.alpha = ClientPrefs.healthBarAlpha;
					iconP2.alpha = ClientPrefs.healthBarAlpha;
					iconP1.alpha = ClientPrefs.healthBarAlpha;
					//vignette.alpha = 1;
					monitors.animation.play('whitty');
				}
				case 200:
				{
					monitors.animation.play('zardy');
				}
				case 232:
				{
					monitors.animation.play('filip');
				}
				case 264:
				{
					monitors.animation.play('sarvente');
				}
				case 296:
				{
					monitors.animation.play('ace');
				}

				case 328:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					goatold.alpha = 1;
					if (!ClientPrefs.lowQuality) {
						goatmultiply.alpha = 0;
						goatadd.alpha = 0;
						add(vignette);
						vignette.alpha = 1;
					}
					healthBar.color = 0xFF000000;
					boyfriend.color = 0xFF000000;
					dad.color = 0xFF000000;
					iconP2.color = 0xFF000000;
					iconP1.color = 0xFF000000;
					gf.color = 0xFF000000;
					healthBar.alpha = ClientPrefs.healthBarAlpha;
					iconP2.alpha = ClientPrefs.healthBarAlpha;
					iconP1.alpha = ClientPrefs.healthBarAlpha;
				}
				case 360:
				{
					add(blackOverlay);
					blackOverlay.alpha = 1;
				}
			}
		}

		if (formattedSong == 'interrupted' && curStage == 'ourple')
		{ //dad 1 is phone dad 2 is ourplemark dad 3 is guy and dad 4 is crying

			switch (curBeat)
			{
				case 1:
					for(note in unspawnNotes) if(note != null) note.noteSplashDisabled = true;
					for(note in notes.members) if(note != null) note.noteSplashDisabled = true;
					markiplier.visible = false;
					cryingchild.alpha = 0.0001;

				case 2:
				{
					FlxTween.tween(blackOverlay, {alpha: 0}, 2, {ease: FlxEase.expoIn});
				}

				case 8:
				{
					FlxTween.tween(healthBar, {alpha: 1}, 3, {ease: FlxEase.expoIn});
					FlxTween.tween(iconP2, {alpha: 1}, 3, {ease: FlxEase.expoIn});
					FlxTween.tween(iconP1, {alpha: 1}, 3, {ease: FlxEase.expoIn});
					FlxTween.tween(cryingchild, {alpha: 1}, 3);
					FlxTween.tween(boyfriendGroup, {alpha: 1}, 3);

				}
				case 172:
				{
					FlxTween.tween(ourpleguy, {y: -300}, 8 * Conductor.stepCrochet / 1000, {ease: FlxEase.expoIn});
				}
				case 174:
				{
					cryingchild.playAnim('dead');
					cryingchild.specialAnim = true;
					new FlxTimer().start(2, function(tmr:FlxTimer)
					{
						cryingchild.animation.pause();
						cryingchild.animation.curAnim.curFrame = 93;
					});
					ourplebg.alpha = 1;
					remove(ourplelight);
				}
				case 354:
				{
					FlxTween.tween(phoneguy, {x: 1200}, 12 * Conductor.stepCrochet / 1000, {ease: FlxEase.expoInOut});

				}

				case 362:
				{
					FlxTween.tween(phoneguy, {x: 200}, 12 * Conductor.stepCrochet / 1000, {ease: FlxEase.expoInOut});

				}
				case 513:
				{
					if (!ClientPrefs.lowQuality) {
						FlxTween.tween(ourpletheory, {alpha: 1}, 155 * Conductor.stepCrochet / 1000);
					}

				}
				case 525:
				{
					if (!ClientPrefs.lowQuality) {
						FlxTween.tween(ourplelogo, {alpha: 1}, 107 * Conductor.stepCrochet / 1000);
					}

				}
				case 558:
				{
					remove(ourpletheory);
					remove(ourplelogo);
					ourpleguy.playAnim('eat');
					ourpleguy.specialAnim = true;
					new FlxTimer().start(6, function(tmr:FlxTimer)
						{
							ourpleguy.animation.pause();
							ourpleguy.animation.curAnim.curFrame = 158;
						});
				}
				case 578:
				{
					markiplier.visible = true;
					markiplier.playAnim('fall');
					markiplier.specialAnim = true;
				}
				case 600:
				{
					ourpleguy.animation.resume();
				}
				case 768:
				{
					blackOverlay.alpha = 1;
				}
			}
		}


		if (formattedSong == 'all-saints-scramble' && curStage == 'skalloween')
			{

				switch (curBeat)
				{
					case 4:
					{
						FlxTween.tween(skaclock, {alpha: 1}, 1);

					}

					case 8:
					{
						skaclock.animation.curAnim.curFrame = 24;
						skaclock.animation.resume();
						new FlxTimer().start(0.4, function(tmr:FlxTimer)
							{
								skaclock.animation.pause();
							});
					}
					case 12:
					{
						skaclock.animation.curAnim.curFrame = 48;
						skaclock.animation.resume();
						new FlxTimer().start(0.4, function(tmr:FlxTimer)
							{
								skaclock.animation.pause();
							});
					}
					case 16:
					{
						skaclock.animation.curAnim.curFrame = 93;
						skaclock.animation.resume();
						new FlxTimer().start(0.4, function(tmr:FlxTimer)
							{
								skaclock.animation.pause();
							});
					}
					case 20:
					{
						skaclock.animation.curAnim.curFrame = 120;
						skaclock.animation.resume();
						new FlxTimer().start(0.4, function(tmr:FlxTimer)
							{
								skaclock.animation.pause();
							});
					}

					case 24:
					{
						skaclock.animation.curAnim.curFrame = 144;
						skaclock.animation.resume();
						new FlxTimer().start(0.4, function(tmr:FlxTimer)
							{
								skaclock.animation.pause();
							});
					}

					case 28:
					{
						skaclock.animation.curAnim.curFrame = 168;
						skaclock.animation.resume();
						new FlxTimer().start(0.4, function(tmr:FlxTimer)
							{
								skaclock.animation.pause();
							});
					}

					case 32:
					{
						blackOverlay.alpha = 0.0001;
						remove(skaclock);
						camHUD.alpha = 1;
					}

					case 320:
					{
						FlxG.camera.flash(FlxColor.WHITE,1,false);
						if (!ClientPrefs.lowQuality) {
						grayscale.apply = 1;
						vignette.alpha = 1;}
					}

					case 350:
					{
						if (!ClientPrefs.lowQuality) {
						FlxTween.tween(grayscale, {apply: 0}, 8 * Conductor.stepCrochet / 1000);
						FlxTween.tween(vignette, {alpha: 0}, 8 * Conductor.stepCrochet / 1000);}

					}

					case 416:
					{
						if (!ClientPrefs.lowQuality) {
							skafunky.alpha = 1;
						}
					}

					case 672:
					{
						FlxTween.tween(blackOverlay, {alpha: 1}, 4);
					}

				}
			}

		if (formattedSong == 'heart-attack' && curStage == 'kpark')
		{

			switch (curBeat)
			{
				case 2:
				{
					if (!ClientPrefs.lowQuality) {
						add(funkyassoverlay);
						add(munchoverlay);
					}
				}

				case 36:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					if (!ClientPrefs.lowQuality) {
						funkyassoverlay.alpha = 0.45;
					}
				}
				case 100:
				{
					if (!ClientPrefs.lowQuality) {
						FlxTween.tween(funkyassoverlay, {alpha: 0}, 2.5);
					}
				}
				case 143:
				{
					FlxTween.tween(blackOverlay, {alpha: 1}, 1);
					FlxTween.tween(camHUD, {alpha: 0}, 1);
				}
				case 154:
				{
					if (!ClientPrefs.lowQuality) {
					skaclock.alpha = 1;
					skaclock.animation.resume();}
				}
				case 164:
				{
					if (!ClientPrefs.lowQuality) {
					skaclock.animation.play('transition20');}
				}

				case 168:
				{
					camHUD.alpha = 1;
					if (!ClientPrefs.lowQuality) {
					FlxTween.tween(kissuhoh, {alpha: 0.8}, 0.5 );
					skaclock.alpha = 0;}
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					blackOverlay.alpha = 0.0001;
				}
				case 232:
				{
					if (!ClientPrefs.lowQuality) {
					FlxTween.tween(munchoverlay, {alpha: 0.45}, 0.4);}
				}
				case 268:
				{
					if (!ClientPrefs.lowQuality) {
					FlxTween.tween(munchoverlay, {alpha: 0}, 2);}
				}
				case 303:
				{
					FlxTween.tween(blackOverlay, {alpha: 1}, 2);
				}
			}
		}

		if (formattedSong == 'jelly-jamboree' && curStage == 'waterfall')
			{

				switch (curBeat)
				{
					case 1:
					{
						blackOverlay.alpha = 0;
					}
					case 20:
					{
						if (!ClientPrefs.lowQuality) {
						FlxTween.tween(wateradd, {alpha: 0.8}, 1);
						FlxTween.tween(wateroverlay, {alpha: 1}, 1);}
					}
					case 22 | 266:
					{
						upperBlackBar.exists = false;
						bottomBlackBar.exists = false;
					}
					case 196:
					{
						upperBlackBar.exists = true;
						bottomBlackBar.exists = true;
					}
					case 101 | 109 | 117 | 125 | 293 | 301 | 309 | 317:
					{
						if (!ClientPrefs.lowQuality) {
						grayscale.apply = 1;
						FlxG.game.filtersEnabled = true;}
					}
					case 102 | 110 | 118 | 126 | 294 | 302 | 310 | 318:
					{
						if (!ClientPrefs.lowQuality) {
						grayscale.apply = 0.25;}
					}
					case 103 | 111 | 119 | 127 | 295 | 303  | 311 | 319 | 261:
					{
						if (!ClientPrefs.lowQuality) {
						grayscale.apply = 0;
						FlxG.game.filtersEnabled = true;}
					}
					case 104 | 112 | 120 | 128 | 296 | 304 | 312 | 320 | 262:
					{
						if (!ClientPrefs.lowQuality) {
						grayscale.apply = 0;
						FlxG.game.filtersEnabled = false;}
					}
					case 324:
					{
						FlxTween.tween(camHUD, {alpha: 0}, 2);
					}
					case 340:
						FlxTween.tween(blackOverlay, {alpha: 1}, 9);

				}
			}

		if (formattedSong == 'minimize' && curStage == 'fake')
		{

			switch (curBeat)
			{
				case 17:
				{
					for(note in unspawnNotes) if(note != null) note.noteSplashDisabled = true;
					for(note in notes.members) if(note != null) note.noteSplashDisabled = true;
					//dad.alpha = 0.0001;
					coming4u.animation.resume();
				}
				case 31:
				{
					camHUD.alpha = 1;
					enableCameraBopping = false;
					blackOverlay.alpha = 1;
					coming4u.animation.pause();
					boyfriend.screenCenter(XY);
					dad.screenCenter(XY);
					dad.scrollFactor.set(0,0);
					boyfriend.alpha = 0.0000;
					gf.alpha = 0.0000;
					fakeweek.alpha = 0.0000;
				}

				case 37:
				{

					if (ClientPrefs.middleScroll) {
						for(note in notes.members) if(note != null && !note.mustPress) note.visible = false;
						for(note in unspawnNotes) if(note != null && !note.mustPress) note.visible = false;
						for(note in opponentStrums.members) {note.exists = false;}
					} //god this looks so good amirite bois

					coming4u.alpha = 0;
					remove(coming4u, true);
					coming4u.destroy();
					FlxTween.tween(blackOverlay, {alpha: 0}, 1.7);
					FlxTween.tween(dad, {alpha: 1}, 1.7);
				}

				case 104:
				{
					remove(blackOverlay);
					FlxTween.tween(dad, {alpha: 0}, 2.5);
					if (!ClientPrefs.lowQuality) {
					Main.instance.flashShader.color = 1.0;}
				}

				case 112:
				{
					if (ClientPrefs.lowQuality) {
						FlxG.camera.flash(FlxColor.WHITE,1,false);
					}

					if (!ClientPrefs.lowQuality) {
						Main.instance.flashShader.apply = 1;

						camGame.bgColor = FlxColor.fromRGB(2, 3, 5);

						FlxTween.tween(Main.instance.flashShader, {apply: 0}, 0.5);
						isMinimizeBroken = true;
						//FlxG.camera.flash(FlxColor.WHITE,0.5,false);

						if(origWinFullScreen == null) origWinFullScreen = Lib.application.window.fullscreen;
						#if mac
						if(origWinX == null) origWinX = Application.current.window.x;
						if(origWinY == null) origWinY = Application.current.window.y;
						if(origWinWidth == null) origWinWidth = Application.current.window.width;
						if(origWinHeight == null) origWinHeight = Application.current.window.height;
						Application.current.window.resize(
							Std.int(Application.current.window.display.bounds.width),
							Std.int(Application.current.window.display.bounds.height)
						);
						#end

						#if windows
						Lib.application.window.borderless = true;
						Lib.application.window.fullscreen = false;
						#end
						#if mac
						camGame.bgColor.alpha = 0;
						Main.macBackground.visible = true;
						Application.current.window.fullscreen = true;
						Application.current.window.borderless = true;

						var shader = new MacNoteAlphaShader();
						shader.downscroll.value = [ClientPrefs.downScroll ? 1 : 0];

						camHUD.setFilters([new ShaderFilter(shader)]);
						if(!ClientPrefs.downScroll) {
							scoreTxt.cameras = [camOther];
						}
						#end
						TransparentWindow.enableTransparent();
						Main.fpsVar.visible = false; // Transparent
						#if windows
						for(note in unspawnNotes) if(note != null && note.isSustainNote) note.multAlpha = 1;
						for(note in notes.members) if(note != null && note.isSustainNote) note.multAlpha = 1;
						camGame.setFilters([new ShaderFilter(new TransparentHudShader())]);
						camHUD.setFilters([new ShaderFilter(new TransparentHudShader())]);
						camOther.setFilters([new ShaderFilter(new TransparentHudShader())]);
						#end
					}
					dad.alpha = 1;
				}

				case 116:
				{
					if (!ClientPrefs.lowQuality) {
						Main.instance.flashShader.color = 1/255;
					}

				}

				case 891:
				{
					if (!ClientPrefs.lowQuality) {
						FlxTween.tween(Main.instance.flashShader, {apply: 1}, 0.6);
						#if mac
						if(!ClientPrefs.downScroll) {
							FlxTween.tween(scoreTxt, {alpha: 0}, 0.6);
						}
						#end
					}

				}

				case 892:
				{
					canPause = false;
					if (!ClientPrefs.lowQuality) {
						Main.instance.flashShader.apply = 0;
						Lib.application.window.borderless = false;
						TransparentWindow.disableTransparent();
						camGame.setFilters([]);
						camHUD.setFilters([]);
						camOther.setFilters([]);
					}
					camHUD.alpha = 0.0001;
					camGame.bgColor = 0xFF000000;
					if (!ClientPrefs.lowQuality) {
						#if mac
						camGame.bgColor.alpha = 255;
						Main.macBackground.visible = false;
						#end
					}

				}

				case 924:
				{
					if (!ClientPrefs.lowQuality) {
					isMinimizeBroken = false;}

					dad.alpha = 0.0001;
				}
			}
		}

		if (formattedSong == 'spooks' && curStage == '90s')
		{
			switch (curBeat)
			{
				case 132:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					if (!ClientPrefs.lowQuality) {
						animevfx.alpha = 1;
						light1.alpha = 0.65;
						light2.alpha = 1;
					}

				}
				case 192:
				{
					if (!ClientPrefs.lowQuality) {
						FlxTween.tween(animevfx, {alpha: 0}, 1);
						FlxTween.tween(light1, {alpha: 0}, 1);
						FlxTween.tween(light2, {alpha: 0}, 1);}
					}
					FlxTween.tween(blackbg, {alpha: 0.6}, 2.5);
				case 200:
				{
					if (!ClientPrefs.lowQuality) {
						FlxTween.tween(animesmoke, {alpha: 0.8}, 2);}
				}
				case 232:
				{
					if (!ClientPrefs.lowQuality) {
						FlxTween.tween(animesmoke, {alpha: 0}, 2);}
				}
				case 256:
				{
					FlxG.camera.flash(FlxColor.WHITE,1,false);
					blackbg.alpha = 0.0001;
				}
				case 288:
				{
					if (!ClientPrefs.lowQuality) {
					FlxTween.tween(animevfx, {alpha: 1}, 1);
					FlxTween.tween(light1, {alpha: 0.65}, 1);
					FlxTween.tween(light2, {alpha: 1}, 1);}
				}
				case 356:
				{
					if (!ClientPrefs.lowQuality) {
					FlxTween.tween(animesmoke, {alpha: 0.3}, 0.5);}
				}
				case 384:
				{
					blackOverlay.alpha = 1;
				}
			}
		}


		switch (curStage)
		{
			case 'erect': //anime
				if(curBeat % 2 == 0)
				{
					bge.dance(true);
				}

			case '90s': //anime
				if(curBeat % 2 == 0)
				{
					animemap.dance(true);
				}

			case 'skalloween': //all saints wooooo
				if(curBeat % 2 == 0)
				{
					skacrowd.dance(true);
				}
				if(curBeat % 4 == 0)
				{
					skagf.dance(true);
				}

			case 'pasta': //anime
				if(curBeat % 2 == 0)
				{
					pastabg.dance(true);
				}
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat);//DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	public var closeLuas:Array<FunkinLua> = [];
	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			//trace(script.scriptName+"."+event);
			if(exclusions.contains(script.scriptName))
				continue;

			FunkinLua.currentScript = script;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;

			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if(!bool && ret != 0) {
				returnVal = cast ret;
			}
		}
		#end
		if(functions.get(event)!=null){
			Reflect.callMethod(null, functions.get(event), args);
		}
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for(script in luaArray) {
			FunkinLua.currentScript = script;
			script.set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float,n:Note) {
		var spr:StrumNote = null;
		if(isDad) {
			if (!n.mustPressByThird)
				spr = strumLineNotes.members[id];
			else
				spr = opponent2Strums.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	public function bypass_closeSubState(){super.closeSubState();}
	public function bypass_create(){super.create();}
	public function bypass_destroy(){super.destroy();}
	public function bypass_onFocus(){super.onFocus();}
	public function bypass_onFocusLost(){super.onFocusLost();}
	public function bypass_openSubState(SubState:FlxSubState){super.openSubState(SubState);}
	public function bypass_stepHit(){super.stepHit();}
	public function bypass_beatHit(){super.beatHit();}
	public function bypass_update(elapsed:Float){super.update(elapsed);}

	public static var othersCodeName:String = 'otherAchievements';
	#if ACHIEVEMENTS_ALLOWED

	#end
}
