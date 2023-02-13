-- NOTES
-- Changes syncing to all clients, to the only client it's happening on
-- Can use the server events to listen for when it's needed for LEO calls and what not

-- LX Events
RegisterNetEvent("LX_Events:server:pedInjured")
AddEventHandler("LX_Events:server:pedInjured", function(attackersNet, attackersWeapon, meleeWeapon)
  TriggerClientEvent("LX_Events:client:pedInjured", source, attackersNet, attackersWeapon, meleeWeapon)
end)

RegisterNetEvent("LX_Events:server:gunshot")
AddEventHandler("LX_Events:server:gunshot", function(shootersNet)
  -- TriggerClientEvent("LX_Events:client:gunshot", -1, shootersNet)
  if shootersNet == source then -- If it's you shooting
    TriggerClientEvent("LX_Events:client:gunshot", source)
  end
end)

RegisterNetEvent("LX_Events:server:vehCollision")
AddEventHandler("LX_Events:server:vehCollision", function(driversNet, driversPosition)
  TriggerClientEvent("LX_Events:client:vehCollision", source, driversNet, driversPosition)
  -- TriggerClientEvent("LX_Events:client:vehCollision", -1, driversNet, driversPosition)
end)

RegisterNetEvent("LX_Events:server:enteredVeh")
AddEventHandler("LX_Events:server:enteredVeh", function(driversNet, vehNet, vehSeat, vehName)
  -- TriggerClientEvent("LX_Events:client:enteredVeh", -1, driversNet, vehNet, vehSeat, vehName)
  TriggerClientEvent("LX_Events:client:enteredVeh", source, vehNet, vehSeat, vehName)
end)

RegisterNetEvent("baseevents:enteringVehicle")
AddEventHandler("baseevents:enteringVehicle", function(vehHandle, vehSeat, vehName, vehNet)
  TriggerClientEvent("LX_Events:client:enteringVehicle", source, vehNet, vehSeat, vehName)
  -- TriggerClientEvent("LX_Events:client:enteringVehicle", -1, driversNet, vehNet, vehSeat, vehName)
end)

RegisterNetEvent("baseevents:enteringAborted")
AddEventHandler("baseevents:enteringAborted", function()
  TriggerClientEvent("LX_Events:client:enteringVehAborted", source)
  -- TriggerClientEvent("LX_Events:client:enteringVehAborted", -1, driversNet)
end)

RegisterNetEvent("baseevents:leftVehicle")
AddEventHandler("baseevents:leftVehicle", function(vehHandle, vehSeat, vehName, vehNet)
  TriggerClientEvent("LX_Events:client:leftVehicle", source, vehNet, vehSeat, vehName)
  -- TriggerClientEvent("LX_Events:client:leftVehicle", -1, driversNet, vehNet, vehSeat, vehName)
end)

RegisterNetEvent("baseevents:onPlayerDied")
AddEventHandler('baseevents:onPlayerDied', function(killedBy, deathPosition)
  TriggerClientEvent("LX_Events:client:playerDied", source, killedBy, deathPosition)
  -- TriggerClientEvent("LX_Events:client:playerDied", -1, playersNet, deathPosition)
end)

RegisterNetEvent("baseevents:onPlayerKilled")
AddEventHandler('baseevents:onPlayerKilled', function(killersNet, killData)
  TriggerClientEvent("LX_Events:client:playerKilled", source, killersNet, killData)
  -- TriggerClientEvent("LX_Events:client:playerKilled", -1, playersNet, killersNet, killData)
end)