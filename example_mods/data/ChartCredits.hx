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
import("CoolUtil");
import("flixel.math.FlxMath");
import("flixel.util.FlxTimer");
import("Conductor");
import("FlxColor");
var u;
var songLength = 1.0;

var timeTxt = new FlxBitmapText(
	FlxBitmapFont.fromAngelCode(
		Paths.image('font/menuOutline_B'),
		Paths.getTextFromFile("images/font/menuOutline.fnt")
	)
);

var beatTxt = new FlxBitmapText(
	FlxBitmapFont.fromAngelCode(
		Paths.image('font/menuOutline_B'),
		Paths.getTextFromFile("images/font/menuOutline.fnt")
	)
);


var camZooming = false;
var defaultCamZoom:Float = 1;

function bop()
{
	FlxG.camera.zoom += 0.020;
	camZooming = true;
}

function timer(dur:Float, func:Dynamic) {
    new FlxTimer().start(dur, func);
}

var beatTween = null;
var scaleTo = 0.75;
function beatHit()
{
	beatTxt.scale.set(1,1);
	beatTxt.screenCenter(FlxAxes.X);
	if(beatTween!=null){
		beatTween.cancel();
	}
	beatTween = FlxTween.tween(beatTxt.scale, {x: scaleTo, y:scaleTo}, 0.2, {ease: FlxEase.cubeInOut});
	beatTxt.text = game.curBeat;
	beatTxt.screenCenter(FlxAxes.X);

	//FlxTween.tween(FlxG.camera, {zoom: lol}, 1);


	switch (curBeat)
	{

		case 32 , 56 , 80 , 109 , 112:
		{
			bop();
			//single bops with nothing special
		}


		case 3:
		{
			FlxTween.tween(u, {alpha: 1}, 1);
		}
		case 16:
		{
			bop();
			//Display Vs Alfie logo image (logoBumpin.png, but it doesnt have to be that one, it can be just a cropped logo as well)
		}
		case 24:
		{
			bop();
			//Display subtitle Megamix below the logo (megamix.png, same case as the logo)
		}

		case 40:
		{
			bop();
			FlxG.camera.flash(-1,1,false);
			//logo and megamix go away, there's a bit ARTWORK:  title at the top (like the image i sent in the GC)
		}		
		case 48:
		{
			bop();
			//Display "Mkv8, Creator of Alfie", with mk.png icon
		}
		case 64:
		{
			bop();
			//Mk goes away, displays in its place "Gigab00ts, creator of Kisston" and "Josszzol, creator of Filip", with the giga and joss icons respectively
		}
		case 72:
		{
			bop();
			//below them there's Aurum and their icon
		}
		case 88:
		{
			bop();
			FlxG.camera.flash(-1,1,false);
			//artists stuff goes away, title goes from ARTWORK to PROGRAMMING
		}	
		case 96:
		{
			bop();
			//Mkv8 and icon again
		}	
		case 104:
		{
			bop();
			//MKv8 goes away, and in comes Ne_Eo, Whatify, and Shadowfi for the programmer section
			//i put myself separated cuz idk both with the timing of the song it seemed good, and also while I did a lot of work, you guys did all the big stuff so
			//yall deserve more time on screen
		}
		case 110:
		{
			new FlxTimer().start(0.28, function(tmr:FlxTimer){
				bop();
			});	
		}
		case 117:
		{
			bop();
			//Neo goes away
		}
		case 118:
		{
			new FlxTimer().start(0.28, function(tmr:FlxTimer){
				bop();
				//whatify goes away
			});	
		}
		case 120: 
		{
			bop();
			//shadowfi goes away
		}
		case 125:
		{
			bop();
			FlxG.camera.flash(-1,1,false);
			//programming stuff goes away
		}
		case 126: 
		{
			new FlxTimer().start(0.28, function(tmr:FlxTimer){
				bop();
				//the start of the word Music comes in, "mu"
			});	
		}
		case 128: 
		{
			bop();
			//finishing the word, "sic", forming Music
		}
		

		case 304:
		{
			FlxTween.tween(u, {alpha: 0}, 7);
		}
	}
	if(curBeat == 20){
		beatTxt.color=0xFF00FF00;
	}
	if(curBeat == 22){
		beatTxt.color=0xFF0084FF;
	}
	/*if(curBeat == 24){
		beatTxt.color=0xFFFF6868;
	}*/
	if(curBeat == 30){
		beatTxt.color=0xFFFFFFFF;
	}


}


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
	if (controls.RESET)
	{
		MusicBeatState.resetState();	
	}
	u.updateHitbox();
	u.screenCenter(FlxAxes.X);
	Conductor.songPosition = FlxG.sound.music.time;
	

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

	if (camZooming)
	{
		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
	}

}




function create(){
	Conductor.changeBPM(155);
	Conductor.songPosition=0;
	FlxG.sound.playMusic(Paths.music('Megamix'));
	FlxG.sound.music.volume = 0.5;
	songLength = FlxG.sound.music.length;
	
	var initialScale = 1;
	var newScale = FlxG.width/2275;
	
	u = new BGSprite('credits_video', 1,1,true, true);
	u.scale.set(initialScale,initialScale);
	u.updateHitbox();
	u.screenCenter(FlxAxes.XY);
	u.y+=3655/2*1-FlxG.height/2;
	u.antialiasing = true;
	u.alpha = 0.00001;
	
	game.add(u);
	FlxTween.tween(u, {y: -2275/2}, 2, {ease: FlxEase.expoInOut, startDelay: 2.0});
	FlxTween.tween(u.scale, {x: newScale, y:newScale}, 3, {ease: FlxEase.expoInOut, startDelay: 1.0});
	game.add(timeTxt);
	beatTxt.scale.set(1,1);
	game.add(beatTxt);
	beatTxt.text= "[Beat hit here]";
	beatTxt.screenCenter(FlxAxes.XY);
	//beatTxt.y=60;
	
}