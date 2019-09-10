local playerLastPos = {}
local playerRenamePos = {}

minetest.register_node("block_alert:notifier",
{
    description = "notifier block.",
    tiles = {"^[colorize:#802BB1"}, 

    after_place_node  = function(pos, placer)
        local meta = minetest.get_meta(pos)
        local pname = placer and placer:get_player_name() or ""
        meta:mark_as_private("owner")
        meta:set_string("owner", pname)
        meta:set_string("name", "Notifier")
    end,

    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        --todo add permission check
        local pname = clicker and clicker:get_player_name() or ""
        local meta = minetest.get_meta(pos)
        minetest.chat_send_all(meta:get_string("owner"))
        if(meta:get_string("owner") == pname) then 
            playerRenamePos[pname] = pos
            minetest.show_formspec(pname, "block_alert:rename", get_rename_formspec(meta:get_string("name")))            
        end
    end,
})


minetest.debug("Jukealert initialised")

--This can be made muchhhhhh more efficient
minetest.register_globalstep(function(dtime)
    for _,player in ipairs(minetest.get_connected_players()) do
        local lastPos = playerLastPos[player:get_player_name()]
        if(lastPos and not samePos(lastPos, player:get_pos())) then
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
        if(meta:get_string("owner") == pname) then
            meta:set_string("name", fields.name) 
        end
    end
end)

function playerEnterEvent(player, pos)
    local notifierName = minetest.get_meta(pos):get_string("name")
    minetest.chat_send_all(player:get_player_name() .. " entered " .. notifierName .. " at " .. "x:" .. pos.x .. " y:" ..pos.y .. " z:" .. pos.z)
end

--This might be slightly more efficient if run as a "different pos instead"
 function samePos(pos1,pos2)
    return pos1.x == pos2.x and pos1.z == pos2.z and pos1.y == pos2.y
end

function get_rename_formspec(name)
    local formspec = {
        "size[3,2]",
        "real_coordinates[true]",
        "field[0.5,0.5;2.5,1;name;Name;" .. minetest.formspec_escape(name) .. "]",
        "button_exit[1,1.5;1,1;rename;Rename]"
    }
    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end