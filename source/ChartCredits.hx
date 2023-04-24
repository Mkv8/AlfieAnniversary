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
import flixel.text.FlxText.FlxTextBorderStyle;

import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
import FunkinLua.HScript;
import FunkinLua.CustomSubstate;


import Type.ValueType;


class ChartCredits extends MusicBeatState
{
	public static var hscript:HScript = null;
	public var curMod ="";
		
	public function initHaxeModule()
	{
		
		hscript = null; //man I hate this but idk how else to do it lol
		try{
			if(hscript == null)
			{
				trace('initializing haxe interp for CustomBeatState');
				hscript = new HScript(); 
				hscript.interp.variables.set('game', cast(this,MusicBeatState));
				hscript.interp.variables.set('controls', controls);
				//Thanks Neo!
				hscript.interp.variables.set("import", function(pkg) {
					var a = pkg.split(".");
					var e = Type.resolveEnum(pkg);
					hscript.interp.variables.set(a[a.length-1], e!=null?e:Type.resolveClass(pkg));
				});

			}
		}catch(err){
			trace("Failed to intialize HScript (CustomBeatState)");
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
			trace(err);
		}
	}

	public function runHScript(name:String, hscript:FunkinLua.HScript, ?modFolder:String="", ?isCustomState:Bool=false){
		try{
			var path:String = "mods/"+modFolder+"/"+name; // Paths.getTextFromFile(name);
			var y = '';
			//PLEASE WORK 
			if (FileSystem.exists(path)){
				trace(path);
				y = File.getContent(path);
			}else if(FileSystem.exists(Paths.modFolders(modFolder+"/"+name))){
				trace(Paths.modFolders(modFolder+"/"+name));
				y = File.getContent(path);
			}else if(FileSystem.exists(modFolder+"/"+name)){
				trace(modFolder+"/"+name);
				y = File.getContent(path);
			}else if(FileSystem.exists(Paths.modFolders(name))){
				trace(Paths.modFolders(name));
				y = File.getContent(path);
			}else{
				trace(path + "Does not exist");
				y = Paths.getTextFromFile(modFolder+"/"+name);
				/*if(isCustomState){
					MusicBeatState.switchState(new MainMenuState());
				}*/
			}
			hscript.execute(y);
		}
		catch(err){
			trace(err);
		}
	}

	public function quickCallHscript(event:String,args:Array<Dynamic>){
		try{
			var ret = hscript.variables.get(event);
			if(ret != null){
				Reflect.callMethod(null, ret, args);
			}
		}
		catch(err){
			trace("\n["+event+"] Stage Function Error: " + err);
		}
	}

	public var name:String = 'chartCredits';
	public static var instance:ChartCredits;

	override function create()
	{
		curMod = Paths.currentModDirectory;
		trace("creation");
		instance = this;
		super.create();
		trace("create super");
		//PlayState.instance.callOnLuas('create', [name]);
		#if hscript
		initHaxeModule();
		runHScript("data/"+name+".hx",hscript, curMod, true);
		#end
		quickCallHscript("create",[]);	
		//There is no difference here, if 
		quickCallHscript("createPost",[]);
		
	}
	
	public function new(nameinput:String)
	{
		trace("new");
		
		name = nameinput;
		super();
		trace("new super");
		
		//cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
	
	override function beatHit()
	{
		quickCallHscript("beatHit",[]);
		super.beatHit();
		quickCallHscript("beatHitPost",[]);
		//FlxG.log.add('beat');
	}
	
	override function update(elapsed:Float)
	{
		quickCallHscript("update",[elapsed]);
		super.update(elapsed);
		quickCallHscript("updatePost",[elapsed]);
	}

	override function destroy()
	{
		quickCallHscript("stateDestroy",[]);
		super.destroy();
	}
}