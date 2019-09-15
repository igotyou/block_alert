local util = {}
local notifier = {}
local recorder = {}

minetest.debug("Initialising block_alert")

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath .. "/util.lua")
dofile(modpath .. "/notifier.lua")
dofile(modpath .. "/recorder.lua")
dofile(modpath .. "/api.lua")