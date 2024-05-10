local ox_inventory = exports.ox_inventory
local repairs = {}

if Config.useOTSkills then
    exports.OT_skills:registerSkill({
        name = 'gunsmithing',
        multiplier = 2.5,
        maxlevel = 30,
        maxReward = 20,
        maxDeduction = 20,
        label = 'Gunsmithing',
        description = 'A master gunsmith can assemble, repair and modify even the rarest of firearms.'
    })
end

local function fixWeapon(payload)
    if type(payload) ~= 'table' or table.type(payload) == 'empty' then return end
    TriggerClientEvent('ox_inventory:closeInventory', payload.source)
    if not ox_inventory:RemoveItem(payload.source, payload.fromSlot.name, 1) then return end
    repairs[payload.source] = {}
    repairs[payload.source].slot = payload.toSlot.slot
    repairs[payload.source].name = payload.toSlot.name
    TriggerClientEvent('OT_weaponrepair:repairitem', payload.source, payload.toSlot.name)
end

RegisterNetEvent('OT_weaponrepair:startweaponrepair', function(data)
    local source = source
    local slot = ox_inventory:GetSlot(source, data.slot)
    if slot and slot.name == data.name then
        local pCoords = GetEntityCoords(GetPlayerPed(source))
        if not Config.locations[data.bench].free then
            local requiredItem = Config.require[data.name] and Config.require[data.name].requireditem or Config.requireditem
            local requiredAmount = Config.require[data.name] and Config.require[data.name].requireditemamount or Config.requireditemamount
            local count = ox_inventory:Search(source, 'count', requiredItem)
            if #(pCoords - Config.locations[data.bench].coords) > 10.0 then print('Player ID:', source, 'Attempting to fixweapon away from bench, probably cheating') return end
            if not count then return TriggerClientEvent('ox_lib:notify', source, {type = 'error', title = 'Workbench', description = 'Missing Required items'}) end
            if count >= requiredAmount then
                if not ox_inventory:RemoveItem(source, requiredItem, requiredAmount) then return end
                repairs[source] = {}
                repairs[source].slot = data.slot
                repairs[source].name = data.name
                TriggerClientEvent('OT_weaponrepair:repairitem', source, data.name)
            else
                TriggerClientEvent('ox_lib:notify', source, {type = 'error', title = 'Workbench', description = string.format('You dont have enough %s', requiredItem)})
            end
        else
            if #(pCoords - Config.locations[data.bench].coords) > 10.0 then print('Player ID:', source, 'Attempting to fixweapon for free away from bench, probably cheating') return end
            repairs[source] = {}
            repairs[source].slot = data.slot
            repairs[source].name = data.name
            TriggerClientEvent('OT_weaponrepair:repairitem', source, data.name)
        end
    elseif slot and slot.name ~= data.name then
        print('Player ID:', source, 'Attempting to fixweapon with incorrect data, probably cheating')
    end
end)

RegisterNetEvent('OT_weaponrepair:fixweapon', function()
    local source = source
    if repairs[source] then
        local slot = ox_inventory:GetSlot(source, repairs[source].slot)
        if slot and slot.name == repairs[source].name then
            ox_inventory:SetDurability(source, repairs[source].slot, 100)
            if Config.useOTSkills then
                exports.OT_skills:addXP(source, 'gunsmithing', Config.xpreward)
            end
            repairs[source] = nil
        elseif slot and slot.name ~= repairs[source].name then
            print('Player ID:', source, 'Attempting to fixweapon with data mismatch, probably cheating')
        end
    else
        print('Player ID:', source, 'Attempting to fixweapon with incorrect data, probably cheating')
    end
end)

lib.callback.register('openRepairBench', function(source)
    return ox_inventory:Search(source, 'slots', Weapons)
end)

local hookId = exports.ox_inventory:registerHook('swapItems', function(payload)
    if type(payload.toSlot) == 'table' and payload.fromSlot.name == Config.repairItem then
        if WeaponHashes[payload.toSlot.name] then
            if payload.toSlot.metadata.durability >= 100.0 then TriggerClientEvent('ox_lib:notify', payload.source, {position = 'top', type = 'error', description = 'Weapon does not need repairing'}) return false end
            CreateThread(function() fixWeapon(payload) end)
            return false
        end
    end
    return true
end, {print = true, itemFilter = Filter})