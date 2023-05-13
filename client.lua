local props = {}

local function openRepairBench(i)
    local options = {}
    local items = lib.callback.await('openRepairBench', false)
    if items then
        for name, data in pairs(items) do
            for _, v in pairs(data) do
                if v.slot then
                    options[#options+1] = {id = name .. v.slot, title = v.label, description = string.format('Durability: %s', v.metadata.durability .. '%'), serverEvent = 'OT_weaponrepair:startweaponrepair', args = {slot = v.slot, name = name, bench = i}}
                end
            end
        end
        lib.registerContext({id = 'repairbench', title = 'Repair Bench', options = options})
        lib.showContext('repairbench')
    end
end

RegisterNetEvent('OT_weaponrepair:repairitem', function(name)
    if lib.progressBar({
        duration = Config.require[name] and Config.require[name].repairtime or Config.repairtime,
        label = 'Repairing Weapon',
        useWhileDead = false,
        canCancel = false,
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped'
        },
        disable = {
            move = true,
            car = true
        }
    }) then
        TriggerServerEvent('OT_weaponrepair:fixweapon')
    end
end)


local target = GetResourceState('ox_target') == 'started' and true or false
for i = 1, #Config.locations do

    local location = Config.locations[i]

    if location.spawnprop then
        local benchfar = lib.points.new(location.coords, 50, {coords = location.coords, heading = location.heading, index = i})

        function benchfar:onEnter()
            lib.requestModel(`gr_prop_gr_bench_02a`)
            props[self.index] = CreateObject(`gr_prop_gr_bench_02a`, self.coords.x, self.coords.y, self.coords.z, false, false, false)
            SetEntityHeading(props[self.index], self.heading)
            FreezeEntityPosition(props[self.index], true)
            if target then
                exports.ox_target:addLocalEntity(props[i], {
                    {
                        name = 'weaponrepair:openRepairBench',
                        icon = 'fa-solid fa-wrench',
                        label = 'Open Repair Bench',
                        canInteract = function(entity, distance, coords, name, bone)
                            return distance <= 2.0
                        end,
                        onSelect = function(entity, distance, coords, name, bone)
                            openRepairBench(i)
                        end
                    }
                })
            end
        end

        function benchfar:onExit()
            if DoesEntityExist(props[self.index]) then
                if target then
                    exports.ox_target:removeLocalEntity(props[self.index], {'weaponrepair:openRepairBench'})
                end
                DeleteEntity(props[self.index])
            end
        end
    end

    if target then
        if not location.spawnprop then
            exports.ox_target:addBoxZone({
                coords = location.coords,
                size = vec3(2, 2, 2),
                rotation = location.heading,
                options = {
                    {
                        name = 'weaponrepair:openRepairBenchZone',
                        icon = 'fa-solid fa-wrench',
                        label = 'Open Repair Bench',
                        canInteract = function(entity, distance, coords, name, bone)
                            return distance <= 3.0
                        end,
                        onSelect = function(entity, distance, coords, name, bone)
                            openRepairBench(i)
                        end
                    }
                }
            })
        end
    else
        local bench = lib.points.new(location.coords, 2, {index = i})

        function bench:onEnter()
            lib.showTextUI('[E] - Open Repair Bench', {icon = 'wrench'})
        end
    
        function bench:onExit()
            lib.hideTextUI()
        end
    
        function bench:nearby()
            if IsControlJustReleased(0, 38) then
                openRepairBench(self.index)
            end
        end
    end
end

AddEventHandler('onResourceStop', function(name)
    if name ~= cache.resource then return end
    for _, v in pairs(props) do
        if DoesEntityExist(v) then
            if target then
                exports.ox_target:removeLocalEntity(v, {'weaponrepair:openRepairBench'})
            end
            DeleteEntity(v)
        end
    end
end)