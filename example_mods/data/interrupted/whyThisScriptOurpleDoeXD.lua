function onCreate()
	addHaxeLibrary("Character")
end

function onCreatePost()
	runHaxeCode([[
	var charList:Array<String> = ["crying","phone","ourplemark"];
	var positions:Array<Array<Float>> = [   [-300, -400], [-50, -700], [-260 , -750]    ];
	var objectOrder:Array<Array<Float>> = [   1,2,3   ];
	var index = 0;
	
	var chars:Array<Character> = [];
	for (charStr in charList){
		var char:Character = PlayState.instance.dadMap.get(charStr);
		if(!PlayState.instance.dadMap.exists(charStr)){
			char = new Character(0,0, charStr);
		else
			char.setPosition(0,0);
		char.setPosition(positions[index][0] + char.positionArray[0], positions[index][1]+char.positionArray[1]);
		char.alpha = 1;
		chars.push(char);
		PlayState.instance.dadGroup.add(char);
		PlayState.instance.dadMap.set(charStr,char);
		index++;
	}
	
	//Unfortunately later hscript calls do not share the same context some reason
	PlayState.instance.variables.set('CharScriptList',charList);
	PlayState.instance.variables.set('CharScriptChars',chars);
	PlayState.instance.variables.set('dName',""); ]])
end


function onUpdate()
	runHaxeCode([[
	var dName:String = PlayState.instance.variables.get('dName');
	var chars:Array<Character> = PlayState.instance.variables.get('CharScriptChars');
	var charList:Array<String> = PlayState.instance.variables.get('CharScriptList');
	//Track Character changes and move the opponent to the correct position
	if(dName!=PlayState.instance.dad.curCharacter){
		dName = PlayState.instance.dad.curCharacter;
		if(charList.indexOf(dName)<0)
			return;
		var char:Character = chars[charList.indexOf(dName)];
		for (dad in chars){
			dad.alpha=1;
		}
		if (char.alpha > 0.1){
			//char.alpha = 0.00001; 
			//PlayState.instance.dad.setPosition(char.x,char.y);
		}
	}
	PlayState.instance.variables.set('dName',dName); ]])
end

function handleDance(isCountedDown)
	runHaxeCode([[
	var counted:Bool = ]]..tostring(isCountedDown)..[[;
	var chars:Array<Character> = PlayState.instance.variables.get('CharScriptChars');
	
	for (dad in chars){
		//Strange glitch happens sometimes so new variable strAnim lol
		var strAnim:String = dad.animation.curAnim; 
		if(strAnim != null){
			strAnim=strAnim.name;
		}
		if ((PlayState.instance.curBeat-(counted?0:1)) % 2 == 0 && strAnim !=null && !strAnim.indexOf('sing')>=0 && !dad.stunned)
		{
			dad.dance();
		}
	} ]])
end

function onBeatHit()
	handleDance(true)
end

function onCountdownTick()
	handleDance(false)
end
