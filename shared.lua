Weapons = {}

local function data(name)
	local file = ('data/%s.lua'):format(name)
	local datafile = LoadResourceFile('ox_inventory', file)
	local func, err = load(datafile, ('@@%s/%s'):format('ox_inventory', file))

	if not func or err then
		return print(err)
	end

	return func()
end

for k, v in pairs(data('weapons').Weapons) do
    Weapons[#Weapons+1] = k
end