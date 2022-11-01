package;

import flixel.util.FlxTimer;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.1'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story mode',
		//'freeplay',
		//#if MODS_ALLOWED 'mods', #end
		//#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'info',
		'credits',
		//#if !switch 'donate', #end
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var songListAlfie:Item;
	var infoBF:Item;
	var creditsPortrait:Item;
	var optionsPooky:Item;



	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, 0);
		//bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.setGraphicSize(FlxG.width, FlxG.height);

		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuBGDesat'));
		magenta.scrollFactor.set(0, 0);
		//magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.setGraphicSize(FlxG.width, FlxG.height);

		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		songListAlfie = new Item(200, 1800);
		songListAlfie.loadGraphic(Paths.image('mainmenu/SonglistAlfie'));
		infoBF = new Item(200, 1800);
		infoBF.loadGraphic(Paths.image('mainmenu/InfoBoyfriend'));
		creditsPortrait = new Item(200, 1800);
		creditsPortrait.loadGraphic(Paths.image('mainmenu/Creditsportrait'));
		optionsPooky = new Item(200, 1800);
		optionsPooky.loadGraphic(Paths.image('mainmenu/Optionspooky'));

		add(songListAlfie);
		add(infoBF);
		add(creditsPortrait);
		add(optionsPooky);

		var scale:Float = 1.1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{

			var offsetx:Float = 135;
			var offset:Float = 50 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0 + offsetx, (i * 150)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			//menuItem.screenCenter(X);
			menuItem.x -= 105;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, 0);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.9));
			menuItem.updateHitbox();

			switch(optionShit[i]) {
				case "story mode":
					menuItem.y -= 20;
				case "credits":
					menuItem.y -= 10;
				case "options":
					menuItem.y += 20;
			} 
		}




		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}


	var selectedSomethin:Bool = false;


	
	override function update(elapsed:Float)
	{



		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'info':
										MusicBeatState.switchState(new InfoState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
		{

		}

		/*menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});*/
	}

	var alfTimer:FlxTimer;
	var bfTimer:FlxTimer;
	var portraitTimer:FlxTimer;
	var pookyTimer:FlxTimer;


	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});



FlxTween.cancelTweensOf(songListAlfie);
FlxTween.cancelTweensOf(infoBF);
FlxTween.cancelTweensOf(creditsPortrait);
FlxTween.cancelTweensOf(optionsPooky);

if(alfTimer != null) alfTimer.cancel();
if(bfTimer != null) bfTimer.cancel();
if(portraitTimer != null) portraitTimer.cancel();
if(pookyTimer != null) pookyTimer.cancel();

switch (optionShit[curSelected])
{
    case 'story mode':
    {
        FlxTween.tween(songListAlfie,{y: -210}, 1.2, {ease: FlxEase.expoInOut});
        songListAlfie.angle = -4;

        alfTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            if(songListAlfie.angle == -4)
                FlxTween.angle(songListAlfie, songListAlfie.angle, 4, 4, {ease: FlxEase.quartInOut});
            if (songListAlfie.angle == 4)
                FlxTween.angle(songListAlfie, songListAlfie.angle, -4, 4, {ease: FlxEase.quartInOut});
        }, 0);

        FlxTween.tween(infoBF,{y: 1800}, 1.2, {ease: FlxEase.expoInOut});
        FlxTween.tween(creditsPortrait,{y: 1800}, 1.2, {ease: FlxEase.expoInOut});
        FlxTween.tween(optionsPooky,{y: 1800}, 1.2, {ease: FlxEase.expoInOut});
    }
    case 'info':
    {
        FlxTween.cancelTweensOf(Item);
        FlxTween.tween(infoBF,{y: -40}, 1.2, {ease: FlxEase.expoInOut});
        infoBF.angle = -4;

        bfTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            if(infoBF.angle == -4)
                FlxTween.angle(infoBF, infoBF.angle, 4, 4, {ease: FlxEase.quartInOut});
            if (infoBF.angle == 4)
                FlxTween.angle(infoBF, infoBF.angle, -4, 4, {ease: FlxEase.quartInOut});
        }, 0);

        FlxTween.tween(songListAlfie,{y: 1800}, 1.2, {ease: FlxEase.expoInOut});
        FlxTween.tween(creditsPortrait,{y: 1800}, 1.2, {ease: FlxEase.expoInOut});
        FlxTween.tween(optionsPooky,{y: 1800}, 1.2, {ease: FlxEase.expoInOut});
    }
    case 'credits':
    {
        FlxTween.tween(creditsPortrait,{y: 150}, 1.2, {ease: FlxEase.expoInOut});
        creditsPortrait.angle = -4;

        portraitTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            if(creditsPortrait.angle == -4)
                FlxTween.angle(creditsPortrait, creditsPortrait.angle, 4, 4, {ease: FlxEase.quartInOut});
            if (creditsPortrait.angle == 4)
                FlxTween.angle(creditsPortrait, creditsPortrait.angle, -4, 4, {ease: FlxEase.quartInOut});
        }, 0);

        FlxTween.tween(infoBF,{y: 1800}, 1.2, {ease: FlxEase.expoInOut});
        FlxTween.tween(songListAlfie,{y: 1800}, 1.2, {ease: FlxEase.expoInOut});
        FlxTween.tween(optionsPooky,{y: 1800}, 1.2, {ease: FlxEase.expoInOut});
    }
    case 'options':
    {
        FlxTween.tween(optionsPooky,{y: 350}, 1.2, {ease: FlxEase.expoInOut});
        optionsPooky.angle = -4;

        pookyTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            if(optionsPooky.angle == -4)
                FlxTween.angle(optionsPooky, optionsPooky.angle, 4, 4, {ease: FlxEase.quartInOut});
            if (optionsPooky.angle == 4)
                FlxTween.angle(optionsPooky, optionsPooky.angle, -4, 4, {ease: FlxEase.quartInOut});
        }, 0);

        FlxTween.tween(infoBF,{y: 1800}, 1.2, {ease: FlxEase.expoInOut});
        FlxTween.tween(creditsPortrait,{y: 1800}, 1.2, {ease: FlxEase.expoInOut});
        FlxTween.tween(songListAlfie,{y: 1800}, 1.2, {ease: FlxEase.expoInOut});
    }
}
	}
	
}

class Item extends FlxSprite {
    public var initialX:Float;
    public var initialY:Float;

    public function new(x:Float, y:Float) {
        initialY = y;
        initialX = x;
        super(x, y);
    }
}
