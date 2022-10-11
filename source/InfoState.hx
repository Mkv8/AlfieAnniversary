package;

import flixel.math.FlxRect;

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

class InfoState extends MusicBeatState
{
	//public static var psychEngineVersion:String = '0.5.1'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		//#if MODS_ALLOWED 'mods', #end
		//#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		//#if !switch 'donate', #end
		'info',
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var alfie:FlxSprite;
	var boyfriend:FlxSprite;
	var pooky:FlxSprite;
	var ethlyn:FlxSprite;
	var harper:FlxSprite;
	var laura:FlxSprite;

	var darken:FlxSprite;

	var alfiedesc:FlxSprite;
	var boyfrienddesc:FlxSprite;
	var pookydesc:FlxSprite;
	var ethlyndesc:FlxSprite;
	var harperdesc:FlxSprite;
	var lauradesc:FlxSprite;

	var backbutton:FlxSprite;
	var cursortext:FlxSprite;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('biomenu/mapbg'));


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
		bg.scrollFactor.set(0, 0);
		//bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter(XY);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		alfie = new FlxSprite(248, 310).loadGraphic(Paths.image('biomenu/alfie'));
		alfie.scrollFactor.set(0, 0);
		alfie.updateHitbox();
		alfie.antialiasing = ClientPrefs.globalAntialiasing;
		//add(alfie);

		pooky = new FlxSprite(370, 110).loadGraphic(Paths.image('biomenu/pooky'));
		pooky.scrollFactor.set(0, 0);
		pooky.updateHitbox();
		pooky.antialiasing = ClientPrefs.globalAntialiasing;
		//add(pooky);

		boyfriend = new FlxSprite(710, 330).loadGraphic(Paths.image('biomenu/bf'));
		boyfriend.scrollFactor.set(0, 0);
		boyfriend.updateHitbox();
		boyfriend.antialiasing = ClientPrefs.globalAntialiasing;
		//add(boyfriend);

		ethlyn = new FlxSprite(172, 220).loadGraphic(Paths.image('biomenu/ethlyn'));
		ethlyn.scrollFactor.set(0, 0);
		ethlyn.updateHitbox();
		ethlyn.antialiasing = ClientPrefs.globalAntialiasing;
		//add(ethlyn);

		laura = new FlxSprite(995, 315).loadGraphic(Paths.image('biomenu/laura'));
		laura.scrollFactor.set(0, 0);
		laura.updateHitbox();
		laura.antialiasing = ClientPrefs.globalAntialiasing;
		//add(laura);

		harper = new FlxSprite(865, 290).loadGraphic(Paths.image('biomenu/harper'));
		harper.scrollFactor.set(0, 0);
		harper.updateHitbox();
		harper.antialiasing = ClientPrefs.globalAntialiasing;
		//add(harper);

		add(ethlyn);
		add(alfie);
		add(pooky);
		add(laura);
		add(harper);	
		add(boyfriend);
		

		alfiedesc = new FlxSprite(250, 300).loadGraphic(Paths.image('biomenu/alfie description'));
		alfiedesc.scrollFactor.set(0, 0);
		alfiedesc.updateHitbox();
		alfiedesc.antialiasing = ClientPrefs.globalAntialiasing;
		alfiedesc.alpha = 0;
		add(alfiedesc);

		pookydesc = new FlxSprite(350, 300).loadGraphic(Paths.image('biomenu/pooky description'));
		pookydesc.scrollFactor.set(0, 0);
		pookydesc.updateHitbox();
		pookydesc.antialiasing = ClientPrefs.globalAntialiasing;
		pookydesc.alpha = 0;
		add(pookydesc);

		boyfrienddesc = new FlxSprite(450, 300).loadGraphic(Paths.image('biomenu/boyfriend description'));
		boyfrienddesc.scrollFactor.set(0, 0);
		boyfrienddesc.updateHitbox();
		boyfrienddesc.antialiasing = ClientPrefs.globalAntialiasing;
		boyfrienddesc.alpha = 0;
		add(boyfrienddesc);

		ethlyndesc = new FlxSprite(550, 300).loadGraphic(Paths.image('biomenu/ethlyn description'));
		ethlyndesc.scrollFactor.set(0, 0);
		ethlyndesc.updateHitbox();
		ethlyndesc.antialiasing = ClientPrefs.globalAntialiasing;
		ethlyndesc.alpha = 0;
		add(ethlyndesc);

		lauradesc = new FlxSprite(650, 300).loadGraphic(Paths.image('biomenu/laura description'));
		lauradesc.scrollFactor.set(0, 0);
		lauradesc.updateHitbox();
		lauradesc.antialiasing = ClientPrefs.globalAntialiasing;
		lauradesc.alpha = 0;
		add(lauradesc);

		harperdesc = new FlxSprite(750, 300).loadGraphic(Paths.image('biomenu/harper description'));
		harperdesc.scrollFactor.set(0, 0);
		harperdesc.updateHitbox();
		harperdesc.antialiasing = ClientPrefs.globalAntialiasing;
		harperdesc.alpha = 0;
		add(harperdesc);


		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);


		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{

			/*var offsetx:Float = 1 - 500;
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0 + offsetx, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			//menuItem.screenCenter(X);
			menuItem.x -= 500;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.9));
			menuItem.updateHitbox();
			//menuItem.x = -500; trace('hello???');*/
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		// NG.core.calls.event.logEvent('swag').send();

		//changeItem();

		

		super.create();

		FlxG.mouse.visible = true;
		FlxTween.tween(FlxG.mouse.cursorContainer, {alpha: 1}, 0.3);

	}

	var isMouseVisible = false;
	var mouseShowing:Float = 0;

	var canChange = true;


	var selectedSomethin:Bool = false;

	override function destroy() {
		super.destroy();
		FlxTween.cancelTweensOf(FlxG.mouse.cursorContainer);
		FlxG.mouse.cursorContainer.alpha = 1;
	}

	function checkOverlap(group:FlxSprite, heightExtend:Float = 0) {
		var mouse = FlxG.mouse.getPosition();

		var rect = FlxRect.weak(group.x, group.y - heightExtend/2, group.width, group.height + heightExtend);
		var val = mouse.inRect(rect);

		rect.putWeak();
		mouse.put();

		return val;
	}

	private var isShowingAlfie = false;
	
	override function update(elapsed:Float)
	{
				var isHoveringAlfie = checkOverlap(alfie, 0);
				var isHoveringPooky = checkOverlap(pooky, 0);
				var isHoveringLaura = checkOverlap(laura, 0);
				var isHoveringEthlyn = checkOverlap(ethlyn, 0);
				var isHoveringHarper = checkOverlap(harper, 0);
				var isHoveringBoyfriend = checkOverlap(boyfriend, 0);

		if(canChange) {
			if(FlxG.mouse.justPressed) {

			if(isHoveringAlfie && !isShowingAlfie) {
				isShowingAlfie = true;
				if (alfie.colorTransform.redOffset == 0)
				{
				//FlxTween.tween(alfie.colorTransform, {redOffset: 22, blueOffset: 22, greenOffset: 22}, 0.6);
				}
				FlxTween.tween(alfiedesc, {alpha: 1}, 0.6); 
				FlxTween.color(harper, 0.6, harper.color, 0xFF56526B);
				FlxTween.color(ethlyn, 0.6, ethlyn.color, 0xFF56526B);
				FlxTween.color(pooky, 0.6, pooky.color, 0xFF56526B);
				FlxTween.color(boyfriend, 0.6, boyfriend.color, 0xFF56526B);
				FlxTween.color(laura, 0.6, laura.color, 0xFF56526B);
				FlxTween.color(bg, 0.6, bg.color, 0xFF56526B);
			}

			if(!isHoveringAlfie && isShowingAlfie) {
				isShowingAlfie = false;
				if (alfie.colorTransform.redOffset != 0)
				{
				//FlxTween.tween(alfie.colorTransform, {redOffset: 0, blueOffset: 0, greenOffset: 0}, 0.6);
				}
				FlxTween.tween(alfiedesc, {alpha: 0}, 0.3); 
				FlxTween.color(harper, 0.3, 0xFF56526B, harper.color);
				FlxTween.color(ethlyn, 0.3, 0xFF56526B, ethlyn.color);
				FlxTween.color(pooky, 0.3, 0xFF56526B, pooky.color);
				FlxTween.color(boyfriend, 0.3, 0xFF56526B, boyfriend.color);
				FlxTween.color(laura, 0.3, 0xFF56526B, laura.color);
				FlxTween.color(bg, 0.3, 0xFF56526B, bg.color);
			}

			}
		}
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}



		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			/*if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}*/

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

			/*if (controls.ACCEPT)
			{
			
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

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
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
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
			#end*/
		}

		super.update(elapsed);

		/*menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});*/
	}

	/*function changeItem(huh:Int = 0)
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
	}*/









}
