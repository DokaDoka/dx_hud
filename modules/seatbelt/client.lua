if cfg.seatbelt.enabled then
    local isBuckled = false

    local Buckled = function()
        CreateThread(function()
            while isBuckled do
                DisableControlAction(0, 75, true)
                Wait(0)
            end
        end)
    end

    SetFlyThroughWindscreenParams(15.0, 20.0, 17.0, 2000.0)
    local Seatbelt = function(status)
        if status then
            SendMessage('playSound', 'buckle')
            SendMessage('setSeatbelt', { toggled = true, buckled = true })
            SetFlyThroughWindscreenParams(1000.0, 1000.0, 0.0, 0.0)
            Buckled()
        else
            SendMessage('playSound', 'unbuckle')
            SendMessage('setSeatbelt', { toggled = true, buckled = false })
            SetFlyThroughWindscreenParams(15.0, 20.0, 17.0, 2000.0)
        end
        isBuckled = status
    end

    local helmetLoop = false

    local Helmet = function(currentVehicle)
        helmetLoop = true

        SetPedConfigFlag(cache.ped, 380, false)

        while currentVehicle == cache.vehicle and not IsPedWearingHelmet(cache.ped) do
            Wait(0)
        end

        SetPedConfigFlag(cache.ped, 380, true)

        if IsPedWearingHelmet(cache.ped) then
            SendMessage('setHelmet', { toggled = true, on = true })
        end

        helmetLoop = false
    end

    local vehicleTypes = setmetatable({}, {
        __index = function(self, index)
            local data = Ox.GetVehicleData(index)

            if data then
                self[index] = data.type
                return data.type
            end
        end
    })

    local curInVehicle

    CreateThread(function()
        while true do
            if nuiReady then
			    local inVehicle = cache.vehicle
                if inVehicle ~= curInVehicle then
                    local hasSeatbelt = true
                    local hasHelmet = false

                    if inVehicle then
                        local vType = vehicleTypes[GetEntityArchetypeName(cache.vehicle)]

                        if vType == 'bike' or vType == 'quadbike' or vType == 'amphibious_quadbike' then
                            hasSeatbelt = false
                            hasHelmet = true
                        elseif vType == 'bicycle' then
                            hasSeatbelt = false
                        end
                    end

                    SendMessage('setSeatbelt', { toggled = inVehicle and hasSeatbelt })
                    SendMessage('setHelmet', { toggled = inVehicle and hasHelmet, on = IsPedWearingHelmet(cache.ped) })

                    if not inVehicle and isBuckled then isBuckled = false end
                    curInVehicle = inVehicle
                end
            end
            Wait(cfg.refreshRates.checks)
        end
    end)

    lib.addKeybind({
        name = 'seatbelt',
        description = 'Toggle Seatbelt / Helmet',
        defaultKey = cfg.seatbelt.key,
        onReleased = function()
            if cache.vehicle then
                local vType = vehicleTypes[GetEntityArchetypeName(cache.vehicle)]

                if vType == 'bike' or vType == 'quadbike' or vType == 'amphibious_quadbike' then
                    if not (IsPedWearingHelmet(cache.ped) or helmetLoop) then
                        Helmet(cache.vehicle)
                    end
                elseif vType ~= 'bicycle' then
                    Seatbelt(not isBuckled)
                end
            end
        end
    })
end
