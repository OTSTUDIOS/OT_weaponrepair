Weapons = {}
WeaponHashes = {}
Filter = {}

function DumpTable(table, nb)
	if nb == nil then
		nb = 0
	end

	if type(table) == 'table' then
		local s = ''
		for i = 1, nb + 1, 1 do
			s = s .. "    "
		end

		s = '{\n'
		for k,v in pairs(table) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			for i = 1, nb, 1 do
				s = s .. "    "
			end
			s = s .. '['..k..'] = ' .. DumpTable(v, nb + 1) .. ',\n'
		end

		for i = 1, nb, 1 do
			s = s .. "    "
		end

		return s .. '}'
	else
		return tostring(table)
	end
end

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
	WeaponHashes[k] = true
	Filter[k] = true
end
Filter[Config.repairItem] = true