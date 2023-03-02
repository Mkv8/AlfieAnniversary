function onCreate()
    setPropertyFromClass("ClientPrefs", "middleScroll", false)
end

function onEndSong()
    setPropertyFromClass("ClientPrefs", "middleScroll", middlescroll)
end

function onDestroy()
    setPropertyFromClass("ClientPrefs", "middleScroll", middlescroll)
end