Config = {}

Config.Locale = 'en'

Config.StartLocation = vec3(-1035.0, -2735.0, 20.0)

Config.MinCop      = 1
Config.JobPrice    = 10000
Config.StartTimer  = 120
Config.FinishTimer = 60

Config.MaxTeamSize   = 4
Config.HeistCooldown = 60 * 60

Config.Approaches = { 'boat', 'grapple' }

Config.Difficulties = {
    easy      = { label = 'Easy',      guardMultiplier = 0.7, accuracy = 30, armor = 10 },
    normal    = { label = 'Normal',    guardMultiplier = 1.0, accuracy = 45, armor = 25 },
    hard      = { label = 'Hard',      guardMultiplier = 1.4, accuracy = 60, armor = 50 },
    nightmare = { label = 'Nightmare', guardMultiplier = 1.8, accuracy = 75, armor = 80 },
}

Config.Hack1 = { item = 'trojan_usb', time = 12, squares = 2, repeat = 1 }
Config.Hack2 = { item = 'electronickit', blocks = 2, failBlocks = 2, timeShow = 10, timeHack = 10 }
Config.Hack3 = { item = 'trojan_usb', time = 12, squares = 2, repeat = 1 }

Config.Bomb = {
    timer      = 10,
    item       = 'thermite',
    blocks     = 2,
    failBlocks = 2,
    timeShow   = 10,
    timeHack   = 10,
}

Config.Loot = {
    [1] = { item = 'weapon_combatpistol', min = 1, max = 3, rareItem = 'weapon_microsmg', rareMin = 1, rareMax = 3 },
    [2] = { item = 'goldbar', min = 1, max = 4, rareItem = 'weapon_assaultrifle', rareMin = 1, rareMax = 2 },
    [3] = { item = 'goldbar', min = 1, max = 4, rareItem = 'weapon_assaultrifle', rareMin = 1, rareMax = 2 },
}

Config.LootSpots = {
    { coords = vec3(5003.12, -5203.44, 20.12), tier = 2, cooldown = 600 },
    -- add more
}

Config.SpawnPedOnHack2    = true
Config.SpawnPedOnHack3    = true
Config.SpawnPedOnLootDoor = true

Config.Guards = {
    baseModel = 's_m_m_marine_01',
    weapon    = 'weapon_microsmg',

    waves = {
        [1] = {
            trigger = 'hack2',
            peds = {
                vector3(5004.05, -5696.49, 19.88),
                vector3(5019.25, -5681.98, 19.88),
                vector3(4999.19, -5703.44, 20.08),
                vector3(4994.99, -5714.0, 19.88),
                vector3(4980.56, -5731.76, 19.88),
                vector3(4973.58, -5745.91, 19.88),
                vector3(4996.33, -5803.44, 20.88),
                vector3(5005.3,  -5795.98, 17.49),
                vector3(5021.74, -5806.51, 17.48),
                vector3(5031.18, -5800.11, 17.48),
                vector3(5040.13, -5795.01, 17.48),
                vector3(5043.32, -5783.35, 15.68),
                vector3(5033.58, -5763.38, 15.71),
            }
        },
        [2] = {
            trigger = 'hack3',
            peds = { -- same as above for now
                vector3(5004.05, -5696.49, 19.88),
                vector3(5019.25, -5681.98, 19.88),
                vector3(4999.19, -5703.44, 20.08),
                vector3(4994.99, -5714.0, 19.88),
                vector3(4980.56, -5731.76, 19.88),
                vector3(4973.58, -5745.91, 19.88),
                vector3(4996.33, -5803.44, 20.88),
                vector3(5005.3,  -5795.98, 17.49),
                vector3(5021.74, -5806.51, 17.48),
                vector3(5031.18, -5800.11, 17.48),
                vector3(5040.13, -5795.01, 17.48),
                vector3(5043.32, -5783.35, 15.68),
                vector3(5033.58, -5763.38, 15.71),
            }
        },
        [3] = {
            trigger = 'lootdoor',
            peds = { -- same again, tweak later
                vector3(5004.05, -5696.49, 19.88),
                vector3(5019.25, -5681.98, 19.88),
                vector3(4999.19, -5703.44, 20.08),
                vector3(4994.99, -5714.0, 19.88),
                vector3(4980.56, -5731.76, 19.88),
                vector3(4973.58, -5745.91, 19.88),
                vector3(4996.33, -5803.44, 20.88),
                vector3(5005.3,  -5795.98, 17.49),
                vector3(5021.74, -5806.51, 17.48),
                vector3(5031.18, -5800.11, 17.48),
                vector3(5040.13, -5795.01, 17.48),
                vector3(5043.32, -5783.35, 15.68),
                vector3(5033.58, -5763.38, 15.71),
            }
        },
    }
}

Config.Escape = {
    extractPoint = vec3(4890.0, -4920.0, 3.0),
    extraEscapeGuards = {
        coords = {
            vector3(4900.0, -4930.0, 3.0),
            vector3(4910.0, -4940.0, 3.0),
            vector3(4920.0, -4950.0, 3.0),
        }
    }
}
