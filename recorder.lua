local function get_log(recorder_pos)
    local meta = minetest.get_meta(recorder_pos)
    local log = minetest.deserialize(meta:get_string("log"))
    if not log then log = {} end
    return log
end

local function add_entry(recorder_pos, message)
    local log = get_log(recorder_pos)
    table.insert( log, 1,  message)
    if table.getn(log) > 500 then table.remove(log) end
    local meta = minetest.get_meta(recorder_pos)
    meta:set_string("log", minetest.serialize(log))
    meta:mark_as_private("log")
end

function recorder.get_formspec(recorder_pos)
    local log = get_log(recorder_pos)
    local formspec = {
        "size[10,10]",
        "real_coordinates[true]",
        "textlist[0.5,0.5;9,9;log;"
    }
    for _,text in pairs(log) do
        table.insert(formspec, minetest.formspec_escape(text))
        table.insert(formspec, ",")
    end
    table.insert(formspec, "]")
    return table.concat(formspec, "")
end

function recorder.handle_block_event(pos, node_name, player_name, event_type)  
    local recorders = util.find_nodes(pos, 5, {"block_alert:recorder"})
    if recorders then
        local message = os.date("[%d/%m %H:%M]") .. player_name .. " " .. event_type .." " .. node_name .. " at " .. minetest.pos_to_string(pos)
        for _,recorder_pos in ipairs(recorders) do
            add_entry(recorder_pos, message)
        end
    end
end

function recorder.handle_player_event(player, recorder_pos, event_type)
    local messageString = os.date("[%d/%m %H:%M]") .. player:get_player_name() .. " " .. event_type
    add_entry(recorder_pos, messageString)
end