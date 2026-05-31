RegisterNetEvent('cayoheist:client:startApproach', function(approach)
    if approach == 'boat' then
        TriggerEvent('cayoheist:client:boatApproach')
    elseif approach == 'grapple' then
        TriggerEvent('cayoheist:client:grappleApproach')
    end
end)

RegisterNetEvent('cayoheist:client:grappleApproach', function()
    local attempts, maxAttempts = 0, 3

    SetEntityCoords(cache.ped, -1600.12, 4200.55, 80.12)
    SetEntityHeading(cache.ped, 210.0)
    lib.notify({ type = 'info', description = 'Prepare your grapple gear...' })
    Wait(1500)

    while attempts < maxAttempts do
        attempts += 1
        local success = lib.skillCheck({'easy','medium','medium'}, {'w','a','s','d'})
        if success then
            TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_CLIMBING", 0, true)
            Wait(3500)
            ClearPedTasks(cache.ped)

            SetEntityCoords(cache.ped, 5000.12, -5200.44, 20.12)
            SetEntityHeading(cache.ped, 90.0)

            TriggerEvent('cayoheist:client:enterCompound')
            return
        else
            lib.notify({ type = 'error', description = 'You slipped! Try again.' })
        end
    end

    lib.notify({ type = 'error', description = 'You failed to climb.' })
    TriggerServerEvent('cayoheist:server:failHeist')
end)

RegisterNetEvent('cayoheist:client:boatApproach', function()
    local attempts, maxAttempts = 0, 3

    SetEntityCoords(cache.ped, -3200.55, -1200.44, 0.50)
    SetEntityHeading(cache.ped, 270.0)
    lib.notify({ type = 'info', description = 'Approaching island by boat...' })
    Wait(2000)

    while attempts < maxAttempts do
        attempts += 1
        local success = lib.skillCheck({'easy','easy','medium'}, {'w','a','s','d'})
        if success then
            lib.notify({ type = 'success', description = 'Engine bypassed. Moving in quietly...' })
            Wait(2000)

            SetEntityCoords(cache.ped, 4980.22, -5100.33, 2.12)
            SetEntityHeading(cache.ped, 180.0)

            TriggerEvent('cayoheist:client:enterCompound')
            return
        else
            lib.notify({ type = 'error', description = 'Bypass failed. Try again.' })
        end
    end

    lib.notify({ type = 'error', description = 'You failed to bypass the engine.' })
    TriggerServerEvent('cayoheist:server:failHeist')
end)
