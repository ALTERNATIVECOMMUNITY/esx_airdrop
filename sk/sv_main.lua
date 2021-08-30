ESX = nil
local _airdrop_started = false
local airdrop_created = false
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

CreateThread(function()
    while true do
       Wait(Config.kuinusein*1000*60)
        local xPlayers = ESX.GetPlayers()
        if not _airdrop_started then
            local random = math.random(1, #Config.Locations)
            local coords = Config.Locations[random].coords
            local suuruus = Config.Locations[random].kuiniso
            local zcoord = Config.Locations[random].kuinylos
            for k = 1, #Config.Gangs do
                for i = 1, #xPlayers do
                    local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
                    if xPlayer.job.name == Config.Gangs[k] then
                         _airdrop_started = true
                         TriggerClientEvent("karpo_airdrop:notification",xPlayers[i], 2)
                         TriggerClientEvent("karpo_airdrop:luo", xPlayers[i], coords, suuruus, zcoord, random)
                    end
                end
            end
            gamereita = 0
        end
        while _airdrop_started do
          Wait(0)
        end
    end
end)


TriggerEvent('es:addGroupCommand', 'airdrop', "superadmin", function(source, user)
    local xPlayers = ESX.GetPlayers()
    if not _airdrop_started then
        local random = math.random(1, #Config.Locations)
        local coords = Config.Locations[random].coords
        local suuruus = Config.Locations[random].kuiniso
        local zcoord = Config.Locations[random].kuinylos
        for k = 1, #Config.Gangs do
            for i = 1, #xPlayers do
                local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
                if xPlayer.job.name == Config.Gangs[k] then
                    _airdrop_started = true
                    TriggerClientEvent("karpo_airdrop:notification",xPlayers[i], 2)
                    TriggerClientEvent("karpo_airdrop:luo", xPlayers[i], coords, suuruus, zcoord, random)
                end
            end
        end
    end
    while _airdrop_started do
      Wait(0)
    end
end)

ESX.RegisterServerCallback('karpo_airdrop:info', function(source, cb)
    cb(airdrop_created)
    if not airdrop_created then 
      airdrop_created = true 
    end
end)

ESX.RegisterServerCallback('karpo_airdrop:items', function(source, cb)
    local weapon_random1 = math.random(1, #Config.Weapons)
    local weapon_random2 = math.random(1, #Config.Weapons)
    local selected_weapon = Config.Weapons[weapon_random1]
    local selected_weapon2 = Config.Weapons[weapon_random2]
    ---------------------------------------------------
    local item_random1 = math.random(1, #Config.Items)
    local item_random2 = math.random(1, #Config.Items)
    local selected_item = Config.Items[item_random1]
    local selected_item2 = Config.Items[item_random2]

    cb(selected_weapon, selected_weapon2, selected_item, selected_item2)
end)


RegisterNetEvent("karpo_airdrop:lunastettu")
AddEventHandler("karpo_airdrop:lunastettu", function()
    local xPlayers = ESX.GetPlayers()
    for k = 1, #Config.Gangs do
        for i = 1, #xPlayers do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer.job.name == Config.Gangs[k] then
                TriggerClientEvent("karpo_airdrop:notification", xPlayers[i], 1)
            end
        end
    end
end)

RegisterNetEvent("karpo_airdrop:perse")
AddEventHandler("karpo_airdrop:perse", function(lol)
    _airdrop_started = false
    airdrop_created = false
    local xPlayers = ESX.GetPlayers()
    for k = 1, #Config.Gangs do
        for i = 1, #xPlayers do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer.job.name == Config.Gangs[k] then
                TriggerClientEvent("karpo_airdrop:paska", xPlayers[i], lol)
            end
        end
    end
end)

RegisterNetEvent("karpo_airdrop:give")
AddEventHandler("karpo_airdrop:give", function(tavara, tapa)
    local xPlayer = ESX.GetPlayerFromId(source)
    if tapa == "ITEMI" then 
        xPlayer.addInventoryItem(tavara, 1)
    elseif tapa == "ASE" then
        xPlayer.addWeapon(tavara, 70) 
    end
end)

