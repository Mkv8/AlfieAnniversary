function onEvent(n,v1,v2)
	if n == 'Flash Camera' then
		runHaxeCode([[
		    game.camGame.flash(-1,]]..v1..[[, true);
		]])

	end
end