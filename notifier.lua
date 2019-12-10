local playerRenamePos = {}

local function get_formspec(name)
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
        local setting = meta:get_string("notify_setting")
        if setting == "others" then -- Make sure that we don't send a message if the player is on the group
            local player_id = pm.get_player_by_name(player:get_player_name()).id
            if player_id and pm.get_player_group(player_id,reinf.ctgroup_id) then return end
        end
        local messageString = player:get_player_name() .. " " .. event_type .. " " .. meta:get_string("name") .. " at " .. minetest.pos_to_string(node_pos)
        pm.send_chat_group(reinf.ctgroup_id, messageString)
    end
end

function notifier.handle_right_click(pos, clicker)
    local pname = clicker and clicker:get_player_name() or ""
    local meta = minetest.get_meta(pos)
    if(util.check_permission(pos,pname)) then 
        playerRenamePos[pname] = pos
        minetest.show_formspec(pname, "block_alert:notifier_rename", get_formspec(meta:get_string("name")))            
    end
end

function notifier.handle_formspec_submission(player, fields)
    if fields.name then
        local pname = player and player:get_player_name() or ""
        local meta = minetest.get_meta(playerRenamePos[pname])
        if(util.check_permission(playerRenamePos[pname],pname)) then
            meta:set_string("name", fields.name)
        end
    end
end