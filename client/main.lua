-- Variables
local config = json.decode(LoadResourceFile(GetCurrentResourceName(), "configs/client.json"))
local shootingWeapon = false
local inCrash = false
local enteredVeh = false

-- Game Events
AddEventHandler("gameEventTriggered", function (eventName, eventArgs)
  -- print("Game Event Triggered", eventName)
  if eventName == "CEventNetworkEntityDamage" then
    local damagedEntity = eventArgs[1]
    local attackingEntity = eventArgs[2]
    local weaponHash = eventArgs[7]
    local isMelee = eventArgs[12]

    if IsEntityAPed(damagedEntity) and IsEntityAPed(attackingEntity) then
      local isFatal = eventArgs[4]

      if config.debug then print("Ped Damaged | Victim: " .. damagedEntity .. " | Attacker: " .. attackingEntity .. " | Fatal: " .. tostring(isFatal) .. " | Weapon: " .. weaponHash .. " | Melee: " .. tostring(isMelee)) end

      -- print("Ped Damaged | Victim: " .. damagedEntity .. " | Attacker: " .. attackingEntity .. " | Fatal: " .. tostring(isFatal) .. " | Weapon: " .. weaponHash .. " | Melee: " .. tostring(isMelee))
      if isFatal == 0 then
        TriggerServerEvent("LX_Events:server:pedInjured", PedToNet(attackingEntity), weaponHash, isMelee)
      end
    elseif IsEntityAVehicle(damagedEntity) then
      local vehNet = VehToNet(damagedEntity)

      if config.debug then print("Vehicle Damaged | Entity: " .. damagedEntity .. " (Net Id - " .. vehNet .. ") | Attacking Entity: " .. attackingEntity .. " | Weapon: " .. weaponHash .. " | Melee: " .. tostring(isMelee)) end
      TriggerEvent("LX_Events:client:VehDamaged", damagedEntity, vehNet, attackingEntity, weaponHash, isMelee)
    elseif IsEntityAnObject(damagedEntity) then
      local objNet = ObjToNet(damagedEntity)

      if config.debug then print("Object Damaged | Entity: " .. damagedEntity .. " (Net Id - " .. objNet .. ") | Attacking Entity: " .. attackingEntity .. " | Weapon: " .. weaponHash .. " | Melee: " .. tostring(isMelee)) end
      TriggerEvent("LX_Events:client:ObjDamaged", damagedEntity, objNet, attackingEntity, weaponHash, isMelee)
    end
  elseif eventName == "CEventNetworkPlayerEnteredVehicle" then
    local vehHandle = eventArgs[2]

    if IsEntityAVehicle(vehHandle) then
      local enteringPlayer = eventArgs[1]

      if enteringPlayer == PlayerId() then
        if not enteredVeh then
          enteredVeh = true
        
          local myPed = GetPlayerPed(enteringPlayer)
          local foundVeh = GetVehiclePedIsIn(myPed, false)
          local driversNet = PedToNet(myPed)

          local vehNet = VehToNet(vehHandle)
          local vehSeat = getPedsVehSeat(myPed)
          local vehName = GetDisplayNameFromVehicleModel(GetEntityModel(vehHandle))

          TriggerServerEvent("LX_Events:server:enteredVeh", driversNet, vehNet, vehSeat, vehName)
        end
      end
    end
  end
end)

function getPedsVehSeat(ped)
  if (IsPedInAnyVehicle(ped, false)) then
    local currVeh = GetVehiclePedIsIn(ped, false)
    local maxPassengers = GetVehicleNumberOfPassengers(currVeh)
    for i = -2, maxPassengers, 1 do
      if (GetPedInVehicleSeat(currVeh, i) == ped) then
        return i
      end
    end
  end
end

AddEventHandler("CEventShockingCarCrash", function(somePed, driverPed, position)
  if not inCrash then
    if driverPed == PlayerPedId() then -- If it was you in the car crash
      inCrash = true
      TriggerServerEvent("LX_Events:server:vehCollision", GetPlayerServerId(NetworkGetPlayerIndexFromPed(driverPed)), position)
      Wait(500)
      inCrash = false
    end
  end
end)

AddEventHandler("CEventGunShot", function(entities, shooter, args)
  local shootersPed = shooter

  if IsPedAPlayer(shootersPed) then
    if not shootingWeapon then
      local shootersNet = GetPlayerServerId(NetworkGetPlayerIndexFromPed(shootersPed))
      if shootersNet == GetPlayerServerId(PlayerId()) then -- If it's you shooting
        if config.debug then print("eventGunShot", shootersPed, shootersNet) end
        shootingWeapon = true
        TriggerServerEvent("LX_Events:server:gunshot", shootersNet)
        Wait(50)
        shootingWeapon = false
      end
    end
  end
end)

-- LX Events
RegisterNetEvent("LX_Events:client:pedInjured")
AddEventHandler("LX_Events:client:pedInjured", function(attackersNet, attackersWeapon, meleeWeapon)
  if config.debug then
    local attackersPed = NetToPed(attackersNet)
    print("Ped Injured | Attackers Data: (Handle: " .. attackersPed .. " | Net Id: " .. attackersNet .. "| Weapon: " .. attackersWeapon .. " | Is Melee: " .. tostring(meleeWeapon) .. ")")
  end
end)

RegisterNetEvent("LX_Events:client:gunshot")
AddEventHandler("LX_Events:client:gunshot", function()
  -- AddEventHandler("LX_Events:client:gunshot", function(shootersNet)
  -- local pedHandle = GetPlayerPed(GetPlayerFromServerId(shootersNet))
  if config.debug then
    local myPed = PlayerPedId()
    print("You've Shot Your Weapon | Handle: " .. myPed .. " | Position: " .. json.encode(GetEntityCoords(myPed, false)))
  end
end)

RegisterNetEvent("LX_Events:client:vehCollision")
AddEventHandler("LX_Events:client:vehCollision", function()
  -- AddEventHandler("LX_Events:client:vehCollision", function(driversNet)
  -- local pedHandle = GetPlayerPed(GetPlayerFromServerId(driversNet))
  if config.debug then
    local myPed = PlayerPedId()
    print("Vehicle Collision | Handle: " .. myPed .. " | Position: " .. json.encode(GetEntityCoords(myPed, false)))
  end
end)

RegisterNetEvent("LX_Events:client:enteredVeh")
AddEventHandler("LX_Events:client:enteredVeh", function(vehNet, vehSeat, vehName)
  -- AddEventHandler("LX_Events:client:enteredVeh", function(driversNet, vehNet, vehSeat, vehName)
  if config.debug then
    local vehHandle = NetToVeh(vehNet)
    print("Entered Vehicle | Data (Handle: " .. vehHandle .. " | Seat: " .. vehSeat .. " | Name: " .. vehName .. " | Label: " .. GetLabelText(vehName) .. " | Net Id: " .. vehNet .. ")")
  end
end)

RegisterNetEvent("LX_Events:client:enteringVehicle")
AddEventHandler("LX_Events:client:enteringVehicle", function(vehNet, vehSeat, vehName)
  -- AddEventHandler("LX_Events:client:enteringVehicle", function(driversNet, vehNet, vehSeat, vehName)
  if config.debug then
    local vehHandle = NetToVeh(vehNet)
    print("Entering Vehicle | Data (Handle: " .. vehHandle .. " | Seat: " .. vehSeat .. " | Name: " .. vehName .. " | Label: " .. GetLabelText(vehName) .. " | Net Id: " .. vehNet .. ")")
  end
end)

RegisterNetEvent("LX_Events:client:enteringVehAborted")
AddEventHandler("LX_Events:client:enteringVehAborted", function()
  -- AddEventHandler("LX_Events:client:enteringVehAborted", function(driversNet)
  if config.debug then print("Entering Veh Aborted") end
end)

RegisterNetEvent("LX_Events:client:leftVehicle")
AddEventHandler("LX_Events:client:leftVehicle", function(vehNet, vehSeat, vehName)
  -- AddEventHandler("LX_Events:client:leftVehicle", function(driversNet, vehNet, vehSeat, vehName)
  if enteredVeh then enteredVeh = false end
  if config.debug then
    local vehHandle = NetToVeh(vehNet)
    print("Left Vehicle | Data (Handle: " .. vehHandle .. " | Seat: " .. vehSeat .. " | Name: " .. vehName .. " | Label: " .. GetLabelText(vehName) .. " | Net Id: " .. vehNet .. ")")
  end
end)

RegisterNetEvent("LX_Events:client:playerDied")
AddEventHandler("LX_Events:client:playerDied", function(killedBy, deathPosition)
  if config.debug then print("Player Died | Data (Killed By: " .. killedBy .. " | Position: " .. json.encode(deathPosition) .. ")") end
end)

RegisterNetEvent("LX_Events:client:playerKilled")
AddEventHandler("LX_Events:client:playerKilled", function(killersNet, killData)
  if config.debug then
    local killersPed = GetPlayerPed(GetPlayerFromServerId(killersNet))
    print("Player Killed | Killer (Handle: " .. killersPed .. " | Net Id: " .. killersNet .. ") | Kill Data: " .. json.encode(killData))
  end
end)