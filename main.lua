local QBCore = exports['qb-core']:GetCoreObject()

-- Load configuration from external file
dofile('config.lua')

-- Function to send notifications based on config
function SendNotification(title, description, type, timeout)
    if Config.UseQBNotify then
        -- Use qb-notify (No title for qb-notify)
        TriggerEvent('qb-notify:client:SendNotification', {
            text = description,   -- Only send the text, no title
            type = type,
            duration = timeout
        })
    elseif Config.UseLibNotify then
        -- Use lib.notify
        lib.notify({
            title = title,
            description = description,
            type = type,
            timeout = timeout
        })
    elseif Config.UseMythicNotify then
        -- Use mythic_notify
        TriggerEvent('mythic_notify:client:SendAlert', {
            type = type,
            text = description,
            length = timeout
        })
    elseif Config.UsePNotify then
        -- Use pnotify (without title)
        TriggerEvent('pnotify:sendNotification', {
            text = description,
            type = type,
            timeout = timeout
        })
    elseif Config.UseDillenNotify then
        -- Use dillen-notifications
        exports['dillen-notifications']:sendNotification({
            title = title, -- dillen-notifications requires a title, so passing it even if it’s not needed
            message = description,
            type = type,
            duration = timeout
        })
    else
        print("No notification system selected in config.")
    end
end

-- Command to spawn vehicle
QBCore.Commands.Add("car", "Spawn a vehicle", {{name = "vehicle", help = "The name of the vehicle to spawn"}}, true, function(source, args, rawCommand)
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0, 0.5))
    local veh = args[1]
    if veh == nil then veh = "adder" end
    local vehiclehash = GetHashKey(veh)
    RequestModel(vehiclehash)

    Citizen.CreateThread(function() 
        local waiting = 0
        while not HasModelLoaded(vehiclehash) do
            waiting = waiting + 100
            Citizen.Wait(100)
            if waiting > 5000 then
                SendNotification("BSRP FreeRoam - CarCommand", "Could not load the vehicle model in time, a crash was prevented.", "error", math.random(1000, 10000))
                return
            end
        end
        local vehicle = CreateVehicle(vehiclehash, x, y, z, GetEntityHeading(PlayerPedId()) + 90, true, false)
        SetVehicleNumberPlateText(vehicle, "QB-CAR") -- Optional: set a plate for the vehicle
    end)
end, "admin")
