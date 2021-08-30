ESX = nil
local coords, suuruus, random, zcoords, blip
local pilot, aircraft, parachute, crate, pickup, blip, soundID
local asej = 1
local asej2 = 1
local itemj = 5
local itemj2 = 5

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent("karpo_airdrop:luo")
AddEventHandler("karpo_airdrop:luo", function(coords22, suuruus22, zcoord22, random22)
    local timeri = 600
    coords = coords22
    suuruus = suuruus22
    zcoord = zcoord22
    random = random22
    Config.Locations[random].menossa = true
    local blip = AddBlipForRadius(coords, suuruus + 0.0)
    SetBlipAlpha(blip, 33)
    SetBlipColour(blip, 1)
    CreateThread(function()
        while timeri > 0 do
            Citizen.Wait(1000)
            if timeri > 0 then timeri = timeri - 1 end
        end
    end)
    CreateThread(function()
        while true do
            Wait(2)
            local omatcoords = GetEntityCoords(PlayerPedId())
            if Vdist(omatcoords.x, omatcoords.y, omatcoords.z, coords) < suuruus then
                sallittu = true
                if timeri > 0 and Config.Locations[random].menossa then
                    drawTxt(0.66, 1.40, 1.0, 1.0, 0.4, '~r~AIRDROP ~w~TULOSSA - ~r~' .. timeri, 255, 255, 255, 255)
                else
                    if Config.Locations[random].tullut then
                        drawTxt(0.66, 1.40, 1.0, 1.0, 0.4,'~r~HAE ~w~AIRDROP - ! ~r~', 255, 255, 255, 255)
                    end
                end
            else
                Wait(900)
            end
        end
    end)

    for i = 1, #Config.requiredModels do
        RequestModel(GetHashKey(Config.requiredModels[i]))
        while not HasModelLoaded(GetHashKey(Config.requiredModels[i])) do
            Wait(0)
        end
    end


    while timeri > 0 do 
        Wait(0) 
    end 

    local persereika = false
    if timeri == 0 and not persereika then
        Config.Locations[random].tullut = true
        persereika = true
        if sallittu then
            createbox()
        end
    end

       
        local parachuteCoords = vector3(GetEntityCoords(parachute))
        ShootSingleBulletBetweenCoords(parachuteCoords, parachuteCoords - vector3(0.0001, 0.0001, 0.0001), 0, false, GetHashKey("weapon_flare"), 0, true, false, -1.0) -- flare needs to be dropped with dropCoords like that, otherwise it remains static and won't remove itself later
        DetachEntity(parachute, true, true)
        DeleteEntity(parachute)
        DetachEntity(pickup) 
        Wait(6000)
        DeleteEntity(parachute)
        TriggerServerEvent("karpo_airdrop:landays")
        while Config.Locations[random].tullut do
            Wait(0)
            local omat = GetEntityCoords(PlayerPedId())
            if not Config.Locations[random].collectattu then
                if Vdist(omat.x, omat.y, omat.z, coords) < 3.0 and
                    Config.Locations[random].menossa then
                    _3dText(coords, tostring("~r~E ~w~- Avaa AIRDROP!"))
                    if IsControlJustReleased(0, 38) then
                        RemoveBlip(blip)
                        Config.Locations[random].collectattu = true
                        Config.Locations[random].menossa = false
                        TriggerServerEvent("karpo_airdrop:lunastettu")
                        TriggerServerEvent("karpo_airdrop:perse", random)
                        ESX.TriggerServerCallback('karpo_airdrop:items',function(ase, ase2, itemi, itemi2)
                            menu2(ase, ase2, itemi, itemi2)
                        end)
                        break
                    end
                end
            end
        end

        StopSound(soundID)
        ReleaseSoundId(soundID)
        for i = 1, #Config.requiredModels do
            Wait(0)
           SetModelAsNoLongerNeeded(GetHashKey(Config.requiredModels[i]))
        end
        RemoveWeaponAsset(GetHashKey("weapon_flare"))
        RemoveBlip(blip)
end)

createbox = function()
    ESX.TriggerServerCallback('karpo_airdrop:info', function(luotu)
        if not luotu then
            RequestWeaponAsset(GetHashKey("weapon_flare"))
            while not HasWeaponAssetLoaded(GetHashKey("weapon_flare")) do
                Wait(0)
            end
            local crateSpawn = vector3(coords.x, coords.y, zcoord)
            crate = CreateObject(GetHashKey("prop_box_wood02a_pu"), crateSpawn, true, true, true)
            SetEntityLodDist(crate, 1000) -- so we can see it from the distance
            ActivatePhysics(crate)
            SetDamping(crate, 2, 0.1)
            SetEntityVelocity(crate, 0.0, 0.0, -0.2)
            parachute = CreateObject(GetHashKey("p_cargo_chute_s"), crateSpawn, true, true, true)
            SetEntityLodDist(parachute, 1000)
            SetEntityVelocity(parachute, 0.0, 0.0, -0.2)
            pickup = CreateObject(GetHashKey("ex_prop_adv_case_sm"), crateSpawn, true, true)
            ActivatePhysics(pickup)
            SetDamping(pickup, 2, 0.0245)
            SetEntityVelocity(pickup, 0.0, 0.0, -0.2)
            soundID = GetSoundId()
            PlaySoundFromEntity(soundID, "Crate_Beeps", pickup, "MP_CRATE_DROP_SOUNDS", true, 0)
            AttachEntityToEntity(parachute, pickup, 0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            AttachEntityToEntity(pickup, crate, 0, 0.0, 0.0, 0.3, 0.0, 0.0, 0.0, false, false, true, false, 2, true)
        end
    end)
end


menu2 = function(ase, ase2, itemi, itemi2)
    local elements = {}
    Wait(500)
    if asej > 0 then
        table.insert(elements,{
            label = ase.label .. ' x' .. asej, 
            value = ase.weapon, 
            tapa = "ASE"
        })
    end
    if asej2 > 0 then
        table.insert(elements, {
            label = ase2.label .. ' x' .. asej2,
            value = ase2.weapon,
            tapa = "ASE"
        })
    end
    if itemj > 0 then
        table.insert(elements, {
            label = itemi .. ' x' .. itemj,
            value = itemi,
            tapa = "ITEMI"
        })
    end
    if itemj2 > 0 then
        table.insert(elements, {
            label = itemi2 .. ' x' .. itemj2,
            value = itemi2,
            tapa = "ITEMI"
        })
    end
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'AIRDROP', {
        title = 'AIRDROP',
        align = 'bottom',
        elements = elements
    }, function(data, menu)
        local a = data.current.value
        if a == ase.weapon then
            if asej > 0 then
                asej = asej - 1
                TriggerServerEvent("karpo_airdrop:give", data.current.value, data.current.tapa)
            end
        end
        if a == ase2.weapon then
            if asej2 > 0 then
                asej2 = asej2 - 1
                TriggerServerEvent("karpo_airdrop:give", data.current.value, data.current.tapa)
            end

        end
        if a == itemi then
            if itemj > 0 then
                itemj = itemj - 1
                TriggerServerEvent("karpo_airdrop:give", data.current.value, data.current.tapa)
            end
        end
        if a == itemi2 then
            if itemj2 > 0 then
                itemj2 = itemj2 - 1
                TriggerServerEvent("karpo_airdrop:give", data.current.value, data.current.tapa)
            end
        end
        menu2(ase, ase2, itemi, itemi2)
        if itemj2 == 0 and itemj == 0 and asej == 0 and asej2 == 0 then
            menu.close()
            Wait(2000)
            asej = 1
            asej2 = 1
            itemj = 5
            itemj2 = 5
            menu.close()
        end
    end, function(data, menu) menu.close() end)
end

drawTxt = function(x, y, width, height, scale, text, r, g, b, a, outline)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.6, 0.6)
    SetTextColour(128, 128, 128, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 150)
    SetTextDropshadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end

_3dText = function(cordinaatit, teksti)
    local onScreen, x, y = World3dToScreen2d(cordinaatit.x, cordinaatit.y,cordinaatit.z + 0.20)
    SetTextScale(0.41, 0.41)
    SetTextOutline()
    SetTextDropShadow()
    SetTextDropshadow(2, 0, 0, 0, 255)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextColour(255, 255, 255, 255)
    AddTextComponentString(teksti)
    DrawText(x, y)
    local factor = (string.len(teksti)) / 400
    DrawRect(x, y + 0.012, 0.015 + factor, 0.03, 0, 0, 0, 68)
end

RegisterNetEvent('karpo_airdrop:paska')
AddEventHandler('karpo_airdrop:paska', function(lel)
    Config.Locations[lel].collectattu = true
    Config.Locations[lel].menossa = false
    Config.Locations[lel].tullut = false
    RemoveBlip(blip)
    DeleteObject(pickup)
    DeleteEntity(parachute)
    DeleteObject(crate)

    Wait(1000)
    Config.Locations[random].collectattu = false
end)

RegisterNetEvent('karpo_airdrop:notification')
AddEventHandler('karpo_airdrop:notification', function(lolz)
    if lolz == 1 then
        ESX.ShowAdvancedNotification('AIRDROP', '~r~LUNASTETTU!', '', "CHAR_AMMUNATION", 1)
    elseif lolz == 2 then
        ESX.ShowAdvancedNotification('AIRDROP', '~r~LASKEUTUMASSA!', '', "CHAR_AMMUNATION", 1)
    elseif lolz == 3 then
        ESX.ShowAdvancedNotification('AIRDROP', '~b~LASKEUTUNUT!', '',"CHAR_AMMUNATION", 1)
    end
    PlaySound(-1, "Hang_Up", "Phone_SoundSet_Michael", 0, 0, 1)
end)

