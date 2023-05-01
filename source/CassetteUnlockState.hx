package;

import openfl.filters.ShaderFilter;
import shaders.FastBlurShader;
import flixel.util.FlxTimer;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;

class CassetteUnlockState extends MusicBeatSubstate
{
	var cam:FlxCamera;

	var blur:FastBlurShader;

	var cassette1:Cassette;
	var cassette2:Cassette;
	var cassette3:Cassette;
	var unlocktext:Alphabet;
	var unlocktext2:Alphabet;


	public override function create()
	{
		super.create();

		unlocktext = new Alphabet(0, 70, "New songs unlocked!", true);
		unlocktext.scale.set(0.9, 0.9);
		unlocktext.screenCenter(X);
		unlocktext.alpha = 0.0001;
		FlxTween.tween(unlocktext, {alpha: 1}, 0.3, {ease: FlxEase.quartInOut, startDelay: 0.9});

		unlocktext2 = new Alphabet(0, 550, "Press ENTER to continue.", true);
		unlocktext2.scale.set(0.7, 0.7);
		unlocktext2.screenCenter(X);
		unlocktext2.alpha = 0.0001;
		FlxTween.tween(unlocktext2, {alpha: 1}, 0.3, {ease: FlxEase.quartInOut, startDelay: 0.9});

		add(unlocktext);
		add(unlocktext2);

		blur = new FastBlurShader();
		blur.blur = 0.0;
		blur.brightness = 1.0;

		cam = new FlxCamera();
		cam.bgColor.alpha = 0;
		FlxG.cameras.add(cam, false);
		FlxG.cameras.list[FlxG.cameras.list.indexOf(cam) - 1].setFilters([new ShaderFilter(blur)]);

		//var bg = new FlxSpriteExtra().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
		//bg.alpha = 0.0001;
		//bg.scrollFactor.set();

		//FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(blur, {brightness: 0.4, blur: 0.05}, 0.8, {ease: FlxEase.quartInOut});

		cassette1 = new Cassette("week93", false, false);
		cassette2 = new Cassette("week94", false, false);
		cassette3 = new Cassette("week95", false, false);

		var cassettes = [cassette1, cassette2, cassette3];

		for(i => cass in cassettes) {
			FlxTween.tween(cass, {alpha: 1}, 0.3, {ease: FlxEase.quartInOut, startDelay: 0.9});
			cass.active = false;
			cass.alpha = 0.00001;
			//cass.defaultX = 30;
			//cass.defaultY = 200 * i + 100;
			cass.scale.set(0.8, 0.8);
			cass.updateHitbox();
			cass.scrollFactor.set(0, 0);

			//cass.x = cass.defaultX;
			cass.screenCenter(X);
			cass.y = 300;

			add(cass);
		}

		cassette1.x -= 350;
		cassette3.x += 350;

		//ref = new FlxSprite(Paths.image('cassettes/ref'));
		//ref.alpha = 0.00001;
		//ref.screenCenter();
		//add(ref);

		var parent:StoryMenuState = cast @:privateAccess this._parentState;

		parent.grpCassette.members[parent.weekMap["week93"]].loadDifficulty();
		parent.grpCassette.members[parent.weekMap["week94"]].loadDifficulty();
		parent.grpCassette.members[parent.weekMap["week95"]].loadDifficulty();
		parent.grpCassette.members[parent.weekMap["week93"]].lock();
		parent.grpCassette.members[parent.weekMap["week94"]].lock();
		parent.grpCassette.members[parent.weekMap["week95"]].lock();

		cameras = [cam];//[FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		FlxG.sound.play(Paths.sound('newsongsunlocked'));

	}

	var closing:Bool = false;

	override function update(elapsed:Float)
	{
		var self = this;
		super.update(elapsed);

		if(controls.ACCEPT && !closing) {
			closing = true;
			var cassettes = [cassette1, cassette2, cassette3];
			FlxTween.tween(unlocktext, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(unlocktext2, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});

			for(i => cass in cassettes) {
				FlxTween.tween(cass, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			}

			@:privateAccess {
				FlxTween.tween(blur, {brightness: 1.0, blur: 0.00}, 0.6, {
					ease: FlxEase.quartInOut,
					startDelay: 0.3,
					onComplete: (_) -> {
						var parent:StoryMenuState = cast @:privateAccess self._parentState;
						close();

						parent.allowChanging = false;

						new FlxTimer().start(0.08, (_) -> {
							new FlxTimer().start(0.1, (tmr) -> {
								var wantedI = parent.weekMap["week94"];
								if(wantedI - parent.curWeek > 0) {
									parent.changeWeek(1);
									FlxG.sound.play(Paths.sound('scrollMenu'));
									tmr.reset(0.1);
								} else {
									new FlxTimer().start(0.4, (_) -> {
										FlxG.sound.play(Paths.sound('unlocking'));
										parent.grpCassette.members[parent.weekMap["week93"]].shakeDuration = 1;
										parent.grpCassette.members[parent.weekMap["week94"]].shakeDuration = 1;
										parent.grpCassette.members[parent.weekMap["week95"]].shakeDuration = 1;


										new FlxTimer().start(1, (_) -> {
											parent.camera.flash(-1, 0.3);
											FlxG.sound.play(Paths.sound('unlocked'));
											parent.allowChanging = true;
											parent.grpCassette.members[parent.weekMap["week93"]].unlock();
											parent.grpCassette.members[parent.weekMap["week94"]].unlock();
											parent.grpCassette.members[parent.weekMap["week95"]].unlock();

										});
									});
								}
							});
						});
					}
				});
			}
		}
	}

	override function destroy()
	{
		FlxG.cameras.list[FlxG.cameras.list.indexOf(cam) - 1].setFilters([]);
		FlxG.cameras.remove(cam, true);
		unlocktext.kill();
		unlocktext2.kill();

		super.destroy();
	}
}
