local camzooms = false
function onBeatHit()
    if not camzooms then
        if getProperty("camZooming") and (getProperty("camGame.zoom") < 1.35) and cameraZoomOnBeat and (curBeat % 4 == 0) then
            setProperty("camGame.zoom", getProperty("camGame.zoom") - 0.015)
            setProperty("camHUD.zoom", getProperty("camHUD.zoom") - 0.03)
        end
    end
end

function onEvent(name, value_1, value_2)
    if name == "Add Camera Zoom" then
        if not (getProperty("camZooming") and (getProperty("camGame.zoom") < 1.35) and cameraZoomOnBeat and (curBeat % 4 == 0)) then
            setProperty("camGame.zoom", getProperty("camGame.zoom") + (((value_1 ~= "") and value_1 or 0.015) * 1))
            setProperty("camHUD.zoom", getProperty("camHUD.zoom") + (((value_2 ~= "") and value_1 or 0.03) * 1))
        end
    end
end