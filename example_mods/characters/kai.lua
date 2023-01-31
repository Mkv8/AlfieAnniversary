function onCreatePost()
    runHaxeCode([[
var chars = [game.dad, game.dadMap.get("kai")];
for(char in chars) if(char != null && char.curCharacter == "kai")
char.danceEveryNumBeats = 2;
]])
close(true)
end