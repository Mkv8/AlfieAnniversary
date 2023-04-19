function onEvent(n,v1,v2)
	if n == 'Flash Camera Less Opacity' then
		makeLuaSprite('flash', '', 0, 0);
		makeGraphic('flash',1,1,'ffffff')
		addLuaSprite('flash', true);
		setScrollFactor('flash',0,0)
		setProperty('flash.scale.x',2 * 1280)
		setProperty('flash.scale.y',2 * 720)
		setProperty('flash.alpha',0.6)
		updateHitbox('flash');
		screenCenter('flash');
		doTweenAlpha('flTw','flash',0,v1,'linear')
	end
end