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
    local nodeList = minetest.find_nodes_in_area(bound1, bound2, { block_type })
    return nodeList
end