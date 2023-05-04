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
import('flixel.text.FlxTextBorderStyle');
import('flixel.graphics.frames.FlxBitmapFont');
import('Math');
import('flixel.util.FlxStringUtil');
import("CoolUtil");
import("flixel.math.FlxMath");
import("flixel.util.FlxTimer");
import("Conductor");
import("FlxColor");
import("AttachedSprite");
import("Alphabet");
import("ChartCredits");
import("Reflect");

var u;
var songLength = 1.0;


var font =  FlxBitmapFont.fromAngelCode(
	Paths.image('font/menuOutline_B'),
	Paths.getTextFromFile("images/font/menuOutline.fnt")
);

var timeTxt = new FlxBitmapText(font);

var beatTxt = new FlxBitmapText(font);

var nameTxts = [];



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

function createName(){
	var t0 = new FlxBitmapText(font);
	var oneLetter = new FlxBitmapText(font);
	
}

function animateNameEntry(){

}
//game.add(credGroup);

function subtitleAdd(subtitle:String):FlxBitmapText{
	var t2 = new FlxBitmapText(font);
	t2.scale.set(0.5,0.5);
	t2.text = subtitle;
	t2.letterSpacing =0;
	game.add(t2);
	return t2;
}



var beatTween = null;
var scaleTo = 0.75;

var subtitle1 = subtitleAdd(""); 
var subtitle2 = subtitleAdd(""); 

var megamix = new FlxSprite(355, 500);
//megamix.loadGraphic(Paths.image('megamix', 'preload'));
megamix.frames = Paths.getSparrowAtlas('megamix');
megamix.animation.addByPrefix('bump', 'megamix', 24, false);
megamix.animation.play('bump');
megamix.scale.set(0.7, 0.7);
megamix.antialiasing = ClientPrefs.globalAntialiasing;

var logoBl = new FlxSprite(565, 60);
logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
logoBl.antialiasing = ClientPrefs.globalAntialiasing;
logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
logoBl.animation.play('bump');
logoBl.updateHitbox();

var bopping = [];
var icons = [];
function bopEverything(){
	for( x in bopping){
		var initialScaleX = x.scale.x + 0;
		var initialScaleY = x.scale.y + 0;

		x.scale.x+=0.04;
		x.scale.y+=0.04;
		FlxTween.tween(x.scale, {x: initialScaleX, y:initialScaleY}, 0.4, {ease: FlxEase.cubeInOut});
	}

}

function bopIcons(){
	for( x in icons){
		var initialScaleX = x.scale.x + 0;
		var initialScaleY = x.scale.y + 0;

		x.scale.x+=0.04;
		x.scale.y+=0.04;
		FlxTween.tween(x.scale, {x: initialScaleX, y:initialScaleY}, 0.6, {ease: FlxEase.cubeInOut});
	}

}
//makeLuaText("pop","Hello World", 200, 200, 200);
		
function getLuaText(s:String){
	return game.modchartTexts.get(s);
}

function activateText(name:String){
	var subtitle = getLuaText(name);
	subtitle.screenCenter(FlxAxes.XY);
	subtitle.fieldWidth = FlxG.width*0.3;
	subtitle.updateHitbox();
	addLuaText(name);
	return subtitle;
}

function subTitleSwoop(name:String, x:Int, y:Int){
	var subtitle = activateText(name);
	subtitle.x=-1500;
	FlxTween.tween(subtitle, {x: x-subtitle.width/2, y:y-subtitle.height}, 0.25, {ease: FlxEase.cubeInOut});
}





function swoopNameTo(name:Dynamic, x:Int, y:Int){
	
	FlxTween.tween(name, {x: name.x+x, y:name.y+y}, 0.25, {ease: FlxEase.cubeInOut});
}


function titleSwoop(name:String, x:Int, y:Int, ?b:Bool){
	b = b==null?true:false;
	var title = getLuaText(name);
	title.fieldWidth = FlxG.width;
	title.updateHitbox();
	if(b){
		title.screenCenter(FlxAxes.XY);
	}
	//title.x-=title.width/4;
	addLuaText(name);
	FlxTween.tween(title, {x: title.x+x, y:title.y+y}, 0.25, {ease: FlxEase.cubeInOut});
}

function splitEnter(threeNames:Array<String>){
	var hypno = (threeNames[2] == 'Hypnos Lullaby Team');
	var hypnoAdd = hypno?-40:0;
	var split1 = creditsStuff.get(threeNames[0]);
	var split2 = activateText(threeNames[0]);
	bopping.push(split1);
	split1.screenCenter(FlxAxes.XY);
	split2.screenCenter(FlxAxes.XY);
	swoopNameTo(split1,-FlxG.width/4-40,-250+hypnoAdd);			
	swoopNameTo(split2,-FlxG.width/4-40,30+hypnoAdd);

	var split1 = creditsStuff.get(threeNames[1]);
	var split2 = activateText(threeNames[1]);
	bopping.push(split1);
	split1.screenCenter(FlxAxes.XY);
	split2.screenCenter(FlxAxes.XY);
	swoopNameTo(split1,FlxG.width/4+40,-250+hypnoAdd);			
	swoopNameTo(split2,FlxG.width/4+40,30+hypnoAdd);

	if(threeNames[2]!=''){
		var split1 = creditsStuff.get(threeNames[2]);
		var split2 = activateText(threeNames[2]);
		if(hypno){
			split2.fieldWidth = FlxG.width/2;
		} 
		bopping.push(split1);
		split1.screenCenter(FlxAxes.XY);
		split2.screenCenter(FlxAxes.XY);
		swoopNameTo(split1,0,hypno?20:-50);			
		swoopNameTo(split2,0,hypno?300:230);
	}
}

function splitLeave(threeNames:Array<String>){
	var split1 = creditsStuff.get(threeNames[0]);
	var split2 = getLuaText(threeNames[0]);
	swoopNameTo(split1,-FlxG.width/4*10,-200*10);			
	swoopNameTo(split2,-FlxG.width/4*10,100*10);

	var split1 = creditsStuff.get(threeNames[1]);
	var split2 = getLuaText(threeNames[1]);
	swoopNameTo(split1,FlxG.width/4*10,-200*10);			
	swoopNameTo(split2,FlxG.width/4*10,100*10);

	if(threeNames[2]!=''){
		var split1 = creditsStuff.get(threeNames[2]);
		var split2 = getLuaText(threeNames[2]);
		swoopNameTo(split1,0,1000);			
		swoopNameTo(split2,0,300*10);	
	}
}

var ascendHeight = 0;

function ascendLeave(allNames:Array<String>){

	for(i in 0 ... allNames.length){
		var split1 = creditsStuff.get(allNames[i]);
		var split2 = getLuaText(allNames[i] );
		var j = split1.y/140;
		var k = split2.y/140;
		FlxTween.tween(split1, {x: split1.x, y:-FlxG.height/2-(allNames.length-j)*140}, 10, {ease: FlxEase.LINEAR});
		FlxTween.tween(split2, {x: split2.x, y:-FlxG.height/2-(allNames.length-k)*140}, 10, {ease: FlxEase.LINEAR});
	}

}

function ascendEnter(allNames:Array<String>){

	for(i in 0 ... allNames.length){
		var split1 = creditsStuff.get(allNames[i]);
		var split2 = activateText(allNames[i] );
		split2.fieldWidth = FlxG.width*0.9;
		split2.updateHitbox();
		split1.y=FlxG.height+140*i;
		split2.y=FlxG.height+140*i+split1.height+60;
		split1.screenCenter(FlxAxes.X);
		split2.screenCenter(FlxAxes.X);

		FlxTween.tween(split1, {x: split1.x, y:-FlxG.height/2-(allNames.length-i)*140}, 30, {ease: FlxEase.LINEAR});
		FlxTween.tween(split2, {x: split2.x, y:-FlxG.height/2-(allNames.length-i)*140+60+split1.height}, 30, {ease: FlxEase.LINEAR});
	}
	ascendHeight = -FlxG.height/2-(allNames.length)*140;
}

function beatHit()
{
	/*beatTxt.scale.set(1,1);
	beatTxt.screenCenter(FlxAxes.X);
	if(beatTween!=null){
		beatTween.cancel();
	}
	beatTween = FlxTween.tween(beatTxt.scale, {x: scaleTo, y:scaleTo}, 0.2, {ease: FlxEase.cubeInOut});
	beatTxt.text = game.curBeat;
	beatTxt.screenCenter(FlxAxes.X);*/

	//FlxTween.tween(FlxG.camera, {zoom: lol}, 1);

	if(curBeat%4){
		bopEverything();
		bopIcons();
	}

	switch (curBeat)
	{

		case 32 , 56 , 80 , 109 , 112:
		{
			bop();
			//single bops with nothing special
		}


		case 3:
		{
	
			
			//var t = getLuaText("pop");
			//getLuaText("pop").setFormat(Paths.font("vcr.ttf"), 32,0xFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
			//getLuaText("pop").borderSize=3;
			//scale.set(2,2);
			//FlxTween.tween(u, {alpha: 1}, 1);
			//addLuaText("pop");
			//addLuaText("pop");
		}
		case 16:
		{
			
			bop();
			
			game.add(logoBl);
			bopping.push(logoBl);
			//Display Vs Alfie logo image (logoBumpin.png, but it doesnt have to be that one, it can be just a cropped logo as well)
		}
		case 24:
		{
			bop();
			
			game.add(megamix);
			bopping.push(megamix);
			//Display subtitle Megamix below the logo (megamix.png, same case as the logo)
		}

		case 40:
		{
			bopping = [];
			bop();
			FlxG.camera.flash(-1,1,false);
			game.remove(logoBl);
			game.remove(megamix);
			titleSwoop("ARTWORK:", 0, -250);
			//logo and megamix go away, there's a bit ARTWORK:  title at the top (like the image i sent in the GC)
		}		
		case 48:
		{
			bop();
			
			var name = creditsStuff.get("Mkv8");
			name.screenCenter(FlxAxes.XY);
			name.y -=150;
			bopping.push(name);
			subTitleSwoop("Mkv8",FlxG.width/2,FlxG.height/2+200);
			//Display "Mkv8, Creator of Alfie", with mk.png icon
		}
		case 64:
		{
			bopping =[];
			creditsStuff.get("Mkv8").x=-2000;
			getLuaText("Mkv8").x=-2000;
			
			var name = creditsStuff.get("Gigab00ts");
			name.screenCenter(FlxAxes.XY);
			name.x -= FlxG.width/4;
			name.y -=250;
			subTitleSwoop("Gigab00ts", FlxG.width/4, FlxG.height/2+100);
			
			var name2 = creditsStuff.get("Josszzol");
			name2.screenCenter(FlxAxes.XY);
			name2.x += FlxG.width/4;
			name2.y -=250;
			subTitleSwoop("Josszzol", FlxG.width*3/4, FlxG.height/2+100);
			
			bopping.push(name);
			bopping.push(name2);
			
			bop();
			//Mk goes away, displays in its place "Gigab00ts, creator of Kisston" and "Josszzol, creator of Filip", with the giga and joss icons respectively
		}
		case 72:
		{
			bop();

			
			var name2 = creditsStuff.get("Aurum");
			name2.screenCenter(FlxAxes.XY);
			name2.y -=50;
			subTitleSwoop("Aurum", FlxG.width/2, FlxG.height/2+250);
			bopping.push(name2);
			
			//below them there's Aurum and their icon
		}
		case 88:
		{
			bopping =[];
			swoopNameTo(creditsStuff.get("Gigab00ts"),-2000,0);
			swoopNameTo(creditsStuff.get("Josszzol"),-2000,0);
			swoopNameTo(creditsStuff.get("Aurum"),-2000,0);
			swoopNameTo(getLuaText("Gigab00ts"),-2000,0);
			swoopNameTo(getLuaText("Josszzol"),-2000,0);
			swoopNameTo(getLuaText("Aurum"),-2000,0);
			bop();
			FlxG.camera.flash(-1,1,false);
			titleSwoop("ARTWORK:", 0, -1050, false);
			titleSwoop("PROGRAMMING:", 0, -250);
			
			//artists stuff goes away, title goes from ARTWORK to PROGRAMMING
		}	
		case 96:
		{
			bop();
			var name = creditsStuff.get("Mkv8");
			name.screenCenter(FlxAxes.XY);
			name.y -=150;
			bopping.push(name);
			subTitleSwoop("Mkv8-2",FlxG.width/2,FlxG.height/2+200);
			//Mkv8 and icon again
		}	
		case 104:
		{
			bop();
			creditsStuff.get("Mkv8").x=-2000;
			getLuaText("Mkv8-2").x=-2000;
			
			var name = creditsStuff.get("Ne_Eo");
			name.screenCenter(FlxAxes.XY);
			name.x -= FlxG.width/4;
			name.y -=250;
			subTitleSwoop("Ne_Eo", FlxG.width/4, FlxG.height/2+100);
			
			var name2 = creditsStuff.get("Whatify");
			name2.screenCenter(FlxAxes.XY);
			name2.x += FlxG.width/4;
			name2.y -=250;
			subTitleSwoop("Whatify", FlxG.width*3/4, FlxG.height/2+100);
			
			bopping.push(name);
			bopping.push(name2);
			
			var name2 = creditsStuff.get("Shadowfi");
			name2.screenCenter(FlxAxes.XY);
			name2.y -=50;
			subTitleSwoop("Shadowfi", FlxG.width/2, FlxG.height/2+250);
			bopping.push(name2);
			
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

			
			swoopNameTo(creditsStuff.get("Ne_Eo"),-2000,0);			
			swoopNameTo(getLuaText("Ne_Eo"),-2000,0);

			//Neo goes away
		}
		case 118:
		{
			new FlxTimer().start(0.28, function(tmr:FlxTimer){
				bop();
				swoopNameTo(creditsStuff.get("Whatify"),-2000,0);			
				swoopNameTo(getLuaText("Whatify"),-2000,0);
				//whatify goes away
			});	
		}
		case 120: 
		{
			bop();
			swoopNameTo(creditsStuff.get("Shadowfi"),-2000,0);			
			swoopNameTo(getLuaText("Shadowfi"),-2000,0);
			//shadowfi goes away
		}
		case 125:
		{
			bopping =[];
			bop();
			FlxG.camera.flash(-1,1,false);
			titleSwoop("PROGRAMMING:", 0, -1050, false);
			
			getLuaText("MUSIC:").text="M";
			titleSwoop("MUSIC:", 0, -250);
			//programming stuff goes away
		}
		case 126: 
		{
			new FlxTimer().start(0.28, function(tmr:FlxTimer){
				bop();
				getLuaText("MUSIC:").text="MU";
				titleSwoop("MUSIC:", 0, -250);
				//the start of the word Music comes in, "mu"
			});	
		}
		case 128: 
		{
			bop();
			getLuaText("MUSIC:").text="MUSIC:";
			titleSwoop("MUSIC:", 0, -250);
			//finishing the word, "sic", forming Music
			splitEnter(['AidanXD','Meta','Kamex']);
		}

		case 152: 
		{
			splitLeave(['AidanXD','Meta','Kamex']);	
			splitEnter(['RayZord','Coquers_','Car']);
		}
		case 176:
		{
			splitLeave(['RayZord','Coquers_','Car']);
			splitEnter(['SplatterDash','Jospi','JunoSongs']);
		}
		case 200: 
		{
			titleSwoop("MUSIC:", 0, -1050, false);
			titleSwoop("CHARTING:", 0, -250);
			splitLeave(['SplatterDash','Jospi','JunoSongs']);	
			splitEnter(['Sayge', 'ChubbyGamer', 'PpavlikosS']);
		}
		case 224:
		{

			/*['MISC:'],
['David H.',			
['Smokeyy',				
['Hotline 024 team', 'Ourple Guy team', 'Hypnos Lullaby Team']
*/
			titleSwoop("CHARTING:", 0, -1050, false);
			titleSwoop("MISC:", 0, -250);
			splitLeave(['Sayge', 'ChubbyGamer', 'PpavlikosS']);
			splitEnter(['David H','Smokeyy','']);
		}

		case 248:
		{
			titleSwoop("MISC:", 0, -1050, false);
			titleSwoop("SPECIAL THANKS:", 0, -290);
			splitLeave(['David H','Smokeyy','']);
			splitEnter(['Hotline 024 team', 'Ourple Guy team', 'Hypnos Lullaby Team']);
		}
		case 260:
		{
			ascendLeave(['Hotline 024 team', 'Ourple Guy team', 'Hypnos Lullaby Team']);
			ascendEnter(['Past Vs Alfie members'
			'Flippy and Gegcoin',	
			'MattDoes_',			
			'Tesseption',			
			'FlarinthK',			
			'SirSins',				
			'Alfie and Filip fan Server',
			'Fans and Supporters',	
			'And you']);
		}		

		case 304:
		{
			FlxTween.tween(getLuaText('SPECIAL THANKS:'), {alpha: 0}, 7);
			FlxTween.tween(u, {alpha: 0}, 7);
		}
	}
	/*
	if(curBeat == 20){
		beatTxt.color=0xFF00FF00;
	}
	if(curBeat == 22){
		beatTxt.color=0xFF0084FF;
	}
	if(curBeat == 24){
		beatTxt.color=0xFFFF6868;
	}
	if(curBeat == 30){
		beatTxt.color=0xFFFFFFFF;
	}*/

	
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
	if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
		FlxG.sound.music.pause();
		Conductor.songPosition += 10000;
		FlxG.sound.music.time = Conductor.songPosition;
		FlxG.sound.music.play();
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
	if( Math.floor(secondsTotal) <= 0) {
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


var pisspoop:Array<Array<String>>;
function unselectableCheck(stuff:Array<String>):Bool {
	return stuff.length <= 1;
}

function generateCredits(){
	for (j in 0...pisspoop.length)
	{
		var i = pisspoop[j];
		//if(creditsStuff.get(i[0])==null){
			
			var optionText:Alphabet = 
			new Alphabet(
				0, 		//x
				70 * j, //y
				i[0], 	//text
				unselectableCheck(i), //bold
				false,	//typed
				0.05,	//typingSpeed
				1,		//textSize
				true 	//Invert colors
			);

			optionText.fontColor=0xFFFFFFFF;
			var formattedName= i[0].split(".").join();
			
			var dash2 = creditsInfo.get(formattedName)==null?"":"-2";
				
			creditsStuff.set(formattedName+dash2,optionText);
			
			optionText.x=-5000;
			
			if(!unselectableCheck(i)){
				var icon:AttachedSprite = new AttachedSprite('credits/' + i[1]);
				icon.xAdd = optionText.width/2-icon.width/2;
				icon.yAdd = 100; 
				icon.sprTracker = optionText;
				icons.push(icon);
				makeLuaText(formattedName+dash2,i[2], FlxG.width*0.1, 70 * j, FlxG.width*0.8);
				getLuaText(formattedName+dash2).setFormat(Paths.font("vcr.ttf"), 32,0xFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
				getLuaText(formattedName+dash2).borderSize=3;
				game.add(icon);
			}else{
				makeLuaText(formattedName,i[0], FlxG.width*0.1, 70 * j, FlxG.width*0.8);
				getLuaText(formattedName).setFormat(Paths.font("vcr.ttf"), 64,0xFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
				getLuaText(formattedName).borderSize=3;
			}
			game.add(optionText);
		//}

		if(creditsInfo.get(i[0])==null)
			creditsInfo.set( i[0], [ i[0], unselectableCheck(i) ? i[1] : '' ]);
		else
			creditsInfo.set( i[0]+"2", [ i[0], unselectableCheck(i) ? i[1] : '' ]);
		
		creditsInfo.get(i[0]).push(i.length>4 ? i[3] : '' );

		
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
	
	game.add(u);
	FlxTween.tween(u, {y: -2275/2}, 2, {ease: FlxEase.expoInOut, startDelay: 2.0});
	FlxTween.tween(u.scale, {x: newScale, y:newScale}, 3, {ease: FlxEase.expoInOut, startDelay: 1.0});
	//game.add(timeTxt);
	//beatTxt.scale.set(1,1);
	//game.add(beatTxt);
	//beatTxt.text= "[Beat hit here]";
	
	//beatTxt.screenCenter(FlxAxes.XY);
	//beatTxt.y=60;
	
	generateCredits();
}





pisspoop = [ //Name - Icon name - Description - Link - BG Color
	['ARTWORK:'],
	['Mkv8',				'mk',				'Creator of Alfie, made most of the art',				'https://twitter.com/Mkv8Art',			'D23B48'],
	['Josszzol',			'joss',				'Creator of Filip, made Skalloween Spectracle sprites',	'https://twitter.com/abbledacker',		'FFBF47'],
	['Gigab00ts',			'giga',				'Creator of Kisston and Munchton, sketched a lot of poses',	'https://twitter.com/GigaB00ts',	'81DB7F'],
	['Aurum',				'jade',				'Animated the Pasta Night sprites',						'https://twitter.com/AurumArt_',		'9D58BF'],
	
	['PROGRAMMING:'],
	['Mkv8',				'mk',				'Did most of the basic coding',							'https://twitter.com/Mkv8Art',			'D23B48'],
	['Ne_Eo',				'neo',				'Helped a lot with optimizing and coding the hard stuff!',	'https://twitter.com/Ne_Eo_Twitch',	'8A5F5C'],
	['Whatify',				'WhatIcon',			'Helped with Interrupted, Lua issues and more',			'https://twitter.com/Sonamaker1',		'5A66A6'],
	['Shadowfi',			'shadowdelic',		'Coded Pasta Night mechanics and characters',			'https://twitter.com/Shadowfi1385',		'9D58BF'],
	
	['MUSIC:'],
	['Aidan.XD',			'aidan',			'Gettin Freaky, Spectral Sonnet Beta Mix, After Dark (Alfie Mix)',	'https://www.youtube.com/channel/UCvIvCI3NRiJEYpyes58LhqQ',	'FF9D87'],
	['Meta',				'meta',				'Forest Fire Remix and Spectral Sonnet Beta',			'https://metahumanboi.carrd.co/',		'4F3F5C'],
	['Kamex',				'ace',				'Spectral Sonnet, G.O.A.T Remake, Spooks',				'https://www.youtube.com/c/Kamex',		'BAE2FF'],
	['RayZord',				'ray',				'GOATED song',											'https://www.youtube.com/c/RayZord',	'49A7EB'],
	['Coquers_',			'coquers',			'Shattered (Game Over Music), Mansion Match, G.O.A.T Remake, Heart Attack',	'https://www.youtube.com/c/coquers_',	'D15E56'],
	['Car',					'car',				'Candle-Lit Clash',										'https://www.youtube.com/c/carcarwoah',	'FF3021'],
	['SplatterDash',		'splatter',			'INTERRUPTED, All Saints Scramble Remix, Pasta Night (AFK Mix)',	'https://twitter.com/splatterdash_ng',	'72B2F2'],
	['Jospi',				'jospi',			'Take It Slow (Pause Music), Megamix (Credits Song), Minimize, Jelly Jamboree',	'https://twitter.com/jospi_music',	'96FAFF'],
	['JunoSongs',			'juno',				'Lyrics and singer for Spooks',							'https://www.youtube.com/@JunoSongs',	'B563DB'],
	
	['CHARTING:'],
	['Sayge',				'sayge',			'Charter for Spectral Sonnet and After Dark',			'https://twitter.com/Sayge3D',			'FFA44F'],
	['ChubbyGamer',			'chubby',			'Charter for Interruped, Spooks, and Pasta Night (AFK Mix)','https://twitter.com/ChubbyAlt',	'C78A58'],
	['PpavlikosS',			'pav',				'The rest of the songs lol',							'https://twitter.com/ppavlikoss',		'BAE2FF'],
	
	['MISC:'],
	['David H.',			'blank',			'Album cover Artwork',									' ',									'72A3ED'],
	['Smokeyy',				'smokeyy',			'Release trailer',										'https://twitter.com/Smokiixx',			'716A73'],			
	['Hotline 024 team',	'nikku',			'Thank you Sakury and the H024 team for letting us use Nikku!','https://gamebanana.com/mods/373298',			'FF3021'],
	['Ourple Guy team',		'guy',				'Thank you Kiwiquest and the Ourple Guy team for letting us use the characters!','https://gamebanana.com/mods/357511',			'BD51DB'],
	['Hypnos Lullaby Team',	'hypno',			'Thank you Punkett, iKenny, and TheInnuendo, creators of Pasta Night ','https://fridaynightfunking.fandom.com/wiki/Friday_Night_Funkin%27_Lullaby',			'F7BF45'],
	
	['SPECIAL THANKS:'],
	['Past Vs Alfie members','blank',			'Including MisterParakeet, ThisIsBennyK, StardustTunes, Dami and NemoInABottle',' ',			'D23B48'],
	['Flippy and Gegcoin',	'blank',			'For always playing vs Alfie',							' ',									'BDBCC4'],
	['MattDoes_',			'blank',			'For Always Following Vs Alfie',						' ',									'49E3E6'],
	['Tesseption',			'blank',			'For Always Following Vs Alfie',						' ',									'D149E6'],
	['FlarinthK',			'blank',			' ',													' ',									'F78F45'],
	['SirSins',				'blank',			' ',													' ',									'F78F45'],
	['Alfie and Filip fan Server',	'blank',	' ',													' ',									'F78F45'],
	['Fans and Supporters',	'blank',			'For the fan content (we really appreciate it!!)',		' ',									'98ED87'],
	['And you',				'blank',			'cuz we really do be cheesy like that',					' ',									'D42C3D'],
];


/*
for (i in 0...creditsStuff.length)
{
	var isSelectable:Bool = !unselectableCheck(i);
	var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
	optionText.isMenuItem = true;
	optionText.screenCenter(X);
	optionText.yAdd -= 70;
	if(isSelectable) {
		optionText.x -= 70;
	}
	optionText.forceX = optionText.x;
	//optionText.yMult = 90;
	optionText.targetY = i;
	grpOptions.add(optionText);

	if(isSelectable) {
		if(creditsStuff[i][5] != null)
		{
			Paths.currentModDirectory = creditsStuff[i][5];
		}

		var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
		icon.xAdd = optionText.width + 10;
		icon.sprTracker = optionText;

		// using a FlxGroup is too much fuss!
		iconArray.push(icon);
		add(icon);
		Paths.currentModDirectory = '';

		if(curSelected == -1) curSelected = i;
	}
}
*/