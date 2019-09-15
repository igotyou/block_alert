local util = {}
local notifier = {}

minetest.debug("Initialising block_alert")

local modpath = minetest.get_modpath(minetest.get_current_modname())

util = dofile(modpath .. "/util.lua")
notifier = dofile(modpath .. "/notifier.lua")
dofile(modpath .. "/api.lua")