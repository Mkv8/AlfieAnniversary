function onEvent(ev, v1, v2)
    if ev == "Opposing" then
        if not middlescroll then
            local y = 50
            if not downscroll then
                y = 720 - 150
            end
            for i = 0,3 do
                setPropertyFromGroup("opponentStrums", i, "x", -278 + (160*0.7)*i + 1280*0.5*1 + 50)
                setPropertyFromGroup("opponentStrums", i, "downScroll", not downscroll)
                setPropertyFromGroup("opponentStrums", i, "y", y)
                setPropertyFromGroup("opponentStrums", i, "alpha", 0.4)
            end
            for i = 0,3 do
                setPropertyFromGroup("playerStrums", i, "x", -278 + (160*0.7)*i + 1280*0.5*1 + 50)
            end
        end
    end

    if ev == "Default Strums" then
        if not middlescroll then
            local y = 50
            if downscroll then
                y = 720 - 150
            end
            for i = 0,3 do
                setPropertyFromGroup("opponentStrums", i, "x", 42 + (160*0.7)*i + 1280*0.5*0 + 50)
                setPropertyFromGroup("opponentStrums", i, "downScroll", downscroll)
                setPropertyFromGroup("opponentStrums", i, "y", y)
                setPropertyFromGroup("opponentStrums", i, "alpha", 1)
            end
            for i = 0,3 do
                setPropertyFromGroup("playerStrums", i, "x", 42 + (160*0.7)*i + 1280*0.5*1 + 50)
            end
        end
    end
end