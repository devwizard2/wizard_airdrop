ESX = exports["es_extended"]:getSharedObject()
local dropEntity = nil
local dropBlip = nil
local radiusBlip = nil
local claimed = false
local dropCoords = nil

local model = `prop_drop_armscrate_01`

RegisterNetEvent("airdrop:spawn", function(coords)
    dropCoords = coords
    claimed = false

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    dropEntity = CreateObject(model, coords.x, coords.y, coords.z - 1.0, false, true, true)
    PlaceObjectOnGroundProperly(dropEntity)
    FreezeEntityPosition(dropEntity, true)

    -- Blip
    dropBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(dropBlip, 94)
    SetBlipScale(dropBlip, 1.0)
    SetBlipColour(dropBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Airdrop")
    EndTextCommandSetBlipName(dropBlip)

    -- Radius Blip
    radiusBlip = AddBlipForRadius(coords.x, coords.y, coords.z, 100.0)
    SetBlipColour(radiusBlip, 1)
    SetBlipAlpha(radiusBlip, 128)

    -- Smoke FX
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do Wait(0) end
    UseParticleFxAssetNextCall("core")
    StartParticleFxNonLoopedAtCoord("exp_grd_flare", coords.x, coords.y, coords.z + 0.5, 0.0, 0.0, 0.0, 1.0, false, false, false)

    -- Interaction loop
    CreateThread(function()
        while not claimed do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            if #(playerCoords - coords) < 2.0 then
                ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to claim the airdrop")
                if IsControlJustReleased(0, 38) then
                    claimed = true
                    TriggerServerEvent("airdrop:claim")
                end
            end
            Wait(0)
        end
    end)
end)

RegisterNetEvent("airdrop:remove", function()
    if DoesEntityExist(dropEntity) then
        DeleteEntity(dropEntity)
    end
    if dropBlip then RemoveBlip(dropBlip) end
    if radiusBlip then RemoveBlip(radiusBlip) end
end)
