local playerLastPos = {}
local playerRenamePos = {}

minetest.register_node("block_alert:notifier",
{
    description = "Notifier block.",
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
        if(util.check_permission(pos,pname)) then 
            playerRenamePos[pname] = pos
            minetest.show_formspec(pname, "block_alert:rename", notifier.get_rename_formspec(meta:get_string("name")))            
        end
    end,
})

--This can be made muchhhhhh more efficient
minetest.register_globalstep(function(dtime)
    for _,player in ipairs(minetest.get_connected_players()) do
        local lastPos = playerLastPos[player:get_player_name()]
        if(lastPos and util.different_pos(lastPos, player:get_pos())) then
            local bound1 = vector.subtract(player:get_pos(), {x = 5, y=5 , z= 5})
            local bound2 = vector.add(player:get_pos(), {x = 5, y=5 , z= 5})
            local notifierList = minetest.find_nodes_in_area(bound1, bound2, { "block_alert:notifier" })
            for _,nodeNotifier in ipairs(notifierList) do
                notifier.handle_player_entry(player,nodeNotifier)
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
        if(util.check_permission(playerRenamePos[pname],pname)) then
            meta:set_string("name", fields.name) 
        end
    end
end)