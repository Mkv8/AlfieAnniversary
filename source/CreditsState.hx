package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	//var colorSubTween:FlxTween;
	var replayButton:FlxButton;
	
	function setAllLabelsOffset(button:FlxButton, x:Float, y:Float)
	{
		for (point in button.labelOffsets)
		{
			point.set(x, y);
		}
	}
	
	override function destroy(){
		FlxG.mouse.visible = false;
		super.destroy();
	}

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Checking the credits!", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menucredits'));
		add(bg);
		bg.screenCenter();
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		#if MODS_ALLOWED
		//trace("finding mod shit");
		for (folder in Paths.getModDirectories())
		{
			var creditsFile:String = Paths.mods(folder + '/data/credits.txt');
			if (FileSystem.exists(creditsFile))
			{
				var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
				for(i in firstarray)
				{
					var arr:Array<String> = i.replace('\\n', '\n').split("::");
					if(arr.length >= 5) arr.push(folder);
					creditsStuff.push(arr);
				}
				creditsStuff.push(['']);
			}
		};
		var folder = "";
			var creditsFile:String = Paths.mods('data/credits.txt');
			if (FileSystem.exists(creditsFile))
			{
				var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
				for(i in firstarray)
				{
					var arr:Array<String> = i.replace('\\n', '\n').split("::");
					if(arr.length >= 5) arr.push(folder);
					creditsStuff.push(arr);
				}
				creditsStuff.push(['']);
			}
		#end

		var pisspoop:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			['Art'],
			['Mk',					'mk',				'Creator of Alfie, made most of the art',				'https://twitter.com/Mkv8Art',			'D23B48'],
			['Josszzol',			'joss',				'Creator of Filip, made Skalloween Spectracle sprites',	'https://twitter.com/abbledacker',		'FFBF47'],
			['Gigab00ts',			'giga',				'Creator of Kisston and Munchton, sketched a lot of poses',	'https://twitter.com/GigaB00ts',	'81DB7F'],
			['Aurum',				'jade',				'Animated the Pasta Night sprites',						'https://twitter.com/AurumArt_',		'9D58BF'],
			[''],
			['Programming'],
			['Mk',					'mk',				'Did most of the basic coding',							'https://twitter.com/Mkv8Art',			'D23B48'],
			['Ne_Eo',				'neo',				'Helped a lot with optimizing and coding the hard stuff!',	'https://twitter.com/Ne_Eo_Twitch',	'8A5F5C'],
			['Whatify',				'WhatIcon',			'Helped with Interrupted, Lua issues and more',			'https://twitter.com/Sonamaker1',		'5A66A6'],
			['Shadowfi',			'shadowdelic',		'Coded Pasta Night mechanics and characters',			'https://twitter.com/Shadowfi1385',		'9D58BF'],
			[''],
			['Music'],
			['Aidan.XD',			'aidan',			'Gettin Freaky, Spectral Sonnet Beta Mix, After Dark (Alfie Mix)',	'https://www.youtube.com/channel/UCvIvCI3NRiJEYpyes58LhqQ',	'FF9D87'],
			['Meta',				'meta',				'Forest Fire Remix and Spectral Sonnet Beta',			'https://metahumanboi.carrd.co/',		'4F3F5C'],
			['Kamex',				'ace',				'Spectral Sonnet, G.O.A.T Remake, Spooks',				'https://www.youtube.com/c/Kamex',		'BAE2FF'],
			['RayZord',				'ray',				'GOATED song',											'https://www.youtube.com/c/RayZord',	'49A7EB'],
			['Coquers_',			'coquers',			'Shattered (Game Over Music), Mansion Match, G.O.A.T Remake, Heart Attack',	'https://www.youtube.com/c/coquers_',	'D15E56'],
			['Car',					'car',				'Candle-Lit Clash',										'https://www.youtube.com/c/carcarwoah',	'FF3021'],
			['SplatterDash',		'splatter',			'INTERRUPTED, All Saints Scramble Remix, Pasta Night (AFK Mix)',	'https://twitter.com/splatterdash_ng',	'72B2F2'],
			['Jospi',				'jospi',			'Take It Slow (Pause Music), Megamix (Credits Song), Minimize, Jelly Jamboree',	'https://twitter.com/jospi_music',	'96FAFF'],
			['JunoSongs',			'juno',				'Lyrics and singer for Spooks',							'https://www.youtube.com/@JunoSongs',	'B563DB'],
			[''],
			['Charting'],
			['Sayge',				'sayge',			'Charter for Spectral Sonnet and After Dark',			'https://twitter.com/Sayge3D',			'FFA44F'],
			['ChubbyGamer',			'chubby',			'Charter for Interruped, Spooks, and Pasta Night (AFK Mix)','https://twitter.com/ChubbyAlt',	'C78A58'],
			['PpavlikosS',			'pav',				'The rest of the songs lol',							'https://twitter.com/ppavlikoss',		'BAE2FF'],
			[''],
			['Misc.'],
			['David H.',			'blank',			'Album cover Artwork',									' ',									'72A3ED'],
			['Smokeyy',				'smokeyy',			'Release trailer',										'https://twitter.com/Smokiixx',			'716A73'],			
			['Hotline 024 team',	'nikku',			'Thank you Sakury and the H024 team for letting us use Nikku!','https://gamebanana.com/mods/373298',			'FF3021'],
			['Ourple Guy team',		'guy',				'Thank you Kiwiquest and the Ourple Guy team for letting us use the characters!','https://gamebanana.com/mods/357511',			'BD51DB'],
			['Hypnos Lullaby Team',	'hypno',			'Thank you Punkett, iKenny, and TheInnuendo, creators of Pasta Night ','https://fridaynightfunking.fandom.com/wiki/Friday_Night_Funkin%27_Lullaby',			'F7BF45'],
			[''],
			['Special Thanks'],
			['Past Vs Alfie members','blank',			'Including MisterParakeet, ThisIsBennyK, StardustTunes, Dami and NemoInABottle',' ',			'D23B48'],
			['Flippy and Gegcoin',	'blank',			'For always playing vs Alfie',							' ',									'BDBCC4'],
			['MattDoes_',			'blank',			'For Always Following Vs Alfie',						' ',									'49E3E6'],
			['Tesseption',			'blank',			'For Always Following Vs Alfie',						' ',									'D149E6'],
			['FlarinthK',			'blank',			' ',													' ',									'F78F45'],
			['SirSins',				'blank',			' ',													' ',									'F78F45'],
			['Alfie and Filip fan Server',	'blank',	' ',													' ',									'F78F45'],
			['Fans and Supporters',	'blank',			'For the fan content (we really appreciate it!!)',		' ',									'98ED87'],
			['And you',				'blank',			'cuz we really do be cheesy like that',					' ',									'D42C3D'],
			['']
		];
		
		for(i in pisspoop){
			creditsStuff.push(i);
		}
	
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false, null, null, isSelectable);
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

		descText = new FlxFixedText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		FlxG.mouse.visible = true;

		
		replayButton = new FlxButton(FlxG.width-200-10, FlxG.height-70-10, "", function()
		{
			MusicBeatState.switchState(new ChartCredits("ChartCredits"));
		});
		replayButton.frames = Paths.getSparrowAtlas('ui/creditsbutton');
		replayButton.animation.addByPrefix('normal', 'idle', 24, false);
		replayButton.animation.addByPrefix('highlight', 'selected', 24, false);
		replayButton.animation.addByPrefix('press', 'selected', 24, false);
		replayButton.animation.play('normal');

		replayButton.setGraphicSize(200, 70);
		replayButton.updateHitbox();
		//replayButton.label.fieldWidth = 200;
		//replayButton.label.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		//setAllLabelsOffset(replayButton, 2, 24);
		add(replayButton);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if(controls.ACCEPT) {
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int =  getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
					/*if(colorSubTween != null) {
						colorSubTween.cancel();
					}
					colorSubTween = FlxTween.color(replayButton, 0.25, replayButton.color, intendedColor, {
						onComplete: function(twn:FlxTween) {
							colorSubTween = null;
						}
					});*/
					
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		descText.text = creditsStuff[curSelected][2];
	}

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}