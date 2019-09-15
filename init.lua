util = {}
notifier = {}

minetest.debug("Initialising block_alert")

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath .. "/util.lua")
dofile(modpath .. "/notifier.lua")
dofile(modpath .. "/api.lua")