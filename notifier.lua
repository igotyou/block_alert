local lastNotification = {} --This is used to avoid spamming

local function get_seconds_since_last_notification(string)
    if(lastNotification[string]) then 
        return ((minetest.get_us_time() - lastNotification[string])/1000000.0) 
    else 
        return 60 --This is a arbitriaty large number
    end
end

function notifier.get_formspec(name)
    local formspec = {
        "size[3,2]",
        "real_coordinates[true]",
        "field[0.5,0.5;2.5,1;name;Name;" .. minetest.formspec_escape(name) .. "]",
        "button_exit[1,1.5;1,1;rename;Rename]"
    }
    return table.concat(formspec, "")
end

function notifier.handle_player_entry(player, pos)
    local reinf = ct.get_reinforcement(pos)
    if reinf then
        local meta = minetest.get_meta(pos)
        local messageString = player:get_player_name() .. " entered " .. meta:get_string("name") .. " at " .. minetest.pos_to_string(pos)
        local secondsSinceLast = get_seconds_since_last_notification(messageString)
        if(secondsSinceLast > 10) then 
            pm.send_chat_group(reinf.ctgroup_id, messageString)
            lastNotification[messageString] = minetest.get_us_time()
        end
    end
end