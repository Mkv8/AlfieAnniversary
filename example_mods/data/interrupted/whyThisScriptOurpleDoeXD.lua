didStart = false
function onCreatePost()
	setProperty('noteSplashGloballyDisabled', true);
	if didStart then return end
	didStart = true 
      print("hi neo i agree alfie is p cute");
      luaDebugMode = true
      addHaxeLibrary("Character")
	runHaxeCode([[
	var charList:Array<String> = ["crying","guy", "ourplemark", "phone"];
  	var positions:Array<Array<Float>> = [ [0, 40], [-45, -1000], [150, -50 ], [-1000, 0] ];
	var index = 0;

     // meow meow gay cat
	
	var chars:Array<Character> = [];
	for (charStr in charList){
		var char:Character = null;
		if(!game.dadMap.exists(charStr)) {
			char = new Character(0,0, charStr);
		}else{
                 char = game.dadMap.get(charStr);
			char.setPosition(0,0);
           }
		char.setPosition(positions[index][0] + char.positionArray[0], positions[index][1]+char.positionArray[1]);
		char.alpha = 1;
		chars.push(char);
		game.dadGroup.add(char);
		game.dadMap.set(charStr,char);
		index++;
	}
	
	trace(chars.length);
      trace("Trans Rights");
	//Unfortunately later hscript calls do not share the same context some reason
	setVar('CharScriptList',charList);
	setVar('CharScriptChars',chars);
	setVar('dName',"");
      ]])

triggerEvent("Change Char EX", "dad", "crying") 
Add game.reloadHealthbarColors();
end


function onEvent()
	runHaxeCode([[
	var dName:String = getVar('dName');
	//Track Character changes and move the opponent to the correct position
	if(dName!=game.dad.curCharacter){
		var chars:Array<Character> = getVar('CharScriptChars');
		var charList:Array<String> = getVar('CharScriptList');
		dName = game.dad.curCharacter;
		if(charList.indexOf(dName)<0)
			return;
		var char:Character = chars[charList.indexOf(dName)];
		for (dad in chars){
			dad.alpha=1;
		}
		if (char.alpha > 0.1){
			//char.alpha = 0.00001; 
			//game.dad.setPosition(char.x,char.y);
		}
	}
	setVar('dName',dName); ]])
end
function handleDance()
	runHaxeCode([[
	var counted:Bool = getVar('counted');
	if((game.curBeat-(counted?0:1)) % 2 == 0) {
   	 var chars:Array<Character> = getVar('CharScriptChars');
    
  	 for (dad in chars){
        //Strange glitch happens sometimes so new variable strAnim lol
        var strAnim = dad.animation.name; 
        if (strAnim != null && strAnim.indexOf('sing')==-1 && !dad.stunned)
        {
            dad.dance();
        }
    	}
	} ]])
end

function onBeatHit()
	runHaxeCode([[setVar('counted', true);]]);
	handleDance()
end

function onCountdownTick()
	runHaxeCode([[setVar('counted', false);]]);
	handleDance()
end
