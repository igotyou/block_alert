local playerLastPos = {}
local playerRenamePos = {}
local lastNotification = {} --THis is used to avoid spamming

local function get_seconds_since_last_notification(string)
    if(lastNotification[string]) then 
        return ((minetest.get_us_time() - lastNotification[string])/1000000.0) 
    else 
        return 60 --This is a arbitriaty large number
    end
end

--This might be slightly more efficient if run as a "different pos instead"
local function differentPos(pos1,pos2)
    if pos1.x ~= pos2.x then return true
    elseif pos1.z ~= pos2.z then return true
    elseif pos1.y ~= pos2.y then return true
    else return false
    end
end

local function get_rename_formspec(name)
    local formspec = {
        "size[3,2]",
        "real_coordinates[true]",
        "field[0.5,0.5;2.5,1;name;Name;" .. minetest.formspec_escape(name) .. "]",
        "button_exit[1,1.5;1,1;rename;Rename]"
    }
    return table.concat(formspec, "")
end

local function playerEnterEvent(player, pos)
    local reinf = ct.get_reinforcement(pos)
    if reinf then
        local meta = minetest.get_meta(pos)
        local messageString = player:get_player_name() .. " entered " .. meta:get_string("name") .. " at " .. "x:" .. pos.x .. " y:" ..pos.y .. " z:" .. pos.z
        local secondsSinceLast = get_seconds_since_last_notification(messageString)
        if(secondsSinceLast > 10) then 
            pm.send_chat_group(reinf.ctgroup_id, messageString)
            lastNotification[messageString] = minetest.get_us_time()
        end
    end
end

local function checkPermission(pos, pname)
    local reinf = ct.get_reinforcement(pos)
    if reinf then
        local player_id = pm.get_player_by_name(pname).id
        if pm.get_player_group(player_id, reinf.ctgroup_id) then return true else return false end
    else return true
    end
    return false
end

minetest.register_node("block_alert:notifier",
{
    description = "notifier block.",
    tiles = {"^[colorize:#802BB1"},

    after_place_node  = function(pos, placer)
        local meta = minetest.get_meta(pos)
        meta:mark_as_private("name")
        meta:set_string("name", "Notifier")
    end,

    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        --todo add permission check
        local pname = clicker and clicker:get_player_name() or ""
        local meta = minetest.get_meta(pos)
        if(checkPermission(pos,pname)) then 
            playerRenamePos[pname] = pos
            minetest.show_formspec(pname, "block_alert:rename", get_rename_formspec(meta:get_string("name")))            
        end
    end,
})


minetest.debug("Block_alert initialised")

--This can be made muchhhhhh more efficient
minetest.register_globalstep(function(dtime)
    for _,player in ipairs(minetest.get_connected_players()) do
        local lastPos = playerLastPos[player:get_player_name()]
        if(lastPos and differentPos(lastPos, player:get_pos())) then
            local bound1 = vector.subtract(player:get_pos(), {x = 5, y=5 , z= 5})
            local bound2 = vector.add(player:get_pos(), {x = 5, y=5 , z= 5})
            local notifierList = minetest.find_nodes_in_area(bound1, bound2, { "block_alert:notifier" })
            for _,notifier in ipairs(notifierList) do
                playerEnterEvent(player,notifier)
            end
        end
        playerLastPos[player:get_player_name()] = player:get_pos()    
    end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "block_alert:rename" then
        return
    end

    if fields.name then
        local pname = player and player:get_player_name() or ""
        local meta = minetest.get_meta(playerRenamePos[pname])
        if(checkPermission(playerRenamePos[pname],pname)) then
            meta:set_string("name", fields.name) 
        end
    end
end)