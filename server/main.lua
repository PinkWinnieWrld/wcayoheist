local QBCore = exports['qb-core']:GetCoreObject()

HeistState = {
    active     = false,
    lastHeist  = 0,
    leader     = nil,
    team       = {},
    approach   = nil,
    difficulty = 'normal',
}

GuardState = { peds = {} }
LootCooldowns = {}

GlobalState.CayoHeistActive = false

local function GetOnDutyCops()
    local amount = 0
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v.PlayerData.job and v.PlayerData.job.name == "police" and v.PlayerData.job.onduty then
            amount += 1
        end
    end
    return amount
end

local function CleanupGuards()
    for _, data in ipairs(GuardState.peds) do
        if data.ped and DoesEntityExist(data.ped) then
            DeleteEntity(data.ped)
        end
    end
    GuardState.peds = {}
end

local function ResetHeist()
    HeistState.active     = false
    HeistState.leader     = nil
    HeistState.team       = {}
    HeistState.approach   = nil
    HeistState.difficulty = 'normal'
    GlobalState.CayoHeistActive = false
    CleanupGuards()
end

local function GetDifficultyConfig()
    local diffKey = HeistState.difficulty or 'normal'
    return Config.Difficulties[diffKey] or Config.Difficulties.normal
end

local function GetTeamSize()
    local count = 0
    for _ in pairs(HeistState.team) do count += 1 end
    return math.max(count, 1)
end

-- TEAM

RegisterNetEvent('cayoheist:server:joinTeam', function()
    local src = source
    if HeistState.active then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Heist already active.' })
        return
    end

    if not HeistState.leader then
        HeistState.leader = src
    end

    local count = 0
    for _ in pairs(HeistState.team) do count += 1 end
    if count >= Config.MaxTeamSize then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Team is full.' })
        return
    end

    HeistState.team[src] = true
    TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = 'Joined Cayo heist team.' })
end)

-- START HEIST

RegisterNetEvent('cayoheist:server:startHeist', function(approach, difficulty)
    local src = source
    if src ~= HeistState.leader then return end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if HeistState.active then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Heist already active.' })
        return
    end

    if GetOnDutyCops() < Config.MinCop then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Not enough police on duty.' })
        return
    end

    local now = os.time()
    if HeistState.lastHeist > 0 and (now - HeistState.lastHeist) < Config.HeistCooldown then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Heist is on cooldown.' })
        return
    end

    if Config.JobPrice and Config.JobPrice > 0 then
        if Player.Functions.GetMoney('cash') < Config.JobPrice then
            TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Not enough cash.' })
            return
        end
        Player.Functions.RemoveMoney('cash', Config.JobPrice)
    end

    HeistState.active     = true
    HeistState.lastHeist  = now
    HeistState.approach   = approach
    HeistState.difficulty = difficulty

    GlobalState.CayoHeistActive = true

    TriggerEvent('fd_dispatch:server:notify', {
        code  = 'CAYO_HEIST',
        title = 'Cayo Heist in progress',
        coords = Config.StartLocation,
        jobs  = { 'police' }
    })

    for id, _ in pairs(HeistState.team) do
        TriggerClientEvent('cayoheist:client:beginHeist', id, approach, difficulty)
    end
end)

-- GUARDS

local function SpawnGuardPed(pedData, difficulty, waveName)
    local model = joaat(pedData.model or Config.Guards.baseModel)
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then return end
        Wait(0)
    end

    local ped = CreatePed(4, model, pedData.coords.x, pedData.coords.y, pedData.coords.z, pedData.heading or 0.0, true, true)
    if not DoesEntityExist(ped) then return end

    local diffCfg = GetDifficultyConfig()
    GiveWeaponToPed(ped, joaat(Config.Guards.weapon), 999, false, true)
    SetPedAccuracy(ped, diffCfg.accuracy or 50)
    SetPedArmour(ped, diffCfg.armor or 25)
    SetPedRelationshipGroupHash(ped, `HATES_PLAYER`)
    SetPedAsCop(ped, true)

    GuardState.peds[#GuardState.peds + 1] = { ped = ped, wave = waveName, patrol = pedData.patrol }

    SetModelAsNoLongerNeeded(model)
end

local function SpawnGuardWave(waveIndex)
    local wave = Config.Guards.waves[waveIndex]
    if not wave then return end

    local diffCfg  = GetDifficultyConfig()
    local teamSize = GetTeamSize()

    local basePeds   = wave.peds
    local multiplier = diffCfg.guardMultiplier * (0.5 + teamSize * 0.5)
    local spawnCount = math.floor(#basePeds * multiplier)
    spawnCount       = math.min(spawnCount, #basePeds)

    for i = 1, spawnCount do
        local pos = basePeds[i]
        SpawnGuardPed({ coords = pos, heading = 0.0 }, HeistState.difficulty or 'normal', 'wave_' .. waveIndex)
    end
end

RegisterNetEvent('cayoheist:server:spawnCompoundGuards', function()
    local src = source
    if not HeistState.active or not HeistState.team[src] then
        DropPlayer(src, "Exploit detected (guards spawn).")
        return
    end
    SpawnGuardWave(1) -- initial compound wave if you want
end)

RegisterNetEvent('cayoheist:server:completeHackStage', function(stage)
    local src = source
    if not HeistState.active or not HeistState.team[src] then return end

    if stage == 'hack2' and Config.SpawnPedOnHack2 then
        SpawnGuardWave(1)
    elseif stage == 'hack3' and Config.SpawnPedOnHack3 then
        SpawnGuardWave(2)
    elseif stage == 'lootdoor' and Config.SpawnPedOnLootDoor then
        SpawnGuardWave(3)
        TriggerEvent('cayoheist:server:startEscape', src)
    end
end)

-- ESCAPE

RegisterNetEvent('cayoheist:server:startEscape', function()
    local diffCfg  = GetDifficultyConfig()
    local teamSize = GetTeamSize()
    local coordsList = Config.Escape.extraEscapeGuards.coords

    local multiplier = diffCfg.guardMultiplier * (0.5 + teamSize * 0.5)
    local spawnCount = math.floor(#coordsList * multiplier)
    spawnCount       = math.min(spawnCount, #coordsList)

    for i = 1, spawnCount do
        local pos = coordsList[i]
        SpawnGuardPed({ coords = pos, heading = 0.0 }, HeistState.difficulty or 'normal', 'escape')
    end

    for id, _ in pairs(HeistState.team) do
        TriggerClientEvent('cayoheist:client:startEscape', id)
    end
end)

-- LOOT

RegisterNetEvent('cayoheist:server:lootSpot', function(index)
    local src = source
    if not HeistState.active or not HeistState.team[src] then return end

    local spot = Config.LootSpots[index]
    if not spot then return end

    local now = os.time()
    if LootCooldowns[index] and (now - LootCooldowns[index]) < (spot.cooldown or 300) then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Already looted.' })
        return
    end

    LootCooldowns[index] = now

    local tier = Config.Loot[spot.tier]
    if not tier then return end

    exports.ox_inventory:AddItem(src, tier.item, math.random(tier.min, tier.max))

    if tier.rareItem and math.random(100) <= 25 then
        exports.ox_inventory:AddItem(src, tier.rareItem, math.random(tier.rareMin, tier.rareMax))
    end
end)

-- FINISH / FAIL

RegisterNetEvent('cayoheist:server:finishHeist', function()
    local src = source
    if not HeistState.active or not HeistState.team[src] then return end

    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        exports.ox_inventory:AddItem(src, 'goldbar', math.random(3, 6))
    end

    for id, _ in pairs(HeistState.team) do
        if id ~= src then
            exports.ox_inventory:AddItem(id, 'goldbar', math.random(1, 3))
        end
    end

    ResetHeist()
end)

RegisterNetEvent('cayoheist:server:failHeist', function()
    ResetHeist()
end)

AddEventHandler('playerDropped', function()
    local src = source
    HeistState.team[src] = nil
end)
