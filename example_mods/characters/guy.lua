flipped = true
flippedIdle = false
defaultY = 0
function onCreatePost()
	defaultY = getProperty('ourpleguy.y')
end
function onBeatHit() 
	if getProperty('healthBar.percent') < 80 then
		flipped = not flipped
		setProperty('iconP2.flipX', flipped)
	end
	
	if curBeat % 1 == 0 and getProperty('ourpleguy.animation.curAnim.name') == 'idle' then
		flippedIdle = not flippedIdle
		setProperty('ourpleguy.flipX', flippedIdle)
		setProperty('ourpleguy.y', getProperty('ourpleguy.y') + 20)
		doTweenY('raise', 'ourpleguy', getProperty('ourpleguy.y') - 20, 0.15, 'cubeOut')
	end
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
	if not getPropertyFromGroup('notes', id, 'gfNote') then
	cancelTween('raise')
	setProperty('ourpleguy.y', defaultY)
	setProperty('ourpleguy.flipX', false)
	end
end

function onStepHit() 
	if getProperty('healthBar.percent') > 80 and curStep % 2 == 0 then
		flipped = not flipped
		setProperty('iconP2.flipX', flipped)
	end
end

function onUpdate(e)
	local angleOfs = math.random(-5, 5)
	if getProperty('healthBar.percent') > 80 then
		setProperty('iconP2.angle', angleOfs)
	else
		setProperty('iconP2.angle', 0)
	end
end
