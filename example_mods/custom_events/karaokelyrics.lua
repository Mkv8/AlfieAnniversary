--script by BCTIX you can delete this if u want lol

-- ez settings lol

-- 0 is the middle of the screen
local xOffset = 0
local yOffset = 150

local size = 36

local setColor = 'ffffff'
local sungColor = 'ff0000'

local font = 'vcr.ttf'




function onCreate()
	makeLuaText('setlyric','',1000,screenWidth/2 + xOffset,screenHeight/2 + yOffset);
	setTextSize('setlyric',size);
	setTextAlignment('setlyric','left');
	setTextColor('sunglyric', setColor)
	setObjectCamera('setlyric', 'other')
	setTextFont('setlyric', font)
	addLuaText('setlyric');

	makeLuaText('sunglyric','',1000,screenWidth/2 + xOffset,screenHeight/2 + yOffset);
	setTextSize('sunglyric',size);
	setTextAlignment('sunglyric','left');
	setTextColor('sunglyric', sungColor)
	setObjectCamera('sunglyric', 'other')
	setTextFont('sunglyric', font)
	addLuaText('sunglyric');
end
--[[
function onUpdatePost()
	setProperty('sunglyric.x', getProperty('setlyric.x')) -- make sure sung text is always ontop of set text
end
]]
--Below is an example replacement
function setUpdatePost()
    runHaxeCode([[
    function onUpdatePost(elapsed:Float) {
	    var a = game.modchartTexts.get("sunglyric");
		var b = game.modchartTexts.get("setlyric");
		if(a!=null && b!=null){
			a.x = b.x;
			a.y = b.y;
		}
    }
    game.setUpdaterPost = onUpdatePost;
    ]])
end
function onEvent(name, value1, value2)
	if name == 'karaokelyrics' then
		if value1 == 'set' or value1 == '' then
			setProperty('setlyric.x', screenWidth/2-(#value2*11)+ xOffset) --attempt to emulate center alignment
			setTextString('setlyric', value2)
			setTextString('sunglyric', '')
		end
		if value1 == 'sung' then
			setTextString('sunglyric', value2)
		end
	end
end
