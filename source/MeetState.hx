package;

import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class MeetState extends MusicBeatState
{
	public var leftState:Bool = false;
	public var bg:BGSprite;
	public var text:BGSprite;
	public var enter:BGSprite;
	//public var bg:BGSprite;
	var menuMusic:FlxSound;
	var shouldEnterFade:Bool = false;

	override function create()
	{
		super.create();
		leftState = false;
		if(Paths.formatToSongPath(PlayState.SONG.song) == "heart-attack")
			{
			bg = new BGSprite ('kisstonmeet', 0, 0, 1, 1);
			bg.setGraphicSize(FlxG.width, FlxG.height);
			bg.alpha = 0.0001;
			bg.screenCenter(XY);

			text = new BGSprite ('kisstontext', 180, -600, 1, 1);
			text.alpha = 0.0001;
			text.scale.set(0.65, 0.65);

			FlxG.sound.playMusic(Paths.music('kisstonbreakfast'), 0, true);


			}

		if(Paths.formatToSongPath(PlayState.SONG.song) == "jelly-jamboree")
			{
			bg = new BGSprite ('kaimeet', 0, 0, 1, 1);
			bg.setGraphicSize(FlxG.width, FlxG.height);
			bg.alpha = 0.0001;
			bg.screenCenter(XY);

			text = new BGSprite ('kaitext', 180, -600, 1, 1);
			text.alpha = 0.0001;
			text.scale.set(0.65, 0.65);

			FlxG.sound.playMusic(Paths.music('kaibreakfast'), 0, true);

			}

			
			enter = new BGSprite ('kisstonenter', 0, 0, 1, 1);
			enter.scale.set(0.6, 0.6);
			enter.x = FlxG.width - (enter.width - 90);
			enter.y = FlxG.height - (enter.height + 5);
			enter.alpha = 0.0001;


		add(bg);
		add(text);
		add(enter);

		new FlxTimer().start(0.8, function(tmr:FlxTimer)
			{
				FlxTween.tween(bg,{alpha: 1}, 1.3, {ease: FlxEase.expoInOut});
				FlxTween.tween(text,{alpha: 1}, 1.3, {ease: FlxEase.expoInOut});
				FlxTween.tween(text,{y: -80}, 1.8, {ease: FlxEase.expoInOut});
                FlxTween.tween(enter,{alpha: 1}, 1.3, {
					startDelay: 1.7,
					onComplete: (_) -> {shouldEnterFade = true;}
				});
			});

		FlxG.sound.music.fadeIn(0.55, 0.5);

	}

	override function update(elapsed:Float)
	{


		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				FlxG.sound.music.fadeOut(0.8, 0);
				FlxG.sound.play(Paths.sound('confirmMenu'));
				new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						LoadingState.loadAndSwitchState(new PlayState(), true);

					});
			}
		}
		super.update(elapsed);

			if(FlxMath.equal(enter.alpha, 1) && shouldEnterFade)
			FlxTween.tween(enter, {alpha: 0.1}, 2);

			if (FlxMath.equal(enter.alpha, 0.1) && shouldEnterFade)
			FlxTween.tween(enter, {alpha: 1}, 2);
			
	}
}
