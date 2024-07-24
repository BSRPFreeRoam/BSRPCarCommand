local QBCore = exports['qb-core']:GetCoreObject()

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
                lib.notify({
                    title = "BSRP FreeRoam - CarCommand",
                    description = "Could not load the vehicle model in time, a crash was prevented.",
                    type = "error",
                    timeout = math.random(1000, 10000)
                })
                return
            end
        end
        local vehicle = CreateVehicle(vehiclehash, x, y, z, GetEntityHeading(PlayerPedId()) + 90, true, false)
        SetVehicleNumberPlateText(vehicle, "QB-CAR") -- Optional: set a plate for the vehicle
    end)
end, "admin")
