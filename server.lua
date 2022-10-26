local ox_inventory = exports.ox_inventory
local repairs = {}

RegisterNetEvent('OT_weaponrepair:startweaponrepair', function(data)
    local src = source
    local slot = ox_inventory:GetSlot(src, data.slot)
    if slot and slot.name == data.name then
        local requiredItem = Config.require[data.name] and Config.require[data.name].requireditem or Config.requireditem
        local requiredAmount = Config.require[data.name] and Config.require[data.name].requireditemamount or Config.requireditemamount
        local count = ox_inventory:Search(src, 'count', requiredItem)
        if count >= requiredAmount then
            ox_inventory:RemoveItem(src, requiredItem, requiredAmount)
            repairs[src] = {}
            repairs[src].slot = data.slot
            repairs[src].name = data.name
            TriggerClientEvent('OT_weaponrepair:repairitem', src, data.name)
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
            ox_inventory:SetDurability(source, repairs[src].slot, 100)
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