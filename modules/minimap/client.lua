local mapState = 1
local mapLimit = 3

if cfg.circleMap then
    mapLimit = 1

    CreateThread(function()
        DisplayRadar(false)

        RequestStreamedTextureDict('circlemap', false)
        repeat Wait(100) until HasStreamedTextureDictLoaded('circlemap')
        AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'circlemap', 'radarmasksm')

        SetMinimapClipType(1)
        SetMinimapComponentPosition('minimap', 'L', 'B', -0.017, 0.021, 0.207, 0.32)
        SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.06, 0.05, 0.132, 0.260)
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', 0.005, -0.01, 0.166, 0.257)

        repeat Wait(100) until player

        Wait(500)
        SetBigmapActive(true, false)
        Wait(500)
        SetBigmapActive(false, false)

        local minimap = RequestScaleformMovie('minimap')
        repeat Wait(100) until HasScaleformMovieLoaded(minimap)

        DisplayRadar(cfg.persistentRadar)
        while true do
            BeginScaleformMovieMethod(minimap, 'SETUP_HEALTH_ARMOUR')
            ScaleformMovieMethodAddParamInt(3)
            EndScaleformMovieMethod()
            Wait(cfg.refreshRates.base)
        end
    end)
end


if cfg.persistentRadar then
    local minimap = RequestScaleformMovie('minimap')

    local function setRadarState()
        if mapState == 0 then
            DisplayRadar(false)
        elseif mapState == 1 then
            DisplayRadar(true)
            SetBigmapActive(false, false)
        elseif mapState == 2 then
            DisplayRadar(true)
            SetBigmapActive(true, false)
        elseif mapState == 3 then
            DisplayRadar(true)
            SetBigmapActive(true, true)
        end
    end

    setRadarState()

    CreateThread(function()
        while true do
            Wait(0)

            BeginScaleformMovieMethod(minimap, 'SETUP_HEALTH_ARMOUR')
            ScaleformMovieMethodAddParamInt(3)
            EndScaleformMovieMethod()
        end
    end)

    lib.addKeybind({
        name = 'cyclemap',
        description = 'Cycle Map',
        defaultKey = 'Z',
        onReleased = function(self)
            if mapState == mapLimit then
                mapState = 0
            else
                mapState += 1
            end

            setRadarState()
        end
    })
end
