-- enter compound → spawn guards server-side
RegisterNetEvent('cayoheist:client:enterCompound', function()
    TriggerServerEvent('cayoheist:server:spawnCompoundGuards')
end)

-- HACKS

RegisterNetEvent('cayoheist:client:doHack1', function()
    if not exports.ox_inventory:Search('count', Config.Hack1.item) then
        lib.notify({ type = 'error', description = 'Missing required item.' })
        return
    end

    exports['SN-Hacking']:StartHack(function(success)
        if success then
            TriggerServerEvent('cayoheist:server:completeHackStage', 'hack1')
        else
            lib.notify({ type = 'error', description = 'Hack failed.' })
        end
    end)
end)

RegisterNetEvent('cayoheist:client:doHack2', function()
    if not exports.ox_inventory:Search('count', Config.Hack2.item) then
        lib.notify({ type = 'error', description = 'Missing required item.' })
        return
    end

    exports['ps-ui']:Circle(function(success)
        if success then
            TriggerServerEvent('cayoheist:server:completeHackStage', 'hack2')
        else
            lib.notify({ type = 'error', description = 'Hack failed.' })
        end
    end, Config.Hack2.blocks, Config.Hack2.timeHack)
end)

RegisterNetEvent('cayoheist:client:doHack3', function()
    if not exports.ox_inventory:Search('count', Config.Hack3.item) then
        lib.notify({ type = 'error', description = 'Missing required item.' })
        return
    end

    exports['SN-Hacking']:StartHack(function(success)
        if success then
            TriggerServerEvent('cayoheist:server:completeHackStage', 'hack3')
        else
            lib.notify({ type = 'error', description = 'Hack failed.' })
        end
    end)
end)

RegisterNetEvent('cayoheist:client:doBombDoor', function()
    if not exports.ox_inventory:Search('count', Config.Bomb.item) then
        lib.notify({ type = 'error', description = 'Missing thermite.' })
        return
    end

    exports['ps-ui']:Thermite(function(success)
        if success then
            TriggerServerEvent('cayoheist:server:completeHackStage', 'lootdoor')
        else
            lib.notify({ type = 'error', description = 'Thermite failed.' })
        end
    end, Config.Bomb.blocks, Config.Bomb.timeShow, Config.Bomb.timeHack)
end)

-- LOOT SPOTS

CreateThread(function()
    for i, spot in ipairs(Config.LootSpots) do
        lib.zones.sphere({
            coords = spot.coords,
            radius = 1.0,
            inside = function()
                lib.showTextUI('[E] Loot')
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent('cayoheist:server:lootSpot', i)
                end
            end,
            onExit = function()
                lib.hideTextUI()
            end
        })
    end
end)

-- ESCAPE

RegisterNetEvent('cayoheist:client:startEscape', function()
    lib.notify({ type = 'info', description = 'Reach the extraction point!' })

    lib.zones.sphere({
        coords = Config.Escape.extractPoint,
        radius = 3.0,
        inside = function()
            lib.showTextUI('[E] Escape')
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('cayoheist:server:finishHeist')
            end
        end,
        onExit = function()
            lib.hideTextUI()
        end
    })
end)
