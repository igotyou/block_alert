local function add_entry(recorder_pos, message)
    local meta = minetest.get_meta(recorder_pos)
    local log = minetest.deserialize(meta:get_string("log"))
    if not log then log = {} end
    table.insert(log, message)
    if table.getn(log) > 100 then table.remove(log, 1) end
    meta:set_string("log", minetest.serialize(log))
    meta:mark_as_private("log")
end

function recorder.handle_block_event(pos, node_name, player_name, event_type)  
    local recorders = util.find_nodes(pos, 5, "block_alert:recorder")
    if recorders then
        local message = os.date("[%d/%m %H:%M]") .. player_name .. " " .. event_type .." " .. node_name .. " at " .. minetest.pos_to_string(pos)
        for _,recorder_pos in ipairs(recorders) do
            add_entry(recorder_pos, message)
        end
    end
end