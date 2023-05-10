function onEvent(n,v1,v2)
	if n == 'Flash Camera Less Opacity' then
	runHaxeCode([[
	    game.camGame.flash(-1,]]..v1..[[, true);
	    var alpha = 0.7;
	    game.camGame._fxFlashAlpha = alpha;
 	    game.camGame._fxFlashDuration /= alpha;
	]])
	end
end