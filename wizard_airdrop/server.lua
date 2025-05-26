ESX = exports["es_extended"]:getSharedObject()
local airdropActive = false

function spawnAirdrop()
    if airdropActive then return end
    airdropActive = true

    local location = Config.Locations[math.random(1, #Config.Locations)]
    TriggerClientEvent("airdrop:spawn", -1, location)

    TriggerClientEvent('esx:showNotification', -1, '🚁 A new airdrop has landed! Check your map!')

    if Config.WebhookURL ~= "" then
        PerformHttpRequest(Config.WebhookURL, function() end, 'POST', json.encode({
            username = "Airdrop",
            embeds = {{
                title = "New Airdrop Spawned",
                description = ("Coords: %s"):format(location),
                color = 16711680
            }}
        }), { ['Content-Type'] = 'application/json' })
    end
end

RegisterCommand("startairdrop", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if source == 0 or (xPlayer and xPlayer.getGroup() == 'admin') then
        spawnAirdrop()
        if source ~= 0 then
            TriggerClientEvent('esx:showNotification', source, '✅ Airdrop triggered manually.')
        end
    else
        TriggerClientEvent('esx:showNotification', source, '🚫 You are not allowed to use this command.')
    end
end)

-- Force clear command
RegisterCommand("forceclear", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if source == 0 or (xPlayer and xPlayer.getGroup() == 'admin') then
        if airdropActive then
            TriggerClientEvent("airdrop:remove", -1)
            airdropActive = false
            TriggerClientEvent('esx:showNotification', -1, '🛑 Airdrop has been forcefully cleared.')
        else
            if source ~= 0 then
                TriggerClientEvent('esx:showNotification', source, 'ℹ️ No active airdrop to clear.')
            end
        end
    else
        TriggerClientEvent('esx:showNotification', source, '🚫 You are not allowed to use this command.')
    end
end)

RegisterServerEvent("airdrop:claim")
AddEventHandler("airdrop:claim", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    for _, item in ipairs(Config.Loot) do
        xPlayer.addInventoryItem(item.name, item.count)
    end

    local playerName = xPlayer.getName()
    TriggerClientEvent("airdrop:remove", -1)
    TriggerClientEvent('esx:showNotification', -1, playerName .. ' has claimed the airdrop!')

    if Config.WebhookURL ~= "" then
        PerformHttpRequest(Config.WebhookURL, function() end, 'POST', json.encode({
            username = "Airdrop",
            embeds = {{
                title = "Airdrop Claimed",
                description = playerName .. " has claimed the airdrop!",
                color = 65280
            }}
        }), { ['Content-Type'] = 'application/json' })
    end

    airdropActive = false
end)

CreateThread(function()
    while true do
        Wait(3600000) -- 1h minute
        local coords = Config.Locations[math.random(1, #Config.Locations)]
        TriggerClientEvent("airdrop:spawn", -1, coords)
        TriggerClientEvent('esx:showAdvancedNotification', -1, 'Airdrop', 'Supply Drop Incoming!', 'A supply drop has landed somewhere in the area. Check your map!', 'CHAR_AMMUNATION', 1)
        if Config.WebhookURL and Config.WebhookURL ~= "" then
            PerformHttpRequest(Config.WebhookURL, function(err, text, headers) end, "POST", json.encode({
                username = "Airdrop Bot",
                embeds = {{
                    title = "Airdrop Incoming!",
                    description = ("New airdrop has landed at: `%.2f, %.2f, %.2f`"):format(coords.x, coords.y, coords.z),
                    color = 16753920
                }}
            }), { ["Content-Type"] = "application/json" })
        end
    end
end)

