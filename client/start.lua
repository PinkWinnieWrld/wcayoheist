local QBCore = exports['qb-core']:GetCoreObject()

lib.zones.sphere({
    coords = Config.StartLocation,
    radius = 2.0,
    inside = function()
        lib.showTextUI('[E] Cayo Heist')

        if IsControlJustPressed(0, 38) then
            local choice = lib.inputDialog('Cayo Heist', {
                { type = 'select', label = 'Action', options = {
                    { label = 'Join Team', value = 'join' },
                    { label = 'Start Heist (Leader)', value = 'start' },
                }, required = true },
                { type = 'select', label = 'Approach', options = {
                    { label = 'Boat', value = 'boat' },
                    { label = 'Grapple', value = 'grapple' },
                }},
                { type = 'select', label = 'Difficulty', options = {
                    { label = 'Easy', value = 'easy' },
                    { label = 'Normal', value = 'normal' },
                    { label = 'Hard', value = 'hard' },
                    { label = 'Nightmare', value = 'nightmare' },
                }},
            })

            if not choice then return end

            local mode       = choice[1]
            local approach   = choice[2]
            local difficulty = choice[3]

            if mode == 'join' then
                TriggerServerEvent('cayoheist:server:joinTeam')
            elseif mode == 'start' then
                if not approach or not difficulty then
                    lib.notify({ type = 'error', description = 'Select approach and difficulty.' })
                    return
                end
                TriggerServerEvent('cayoheist:server:startHeist', approach, difficulty)
            end
        end
    end,
    onExit = function()
        lib.hideTextUI()
    end
})

RegisterNetEvent('cayoheist:client:beginHeist', function(approach, difficulty)
    HeistClient.inHeist    = true
    HeistClient.approach   = approach
    HeistClient.difficulty = difficulty

    TriggerEvent('cayoheist:client:startApproach', approach)
end)
