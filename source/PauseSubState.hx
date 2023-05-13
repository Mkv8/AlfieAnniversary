package;

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

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Exit to menu'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	//var botplayText:FlxText;


	var dots:FlxSprite;
	var bells:FlxBackdrop;
	var overlay:FlxSprite;
	var bars:FlxSprite;
	
	public var skipFirstFrame = true;

	public function new(x:Float, y:Float)
	{
		super();

		if(PlayState.instance.formattedSong == "minimize"  && PlayState.instance.isMinimizeBroken == true)
			{
			menuItemsOG = ['Resume', 'Exit to menu'];

			}

		if(CoolUtil.difficulties.length < 2) menuItemsOG.remove('Change Difficulty'); //No need to change difficulty if there is only one!

		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Toggle Practice Mode');
			menuItemsOG.insert(3, 'Toggle Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg = new FlxSpriteExtra().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.0001;
		bg.scrollFactor.set();
		

		dots = new FlxSprite(0, 380).loadGraphic(Paths.image('pausedots'));

		bells = new FlxBackdrop(Paths.image('pausebells'), 0.2, 0, true, true);
		bells.velocity.set(120, 50);
		bells.updateHitbox();
		bells.screenCenter(XY);
		bells.antialiasing = ClientPrefs.globalAntialiasing;

		overlay = new FlxSprite().loadGraphic(Paths.image('pauseoverlay'));
		bars = new FlxSprite(-600, 0).loadGraphic(Paths.image('pausebars'));
		dots.alpha = 0.0001;
		bells.alpha = 0.0001;
		overlay.alpha = 0.0001;
		bars.alpha = 0.0001;
		overlay.blend = OVERLAY;

		add(bg);
		add(dots);
		add(bells);
		add(overlay);
		add(bars);
		
		if(PlayState.instance.formattedSong == "minimize"  && PlayState.instance.isMinimizeBroken == true)
		{
		remove(bg);
		remove(dots);
		remove(bells);
		remove(overlay);
		remove(bars);
		}



		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);


		if(PlayState.instance.formattedSong == "minimize"  && PlayState.instance.isMinimizeBroken == true)
		{
		var minimizetext:FlxText = new FlxText(20, 15 + 101, 0, "YOU CAN'T HIDE FROM ME.", 32);
		minimizetext.scrollFactor.set();
		minimizetext.setFormat(Paths.font('vcr.ttf'), 32);
		minimizetext.screenCenter(X);
		minimizetext.y = FlxG.height - (minimizetext.height + 70);
		minimizetext.updateHitbox();
		minimizetext.visible = true;
		add(minimizetext);

		new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				FlxTween.tween(minimizetext, {alpha: 1}, 0.5, {ease: FlxEase.quartInOut});
			});
		}

		FlxTween.tween(dots, {alpha: 0.6}, 0.6, {ease: FlxEase.quartInOut});
		FlxTween.tween(bells, {alpha: 0.5}, 0.8, {ease: FlxEase.quartInOut});
		FlxTween.tween(overlay, {alpha: 0.3}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(bars, {alpha: 0.4}, 1.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(bars,{x: -1}, 1.4, {ease: FlxEase.expoInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);


		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
			
			if(PlayState.instance.formattedSong == "minimize"  && PlayState.instance.isMinimizeBroken == true)
			{
				songText.y += 120;
				songText.isMenuItem = false;
				songText.screenCenter(X);
			}
		}


		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{

		if(skipFirstFrame) {skipFirstFrame = false; return;}

		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;


		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		
		if(controls.BACK) {close();}


		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			if(daSelected != 'BACK' && difficultyChoices.contains(daSelected)) {
				//var name:String = PlayState.SONG.song.toLowerCase();
				//var poop = Highscore.formatSong(name, curSelected);
				var diffic = Highscore.formatSong("", curSelected);
				if (PlayState.instance.formattedSong != "pasta-night") {
					var name:String = PlayState.SONG.song.toLowerCase();
						PlayState.SONG = Song.loadFromJson(name + diffic, name);
				}
				else
				{
					var kisston = Song.loadFromJson("pasta-night" + diffic + '-k', "pasta-night");
					var alfie = Song.loadFromJson("pasta-night" + diffic + '-a', "pasta-night");
					var filip = Song.loadFromJson("pasta-night" + diffic + '-f', "pasta-night");
		
					switch(PlayState.bihNum)
					{
						case 0:
							PlayState.SONG = kisston;
							PlayState.ectSONGS = [filip, alfie];
						case 1:
							PlayState.SONG = filip;
							PlayState.ectSONGS = [kisston, alfie];
						case 2:
							PlayState.SONG = alfie;
							PlayState.ectSONGS = [kisston, filip];
					}
				}
				PlayState.storyDifficulty = curSelected;
				MusicBeatState.resetState();
				FlxG.sound.music.volume = 0;
				PlayState.changedDifficulty = true;
				PlayState.chartingMode = false;
				return;
			}

			switch (daSelected)
			{
				case "Resume":
					close();
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					regenMenu();
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart Song":
					restartSong();
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case "Exit to menu":

					if(PlayState.instance.formattedSong == "minimize" && PlayState.instance.isMinimizeBroken == true)
					{
						PlayState.instance.health = -10;
						close();
						return;
					}

					PlayState.instance.exiting = true;

					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					if(PlayState.isStoryMode) {
						MusicBeatState.switchState(new StoryMenuState());
					} else {
						MusicBeatState.switchState(new FreeplayState());
					}
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;



				case 'BACK':
					menuItems = menuItemsOG;
					regenMenu();
			}
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);
		}
		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
}
