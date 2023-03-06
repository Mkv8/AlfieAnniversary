package;

import flixel.system.FlxSound;
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
#if ACHIEVEMENTS_ALLOWED
import Achievements;
#end
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import openfl.filters.ShaderFilter;

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
	var debugKeys:Array<FlxKey>;
	var alfie:FlxSprite;
	var boyfriend:FlxSprite;
	var pooky:FlxSprite;
	var ethlyn:FlxSprite;
	var harper:FlxSprite;
	var laura:FlxSprite;

	var darken:FlxSprite;

	var clicksound:FlxSound;

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
		DiscordClient.changePresence("Reading up on character bios!", null);
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


		alfiedesc = new FlxSprite(395, 200).loadGraphic(Paths.image('biomenu/alfie description'));
		alfiedesc.scrollFactor.set(0, 0);
		alfiedesc.updateHitbox();
		alfiedesc.antialiasing = ClientPrefs.globalAntialiasing;
		alfiedesc.alpha = 0;
		add(alfiedesc);

		pookydesc = new FlxSprite(580, 80).loadGraphic(Paths.image('biomenu/pooky description'));
		pookydesc.scrollFactor.set(0, 0);
		pookydesc.updateHitbox();
		pookydesc.antialiasing = ClientPrefs.globalAntialiasing;
		pookydesc.alpha = 0;
		add(pookydesc);

		boyfrienddesc = new FlxSprite(170, 200).loadGraphic(Paths.image('biomenu/boyfriend description'));
		boyfrienddesc.scrollFactor.set(0, 0);
		boyfrienddesc.updateHitbox();
		boyfrienddesc.antialiasing = ClientPrefs.globalAntialiasing;
		boyfrienddesc.alpha = 0;
		add(boyfrienddesc);

		ethlyndesc = new FlxSprite(300, 130).loadGraphic(Paths.image('biomenu/ethlyn description'));
		ethlyndesc.scrollFactor.set(0, 0);
		ethlyndesc.updateHitbox();
		ethlyndesc.antialiasing = ClientPrefs.globalAntialiasing;
		ethlyndesc.alpha = 0;
		add(ethlyndesc);

		lauradesc = new FlxSprite(280, 200).loadGraphic(Paths.image('biomenu/laura description'));
		lauradesc.scrollFactor.set(0, 0);
		lauradesc.updateHitbox();
		lauradesc.antialiasing = ClientPrefs.globalAntialiasing;
		lauradesc.alpha = 0;
		add(lauradesc);

		harperdesc = new FlxSprite(200, 200).loadGraphic(Paths.image('biomenu/harper description'));
		harperdesc.scrollFactor.set(0, 0);
		harperdesc.updateHitbox();
		harperdesc.antialiasing = ClientPrefs.globalAntialiasing;
		harperdesc.alpha = 0;
		add(harperdesc);

		clicksound = new FlxSound().loadEmbedded(Paths.sound("harpermeow"));
		add(clicksound);

		cursortext = new FlxSprite(30, 10).loadGraphic(Paths.image('biomenu/cursor'));
		cursortext.scrollFactor.set(0, 0);
		cursortext.updateHitbox();
		cursortext.antialiasing = ClientPrefs.globalAntialiasing;
		add(cursortext);

		backbutton = new FlxSprite(30, 650).loadGraphic(Paths.image('biomenu/backnobg'));
		backbutton.scrollFactor.set(0, 0);
		backbutton.updateHitbox();
		backbutton.antialiasing = ClientPrefs.globalAntialiasing;
		add(backbutton);






		super.create();

		FlxG.mouse.visible = true;
		FlxTween.tween(FlxG.mouse.cursorContainer, {alpha: 1}, 0.3);

		for(spr in members) {
			if((spr is FlxSprite)) {
				var spr:FlxSprite = cast spr;
				spr.color = 0xFF000000 | spr.color;
			}
		}

	}

	var isMouseVisible = false;
	var mouseShowing:Float = 0;

	var canChange = true;


	var selectedSomethin:Bool = false;

	override function destroy() {
		super.destroy();
		FlxTween.cancelTweensOf(FlxG.mouse.cursorContainer);
		FlxG.mouse.cursorContainer.alpha = 1;
		FlxG.mouse.visible = false;
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
	private var isShowingHarper = false;
	private var isShowingPooky = false;
	private var isShowingEthlyn = false;
	private var isShowingLaura = false;
	private var isShowingBoyfriend = false;
	private var isShowingBack = false;

	function fixColorTween(?Sprite:FlxSprite, Duration:Float = 1, FromColor:FlxColor, ToColor:FlxColor, ?Options:TweenOptions) {
		FlxTween.cancelTweensOf(Sprite);
		FlxTween.color(Sprite, Duration, FromColor, ToColor, Options);
	}

	override function update(elapsed:Float)
	{

		super.update(elapsed);
		FlxG.mouse.visible = true;


		if(canChange) {
			if(FlxG.mouse.justPressed) {
				var isHoveringAlfie = checkOverlap(alfie, 0);
				var isHoveringPooky = checkOverlap(pooky, 0);
				var isHoveringLaura = checkOverlap(laura, 0);
				var isHoveringEthlyn = checkOverlap(ethlyn, 0);
				var isHoveringHarper = checkOverlap(harper, 0);
				var isHoveringBoyfriend = checkOverlap(boyfriend, 0);
				var isHoveringBack = checkOverlap(backbutton, 20);

				if(isHoveringAlfie) isHoveringEthlyn = false;
				if(isHoveringHarper) isHoveringLaura = false;
				if(isHoveringHarper) isHoveringBoyfriend = false;
				if(isHoveringBoyfriend) isHoveringHarper = false;
				if(isHoveringBoyfriend) isHoveringLaura = false;
				if(isHoveringPooky) isHoveringAlfie = false;
				if(isHoveringEthlyn) isHoveringAlfie = false;

				var shouldShowBg = isHoveringAlfie||isHoveringPooky||isHoveringLaura||isHoveringEthlyn||isHoveringHarper||isHoveringBoyfriend;

				if(isHoveringBack && !isShowingBack) {
					isShowingBack = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new MainMenuState());
				}

				//alfie
				if(isHoveringAlfie && !isShowingAlfie) {
					isShowingAlfie = true;

					FlxTween.tween(alfiedesc, {alpha: 1}, 0.6);
					FlxG.sound.play(Paths.sound('alfiebaa'));
					/*clicksound = new FlxSound().loadEmbedded(Paths.sound("alfiebaa"));
					clicksound.play(true);*/

				}
				if(!isHoveringAlfie && isShowingAlfie) {
					isShowingAlfie = false;

					FlxTween.tween(alfiedesc, {alpha: 0}, 0.3);
				}

				//harper
				if(isHoveringHarper && !isShowingHarper) {
					isShowingHarper = true;

					FlxTween.tween(harperdesc, {alpha: 1}, 0.6);
					clicksound = new FlxSound().loadEmbedded(Paths.sound("harpermeow"));
					clicksound.play(true);
				}

				if(!isHoveringHarper && isShowingHarper) {
					isShowingHarper = false;

					FlxTween.tween(harperdesc, {alpha: 0}, 0.3);
				}

				//ethlyn Ethlyn
				if(isHoveringEthlyn && !isShowingEthlyn) {
					isShowingEthlyn = true;

					FlxTween.tween(ethlyndesc, {alpha: 1}, 0.6);
					clicksound = new FlxSound().loadEmbedded(Paths.sound("ethlynbat"));
					clicksound.play(true);
				}

				if(!isHoveringEthlyn && isShowingEthlyn) {
					isShowingEthlyn = false;

					FlxTween.tween(ethlyndesc, {alpha: 0}, 0.3);
				}

				//laura Laura
				if(isHoveringLaura && !isShowingLaura) {
					isShowingLaura = true;

					FlxTween.tween(lauradesc, {alpha: 1}, 0.6);
					clicksound = new FlxSound().loadEmbedded(Paths.sound("laurasqueak"));
					clicksound.play(true);
				}

				if(!isHoveringLaura && isShowingLaura) {
					isShowingLaura = false;

					FlxTween.tween(lauradesc, {alpha: 0}, 0.3);
				}

				//pooky Pooky
				if(isHoveringPooky && !isShowingPooky) {
					isShowingPooky = true;

					FlxTween.tween(pookydesc, {alpha: 1}, 0.6);
					clicksound = new FlxSound().loadEmbedded(Paths.sound("ghostmelody"));
					clicksound.play(true);
				}

				if(!isHoveringPooky && isShowingPooky) {
					isShowingPooky = false;

					FlxTween.tween(pookydesc, {alpha: 0}, 0.3);
				}


				//boyfriend Boyfriend
				if(isHoveringBoyfriend && !isShowingBoyfriend) {
					isShowingBoyfriend = true;

					FlxTween.tween(boyfrienddesc, {alpha: 1}, 0.6);
					clicksound = new FlxSound().loadEmbedded(Paths.sound("boobf"));
					clicksound.play(true);
				}

				if(!isHoveringBoyfriend && isShowingBoyfriend) {
					isShowingBoyfriend = false;

					FlxTween.tween(boyfrienddesc, {alpha: 0}, 0.3);
				}

				fixColorTween(alfie, 0.3, alfie.color, 0xFFFFFFFF);
				fixColorTween(ethlyn, 0.3, ethlyn.color, 0xFFFFFFFF);
				fixColorTween(laura, 0.3, laura.color, 0xFFFFFFFF);
				fixColorTween(pooky, 0.3, pooky.color, 0xFFFFFFFF);
				fixColorTween(harper, 0.3, harper.color, 0xFFFFFFFF);
				fixColorTween(boyfriend, 0.3, boyfriend.color, 0xFFFFFFFF);

				if(shouldShowBg) {
					fixColorTween(bg, 0.6, bg.color, 0xFF56526B);

					if(!isShowingAlfie) fixColorTween(alfie, 0.6, alfie.color, 0xFF56526B);
					if(!isShowingHarper) fixColorTween(harper, 0.6, harper.color, 0xFF56526B);
					if(!isShowingEthlyn) fixColorTween(ethlyn, 0.6, ethlyn.color, 0xFF56526B);
					if(!isShowingPooky) fixColorTween(pooky, 0.6, pooky.color, 0xFF56526B);
					if(!isShowingBoyfriend) fixColorTween(boyfriend, 0.6, boyfriend.color, 0xFF56526B);
					if(!isShowingLaura) fixColorTween(laura, 0.6, laura.color, 0xFF56526B);
				} else {
					fixColorTween(bg, 0.3, bg.color, 0xFFFFFFFF);
				}

			}
		}
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		}
	}

}
