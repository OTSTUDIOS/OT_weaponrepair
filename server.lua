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
    ox_inventory:RemoveItem(payload.source, payload.fromSlot.name, 1)
    repairs[payload.source] = {}
    repairs[payload.source].slot = payload.toSlot.slot
    repairs[payload.source].name = payload.toSlot.name
    TriggerClientEvent('OT_weaponrepair:repairitem', payload.source, payload.toSlot.name)
end

RegisterNetEvent('OT_weaponrepair:startweaponrepair', function(data)
    local src = source
    local slot = ox_inventory:GetSlot(src, data.slot)
    if slot and slot.name == data.name then
        local requiredItem = Config.require[data.name] and Config.require[data.name].requireditem or Config.requireditem
        local requiredAmount = Config.require[data.name] and Config.require[data.name].requireditemamount or Config.requireditemamount
        local count = ox_inventory:Search(src, 'count', requiredItem)
        if not count then return TriggerClientEvent('ox_lib:notify', src, {type = 'error', title = 'Workbench', description = 'Missing Required items'}) end
        if count >= requiredAmount then
            ox_inventory:RemoveItem(src, requiredItem, requiredAmount)
            repairs[src] = {}
            repairs[src].slot = data.slot
            repairs[src].name = data.name
            TriggerClientEvent('OT_weaponrepair:repairitem', src, data.name)
        else
            TriggerClientEvent('ox_lib:notify', src, {type = 'error', title = 'Workbench', description = string.format('You dont have enough %s', requiredItem)})
        end
    elseif slot and slot.name ~= data.name then
        print('Player ID:', src, 'Attempting to fixweapon with incorrect data, probably cheating')
    end
end)

RegisterNetEvent('OT_weaponrepair:fixweapon', function()
    local src = source
    if repairs[src] then
        local slot = ox_inventory:GetSlot(src, repairs[src].slot)
        if slot and slot.name == repairs[src].name then
            ox_inventory:SetDurability(src, repairs[src].slot, 100)
            if Config.useOTSkills then
                exports.OT_skills:addXP(src, 'gunsmithing', Config.xpreward)
            end
            repairs[src] = nil
        elseif slot and slot.name ~= repairs[src].name then
            print('Player ID:', src, 'Attempting to fixweapon with data mismatch, probably cheating')
        end
    else
        print('Player ID:', src, 'Attempting to fixweapon with incorrect data, probably cheating')
    end
end)

lib.callback.register('openRepairBench', function(source)
    return ox_inventory:Search(source, 'slots', Weapons)
end)

local hookId = exports.ox_inventory:registerHook('swapItems', function(payload)
    if payload.fromSlot.name == Config.repairItem then
        if WeaponHashes[payload.toSlot.name] then
            if payload.toSlot.metadata.durability >= 100.0 then TriggerClientEvent('ox_lib:notify', payload.source, {position = 'top', type = 'error', description = 'Weapon does not need repairing'}) return false end
            CreateThread(function() fixWeapon(payload) end)
            return false
        end
    end
    return true
end, {print = true, itemFilter = Filter})