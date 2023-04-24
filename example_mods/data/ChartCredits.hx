import('MainMenuState');
import('MusicBeatState');
import('Conductor');
import('Paths');
import('BGSprite');
import('flixel.tweens.FlxEase');
import('flixel.tweens.FlxTween');
import('flixel.util.FlxAxes');
import('flixel.addons.display.FlxBackdrop');
import('flixel.text.FlxBitmapText');
import('flixel.graphics.frames.FlxBitmapFont');
import('Math');
import('flixel.util.FlxStringUtil');
var u;
var songLength = 1.0;

var timeTxt = new FlxBitmapText(
	FlxBitmapFont.fromAngelCode(
		Paths.image('font/menuOutline_B'),
		Paths.getTextFromFile("images/font/menuOutline.fnt")
	)
);
var p = 0;

var initialVolume = FlxG.sound.music.volume;

function returnToMenu(){
	FlxG.sound.play(Paths.sound('cancelMenu'));
	game.persistentUpdate = false;
	MusicBeatState.switchState(new MainMenuState());
	FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);	
	FlxG.sound.music.volume = initialVolume;
}

function update(elapsed:Float){
	if (controls.BACK)
	{
		returnToMenu();	
	}
	u.updateHitbox();
	u.screenCenter(FlxAxes.X);
	p+=elapsed;
	//ratingText.text = Math.floor(p*100)/100;
	
	
	Conductor.songPosition += elapsed * 1000;
	var curTime:Float = Conductor.songPosition;
	if(curTime < 0) curTime = 0;
	songPercent = (curTime / songLength);

	var songCalc:Float = (songLength - curTime);
	if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

	var secondsTotal:Int = Math.floor(songCalc / 10)/100;
	if(secondsTotal < 0) {
		secondsTotal = 0;
		returnToMenu();
	}

	if(ClientPrefs.timeBarType != 'Song Name')
		timeTxt.text = FlxStringUtil.formatTime(secondsTotal, true);
	timeTxt.screenCenter(FlxAxes.X);
	
}



function create(){
	Conductor.changeBPM(155);
	Conductor.songPosition=0;
	FlxG.sound.playMusic(Paths.music('0-_Megamix_Credits_theme'));
	FlxG.sound.music.volume = 0.4;
	songLength = FlxG.sound.music.length;
	
	var initialScale = 1;
	var newScale = FlxG.width/2275;
	
	u = new BGSprite('credits_video', 1,1,true, true);
	u.scale.set(initialScale,initialScale);
	u.updateHitbox();
	u.screenCenter(FlxAxes.XY);
	u.y+=3655/2*1-FlxG.height/2;
	u.antialiasing = true;
	
	game.add(u);
	FlxTween.tween(u, {y: -2275/2}, 2, {ease: FlxEase.expoInOut, startDelay: 2.0});
	FlxTween.tween(u.scale, {x: newScale, y:newScale}, 3, {ease: FlxEase.expoInOut, startDelay: 1.0});
	game.add(timeTxt);
	
	
}



