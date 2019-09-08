local playerLastPos = {}

minetest.register_node("block_alert:notifier",
{
  description = "notifier block.",
  tiles = {"^[colorize:#802BB1"}, 
})


minetest.debug("Jukealert initialised")

minetest.register_globalstep(function(dtime)
    for _,player in ipairs(minetest.get_connected_players()) do
        local lastPos = playerLastPos[player:get_player_name()]
        if(lastPos and not samePos(lastPos, player:get_pos())) then
            local pos = player:get_pos()
            local bound1 = vector.subtract(pos, {x = 5, y=5 , z= 5})
            local bound2 = vector.add(pos, {x = 5, y=5 , z= 5})
            local snitch_list = minetest.find_nodes_in_area(bound1, bound2, { "block_alert:notifier" })
            minetest.chat_send_all(dump(snitch_list))
        end
        playerLastPos[player:get_player_name()] = player:get_pos()    
    end
end)

function samePos(pos1,pos2)
    return pos1.x == pos2.x and pos1.z == pos2.z and pos1.y == pos2.y
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