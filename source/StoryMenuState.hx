package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import WeekData;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	// Wether you have to beat the previous week for playing this one
	// Not recommended, as people usually download your mod for, you know,
	// playing just the modded week then delete it.
	// defaults to True
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	public static var forceUnlock:Bool = false;

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	private var curWeek(get, never):Int;
	function get_curWeek() {
		return CoolUtil.mod(_curWeek, WeekData.weeksList.length);
	}
	private static var _curWeek:Int = 0;

	//var txtTracklist:FlxText;

	public var grpCassette:FlxTypedGroup<Cassette>;

	//var difficultySelectors:FlxGroup;
	//var sprDifficulty:FlxSprite;
	//var leftArrow:FlxSprite;
	//var rightArrow:FlxSprite;

	var oldtimes:FlxSprite;
	var specters:FlxSprite;
	var erect:FlxSprite;

	var afterdark:FlxSprite;
	var mansionmatch:FlxSprite;
	var candle:FlxSprite;
	var anime:FlxSprite;
	var goat:FlxSprite;
	var ourple:FlxSprite;
	var ska:FlxSprite;
	var kisston:FlxSprite;
	var kai:FlxSprite;
	var pasta:FlxSprite;

	var choosingbih = false;
	var blackOverlay:FlxSprite;
	var bihText:FlxText;
	var icons:Array<HealthIcon> = [];
	var handSelect:FlxSprite;
	var curBih = 0;

	public var weekMap:Map<String, Int> = [];

	var newUnlockedSongs:Array<String>;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) _curWeek = 0;
		persistentUpdate = persistentDraw = true;

		newUnlockedSongs = LockManager.getNewlyUnlockedSongs();

		scoreText = new FlxFixedText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);


		txtWeekTitle = new FlxFixedText(FlxG.width * 0.7, 10, 0, "", 40);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 1;

		oldtimes = new FlxSprite().loadGraphic(Paths.image('oldtimes'));
		specters = new FlxSprite().loadGraphic(Paths.image('specters'));
		erect = new FlxSprite().loadGraphic(Paths.image('erect'));

		afterdark = new FlxSprite().loadGraphic(Paths.image('afterdarkbg'));
		mansionmatch = new FlxSprite().loadGraphic(Paths.image('hotlinebg'));
		candle = new FlxSprite().loadGraphic(Paths.image('candleebg'));
		anime = new FlxSprite().loadGraphic(Paths.image('90sbga'));
		goat = new FlxSprite().loadGraphic(Paths.image('goatbg'));
		ourple = new FlxSprite().loadGraphic(Paths.image('ourplembg'));
		ska = new FlxSprite().loadGraphic(Paths.image('skabg'));
		kisston = new FlxSprite().loadGraphic(Paths.image('kisstonbg'));
		kai = new FlxSprite().loadGraphic(Paths.image('kaimenubg'));
		pasta = new FlxSprite().loadGraphic(Paths.image('pastamenubg'));

		var bgs = [oldtimes, specters, erect, afterdark, mansionmatch, candle, anime, goat, ourple, ska, kisston, kai, pasta];

		for(bg in bgs) {
			bg.active = false;
			bg.antialiasing = ClientPrefs.globalAntialiasing;
			add(bg);
		}

		updateBackground(true);

		bgSprite = new FlxSprite(0, 56);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		grpCassette = new FlxTypedGroup<Cassette>();

		var blackBarThingie:FlxSprite = new FlxSpriteExtra().makeSolid(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Choosing a song...", null);
		#end

		for (i in 0...WeekData.weeksList.length)
		{
			WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[i]));
			var weekThing:Cassette = new Cassette(WeekData.weeksList[i], weekIsUnlocked(i));
			//weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetItem = i - curWeek;
			grpCassette.add(weekThing);

			weekMap[WeekData.weeksList[i]] = i;

			//weekThing.screenCenter(X);
			//weekThing.antialiasing = ClientPrefs.globalAntialiasing;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			/*if (weekIsLocked(i))
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = ClientPrefs.globalAntialiasing;
				grpLocks.add(lock);
			}*/
		}

		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));

		if(CoolUtil.difficulties.length == 0) {
			CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		}
		if(lastDifficultyName == '') {
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.difficulties.indexOf(lastDifficultyName)));

		/*difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpCassette.members[0].x + grpCassette.members[0].width + 10, grpCassette.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(leftArrow);*/

		/*sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;

		difficultySelectors.add(sprDifficulty);*/

		/*rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(rightArrow);*/
		changeDifficulty();

		add(bgSprite);

		//var tracksSprite:FlxSprite = new FlxSprite(FlxG.width * 0.07, 56 + 425).loadGraphic(Paths.image('Menu_Tracks'));
		//tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		//add(tracksSprite);

		//txtTracklist = new FlxFixedText(FlxG.width * 0.05, tracksSprite.y + 60, 0, "", 32);
		//txtTracklist.alignment = CENTER;
		//txtTracklist.font = Paths.font("vcr.ttf");
		//txtTracklist.color = 0xFFe55777;
		//add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		add(grpCassette);

		changeWeek();

		makeOverlay(); // Maybe optimize to make it happen later

		super.create();
	}

	function makeOverlay() {
		blackOverlay = new FlxSpriteExtra(0, 0).makeSolid(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		blackOverlay.screenCenter();
		blackOverlay.alpha = 0;
		add(blackOverlay);

		bihText = new FlxFixedText(FlxG.width * 0.7, -300, 0, "Choose your player", 40);
		bihText.setFormat("VCR OSD Mono", 90, FlxColor.WHITE, RIGHT);
		add(bihText);
		bihText.screenCenter(X);

		var names = ["icon-kisstonpasta", "icon-filippasta", "icon-alfiepasta"];
		var poses = [new FlxPoint(268,452),new FlxPoint(568,452),new FlxPoint(868,452)];

		for (e in 0...names.length)
		{
			var i = new HealthIcon(names[e], false);
			i.alpha = 0;
			i.setPosition(poses[e].x,poses[e].y);
			add(i);
			icons.push(i);
		}

		handSelect = new FlxSprite(handxpos, 362).loadGraphic(Paths.image('hand_textbox'));
		handSelect.setGraphicSize(Std.int(handSelect.width * PlayState.daPixelZoom * 1.15));
		handSelect.angle = 90;
		handSelect.updateHitbox();
		handSelect.alpha = 0;
		add(handSelect);
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	var didResetTo0 = false;
	var firstFrame = true;
	var allowChanging = true;
	var fml = 0.0;
	var handxpos:Float = 275;

	var waitTime = 0.2;

	override function update(elapsed:Float)
	{
		if(waitTime > 0) {
			waitTime -= elapsed;
			if(waitTime <= 0) {
				if(newUnlockedSongs.length > 0) {
					persistentUpdate = false;
					openSubState(new CassetteUnlockState());
				}
			}
		}

		var lerpVal = CoolUtil.boundTo(1 - (elapsed * 9), 0, 1);
		if (fml != -1)
		{
			fml += elapsed*2;

			handSelect.y = 362 - Math.cos(fml) * 10;
		}
		handSelect.x = FlxMath.lerp(handxpos, handSelect.x, lerpVal);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (fml != -1) {
			for (i in icons)
			{
				var mult:Float = FlxMath.lerp(1, i.scale.x, lerpVal);
				i.scale.set(mult, mult);
				i.updateHitbox();
			}
		}


		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "SONG SCORE:" + lerpScore;
		scoreText.y = 450;

		// FlxG.watch.addQuick('font', scoreText.font);

		//difficultySelectors.visible = !weekIsLocked(curWeek);

		if(!movedBack && !selectedWeek && !allowChanging && !choosingbih) {
			if (controls.UI_UP_P)
				changeDiffNumber(1);
			else if (controls.UI_DOWN_P)
				changeDiffNumber(-1);
		}

		if (!movedBack && !selectedWeek && allowChanging && !choosingbih)
		{
			var upP = controls.UI_LEFT_P;
			var downP = controls.UI_RIGHT_P;
			if (upP)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (downP)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			/*if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');*/

			if(grpCassette.members[curWeek].isUnlocked) {
				if (controls.UI_UP_P)
					changeDifficulty(1);
				else if (controls.UI_DOWN_P)
					changeDifficulty(-1);
			}

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				var week = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
				persistentUpdate = false;
				openSubState(new ResetScoreSubState(week.songs[0][0], curDifficulty, week.songs[0][1]));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				selectWeek(curWeek);
			}
		}
		else if (choosingbih)
		{
			if (controls.UI_RIGHT_P)
				changeBih(1);
			else if (controls.UI_LEFT_P)
				changeBih(-1);
			else if (controls.ACCEPT)
			{
				selectWeek(curWeek,true);
			}
		}

		if(FlxG.keys.justPressed.H) {
			persistentUpdate = false;
			openSubState(new CassetteUnlockState());
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		firstFrame = false;
	}

	function changeBih(n:Int) {
		curBih += n;
		if (curBih == -1)
			curBih = 2;
		if (curBih == 3)
			curBih = 0;

		switch(curBih)
		{
			case 0:
				handxpos = 275;
			case 1:
				handxpos = 575;
			case 2:
				handxpos = 875;
		}
	}

	function openChoosing() {
		choosingbih = true;

		for (i in icons)
			FlxTween.tween(i, {alpha: 1}, 0.75);

		FlxTween.tween(blackOverlay, {alpha: 0.75}, 0.75);
		FlxTween.tween(handSelect, {alpha: 1}, 0.75);
		FlxTween.tween(bihText, {y: bihText.y + 400}, 0.75, {ease: FlxEase.backOut});
	}

	override function beatHit()
	{
		if (fml == -1)
			return;
		for (i in icons)
		{
			i.scale.set(1.2, 1.2);
			i.updateHitbox();
		}
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;

	function selectWeek(wNum:Int,selectPasta = false)
	{
		if(!grpCassette.members[wNum].isUnlocked) {
			grpCassette.members[wNum].shakeDuration = 0.3;
			return;
		}

		if (wNum == 14 && !selectPasta)
		{
			openChoosing();
			return;
		}
		else if (selectPasta)
		{
			fml = -1;
			handSelect.y += 30;
			FlxTween.tween(handSelect, {y: handSelect.y - 25}, 0.3, {ease: FlxEase.cubeOut});
			var chosen = [0,1,2];
			chosen.remove(curBih);
			for (i in chosen)
				icons[i].animation.curAnim.curFrame = 1;

			icons[curBih].scale.set(1.5,0.5);
			FlxTween.tween(icons[curBih], {"scale.y":1,"scale.x":1}, 0.8, {ease: FlxEase.elasticOut});
		}

		FlxG.sound.play(Paths.sound('confirmMenu'));

		// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
		var songArray:Array<String> = [];
		var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).songs;
		for (i in 0...leWeek.length) {
			songArray.push(leWeek[i][0]);
		}

		// Nevermind that's stupid lmao
		PlayState.storyPlaylist = songArray;
		PlayState.isStoryMode = true;
		selectedWeek = true;

		var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
		if(diffic == null) diffic = '';

		PlayState.storyDifficulty = curDifficulty;

		if (!selectPasta)
			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
		else
		{
			var kisston = Song.loadFromJson("pasta-night" + diffic + '-k', "pasta-night");
			var alfie = Song.loadFromJson("pasta-night" + diffic + '-a', "pasta-night");
			var filip = Song.loadFromJson("pasta-night" + diffic + '-f', "pasta-night");

			switch(curBih)
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

		PlayState.campaignScore = 0;
		PlayState.campaignMisses = 0;
		PlayState.bihNum = curBih;

		for(cassette in grpCassette) {
			if(cassette.targetItem != 0) {
				FlxTween.tween(cassette, {selectAngleOffset: 70}, 0.5, {ease: FlxEase.quartIn});
			}
		}
		var curCassette = grpCassette.members[wNum];
		timer(0.6, (_) -> {
			FlxTween.tween(curCassette, {y: curCassette.defaultY - 50}, 0.1, {
				ease: FlxEase.quartOut,
				onComplete: (_) -> {
					FlxTween.tween(curCassette, {y: curCassette.defaultY + 270}, 0.4, {
						ease: FlxEase.quartIn,
						onComplete: (_) -> {
							loadSong();
						}
					});
				}
			});
		});
	}

	function timer(Time:Float = 1, ?OnComplete:FlxTimer->Void, Loops:Int = 1) {
		new FlxTimer().start(Time, OnComplete, Loops);
	}

	function loadSong() {
		timer(1, function(tmr:FlxTimer)
		{
			if(Paths.formatToSongPath(PlayState.SONG.song) == "heart-attack" || Paths.formatToSongPath(PlayState.SONG.song) == "jelly-jamboree" )
			{
				LoadingState.loadAndSwitchState(new MeetState(), true);
				FreeplayState.destroyFreeplayVocals();
			}
			else{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			}
		});
	}

	var diffName = "";

	function changeDiffNumber(change:Int = 0) {
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		diffName = Paths.formatToSongPath(CoolUtil.difficulties[curDifficulty]);

		if(change == 0) {
			for(cassette in grpCassette) {
				cassette.updateDifficulty(diffName);
			}
			updateScore();
		}

		if(change != 0) {
			for(cassette in grpCassette) {
				if(cassette.targetItem != 0) {
					cassette.updateDifficulty(diffName);
				}
			}
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		changeDiffNumber(change);

		if(change == 0) return;

		for(cassette in grpCassette) {
			cassette.acceleration.set();
			cassette.velocity.set();
			if(cassette.targetItem == 0) {
				cassette.acceleration.y = 650;
				cassette.velocity.y -= FlxG.random.int(240, 275);
				cassette.velocity.x -= FlxG.random.int(-100, 100);
				allowChanging = false;
				cassette.alpha = 1;
				FlxTween.cancelTweensOf(cassette);
				FlxTween.tween(cassette, {alpha: 0}, 0.3, {
					startDelay: 0.3,
					onComplete: (_) -> {
						cassette.updateDifficulty(diffName);
						cassette.acceleration.set();
						cassette.velocity.set();
						cassette.y = cassette.defaultY + 100;
						cassette.x = cassette.defaultX;
						cassette.alpha = 1;
						allowChanging = true;

						updateScore();

						FlxTween.tween(cassette, {y: cassette.defaultY}, 0.2, {
							onComplete: (_) -> {
								cassette.y = cassette.defaultY;
							}
						});
					}
				});
			}
		}
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;


	function fixTween(Object:Dynamic, Values:Dynamic, Duration:Float = 1, ?Options:TweenOptions) {
		FlxTween.cancelTweensOf(Object);
		FlxTween.tween(Object, Values, Duration, Options);
	}


	function tweenBg(bg:FlxSprite, id:Int, instant:Bool) {
		var alpha = curWeek == id?1:(firstFrame ? 0.0001 : 0);
		if(instant) {
			bg.alpha = alpha;
			return;
		}
		fixTween(bg, {alpha: alpha}, 0.2);
	}

	function updateBackground(instant:Bool = false) {
		tweenBg(oldtimes, 0, instant);
		tweenBg(specters, 1, instant);
		tweenBg(erect, 3, instant);
		tweenBg(afterdark, 4, instant);
		tweenBg(mansionmatch, 5, instant);
		tweenBg(candle, 6, instant);
		tweenBg(goat, 7, instant);
		tweenBg(ourple, 8, instant);
		tweenBg(ska, 9, instant);
		tweenBg(anime, 10, instant);
		tweenBg(kisston, 12, instant);
		tweenBg(kai, 13, instant);
		tweenBg(pasta, 14, instant);
	}

	function changeWeek(change:Int = 0):Void
	{
		_curWeek += change;

		/*if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = WeekData.weeksList.length - 1;*/

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		//txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);
		txtWeekTitle.screenCenter(X);

		var half = Math.floor(WeekData.weeksList.length / 2);

		var i:Int = 0;
		//var renderPart = 5;
		//var renderPart2 = renderPart+1;

		for (item in grpCassette.members)
		{
			item.targetItem = i - curWeek;
			var a = CoolUtil.mod(item.targetItem + half, grpCassette.members.length) - half;
			item.visTargetItem = a;
			//if(item.targetItem > renderPart2) {
			//	item.targetItem -= WeekData.weeksList.length;
			//}
			/*if(curWeek < renderPart2 && i ) { // && i > WeekData.weeksList.length - renderPart2
				item.targetItem -= WeekData.weeksList.length; // add to left
			}
			else *//*if(curWeek > WeekData.weeksList.length - renderPart2 && i <= renderPart2) {
				item.targetItem += WeekData.weeksList.length; // add to right
			}*/
			item.exVisible = false;
			if(Math.abs(item.visTargetItem) <= 4) {
				item.exVisible = true;
			}

			item.exAlpha = 1;
			if(item.visTargetItem != item.targetItem) {
				item.exAlpha = 0.3;
			}
			i++;
		}

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		}

		updateBackground();

		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}

		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();

		changeDiffNumber(0);
	}

	function weekIsUnlocked(weekNum:Int) {
		#if debug
		if(forceUnlock) {
			return true;
		}
		#end

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		if(leWeek.songs.length > 0) {
			var song = leWeek.songs[0][0];
			if(newUnlockedSongs.contains(song)) {
				return false;
			}
			return LockManager.isSongUnlocked(song);
		}

		return true;
		//return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		/*var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}*/

		/*txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;*/

		updateScore();
	}

	function updateScore() {
		var wkstr = WeekData.weeksList[curWeek];
		var leWeek = WeekData.weeksLoaded.get(wkstr);
		//trace(leWeek.songs, CoolUtil.difficulties[curDifficulty]);
		if(leWeek.songs.length > 0) {
			intendedScore = Highscore.getScore(leWeek.songs[0][0], curDifficulty);
		} else {
			intendedScore = Highscore.getWeekScore(wkstr, curDifficulty);
		}
	}
}
