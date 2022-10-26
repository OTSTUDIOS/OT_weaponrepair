Config = {}

Config.useOTSkills = false -- requires our skills system, you can find here: https://forum.cfx.re/t/paid-ot-skills/4917372
Config.xpreward = 5

Config.requireditem = 'money'
Config.requireditemamount = 1000
Config.repairtime = 5000

Config.require = {
    ['WEAPON_COMBATPDW'] = {
        requireditem = 'money',
        requireditemamount = 2000,
        repairtime = 10000
    },
}

Config.locations = {
    {
        coords = vector3(-567.8292, -1696.3129, 19.0366),
        heading = 210.3678,
        spawnprop = true
    }
}