function onCreatePost() 
      print("hi neo i agree alfie is p cute");
      luaDebugMode = true
      addHaxeLibrary("Character")
	runHaxeCode([[
	var charList:Array<String> = ["phone","ourplemark", "guy", "crying"];
	var positions:Array<Array<Float>> = [ [-50, -400], [-180, -350 ], [-50, -10], [-50, 10] ];
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
end


--function onUpdate()
--	runHaxeCode([[
--	var dName:String = getVar('dName');
--	var chars:Array<Character> = getVar('CharScriptChars');
--	var charList:Array<String> = getVar('CharScriptList');
--	//Track Character changes and move the opponent to the correct position
--	if(dName!=game.dad.curCharacter){
--		dName = game.dad.curCharacter;
--		if(charList.indexOf(dName)<0)
--			return;
--		var char:Character = chars[charList.indexOf(dName)];
--		for (dad in chars){
--			dad.alpha=1;
--		}
--		if (char.alpha > 0.1){
--			//char.alpha = 0.00001; 
--			//game.dad.setPosition(char.x,char.y);
--		}
--	}
--	setVar('dName',dName); ]])
--end
function handleDance()
	runHaxeCode([[
	var counted:Bool = getVar('counted');
	var chars:Array<Character> = getVar('CharScriptChars');
	
	for (dad in chars){
		//Strange glitch happens sometimes so new variable strAnim lol
		var strAnim:String = dad.animation.curAnim; 
		if(strAnim != null){
			strAnim=strAnim.name;
		}
		if ((PlayState.instance.curBeat-(counted?0:1)) % 2 == 0 && strAnim !=null && !strAnim.indexOf('sing')>=0 && dad!=null && !dad.stunned)
		{
			dad.dance();
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
