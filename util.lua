--for lack of a better name...
local player_alert_status = {}

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

local function handle_player_entry_event(player, node_pos)
    local node_name = minetest.get_node(node_pos).name
    if(node_name == "block_alert:notifier") then
        notifier.handle_player_event(player, node_pos, "entered")
    elseif node_name == "block_alert:recorder" then
        recorder.handle_player_event(player,node_pos,"entered")
    end
end

local function handle_player_exit_event(player, node_pos)
    local node_name = minetest.get_node(node_pos).name
    if(node_name == "block_alert:notifier") then
        notifier.handle_player_event(player, node_pos, "exited")
    elseif node_name == "block_alert:recorder" then
        recorder.handle_player_event(player,node_pos,"exited")
    end
end

function util.check_permission(pos, pname)
    local reinf = ct.get_reinforcement(pos)
    if reinf then
        local player_id = pm.get_player_by_name(pname).id
        if pm.get_player_group(player_id, reinf.ctgroup_id) then return true else return false end
    else return true
    end
    return false
end

function util.different_pos(pos1,pos2)
    if pos1.x ~= pos2.x then return true
    elseif pos1.z ~= pos2.z then return true
    elseif pos1.y ~= pos2.y then return true
    else return false
    end
end

function util.find_nodes(center_pos, search_radius, block_type)
    local bound1 = vector.subtract(center_pos, {x = search_radius, y=search_radius , z= search_radius})
    local bound2 = vector.add(center_pos, {x = search_radius, y=search_radius , z= search_radius})
    local nodeList = minetest.find_nodes_in_area(bound1, bound2, block_type)
    return nodeList
end

function util.check_new_player_move(player)
    local player_name = player:get_player_name()
    local old_alert_list = player_alert_status[player_name]
    if old_alert_list == nil then old_alert_list = {} end
    local new_alert_list = util.find_nodes(player:get_pos(), 5, {"block_alert:notifier","block_alert:recorder"})

    local lookup_table_new = {}
    local lookup_table_old = {}

    for _, node_pos in pairs(new_alert_list) do
        local string_pos = minetest.pos_to_string(node_pos)
        lookup_table_new[string_pos] = true
    end

    for _, node_pos in pairs(old_alert_list) do
        local string_pos = minetest.pos_to_string(node_pos)
        if(lookup_table_new[string_pos]==nil) then 
            handle_player_exit_event(player, node_pos)
        end
        lookup_table_old[string_pos] = true
    end

    for _, node_pos in pairs(new_alert_list) do
        local string_pos = minetest.pos_to_string(node_pos)
        if(lookup_table_old[string_pos]==nil) then
            handle_player_entry_event(player, node_pos)
        end
    end

    player_alert_status[player_name] = new_alert_list
end