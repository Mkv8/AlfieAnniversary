function onCreatePost()
    runHaxeCode([[
var chars = [game.dad, game.dadMap.get("alfiemonster")];
for(char in chars) if(char != null && char.curCharacter == "alfiemonster")
char.danceEveryNumBeats = 2;
]])
close(true)
end