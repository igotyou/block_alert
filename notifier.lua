function notifier.get_formspec(name)
    local formspec = {
        "size[3,2]",
        "real_coordinates[true]",
        "field[0.5,0.5;2.5,1;name;Name;" .. minetest.formspec_escape(name) .. "]",
        "button_exit[1,1.5;1,1;rename;Rename]"
    }
    return table.concat(formspec, "")
end

function notifier.handle_player_event(player, node_pos, event_type)
    local reinf = ct.get_reinforcement(node_pos)
    if reinf then
        local meta = minetest.get_meta(node_pos)
        local messageString = player:get_player_name() .. " " .. event_type .. " " .. meta:get_string("name") .. " at " .. minetest.pos_to_string(node_pos)
        pm.send_chat_group(reinf.ctgroup_id, messageString)
    end
end