--[[
////////////////////////////////////////////////////////////////////////////////
//  
//  FILE:   "modules/player/player.lua"
//  BY:     0xcds4r
//  FOR:    Voxel API - Player Utilities
//  ON:     16 Mar 2025
//  WHAT:   Player-related utilities for VoxelAPI, handling player creation, movement, and state management.
//
////////////////////////////////////////////////////////////////////////////////
]]

local Player = {}
local local_player_cache = nil

function Player.create(name)
    local pid = player.create(name)
    return pid
end

function Player.set_local(pid)
    local uid = player.get_entity(pid)
    if uid ~= 0 then
        local_player_cache = {pid = pid, uid = uid}
    end
end

function Player.get_local()
    if local_player_cache then
        local uid = player.get_entity(local_player_cache.pid)
        if uid ~= 0 then
            return local_player_cache
        else
            local_player_cache = nil
        end
    end
    return nil
end

function Player.delete(pid)
    player.delete(pid)
end

function Player.get_pos(pid)
    return player.get_pos(pid)
end

function Player.set_pos(pid, x, y, z)
    player.set_pos(pid, x, y, z)
end

function Player.get_vel(pid)
    return player.get_vel(pid)
end

function Player.set_vel(pid, x, y, z)
    player.set_vel(pid, x, y, z)
end

function Player.get_rot(pid, interpolated)
    return player.get_rot(pid, interpolated or false)
end

function Player.set_rot(pid, x, y, z)
    player.set_rot(pid, x, y, z)
end

function Player.get_inventory(pid)
    local invid = player.get_inventory(pid)
    local slot = player.get_selected_slot(pid)  
    return invid, slot
end

function Player.add_item(pid, item_id, count)
    local invid = player.get_inventory(pid)
    inventory.add(invid, item_id, count or 1)
end

function Player.is_flight(pid)
    return player.is_flight(pid)
end

function Player.set_flight(pid, enabled)
    player.set_flight(pid, enabled)
end

function Player.is_noclip(pid)
    return player.is_noclip(pid)
end

function Player.set_noclip(pid, enabled)
    player.set_noclip(pid, enabled)
end

function Player.is_infinite_items(pid)
    return player.is_infinite_items(pid)
end

function Player.set_infinite_items(pid, enabled)
    player.set_infinite_items(pid, enabled)
end

function Player.is_instant_destruction(pid)
    return player.is_instant_destruction(pid)
end

function Player.set_instant_destruction(pid, enabled)
    player.set_instant_destruction(pid, enabled)
end

function Player.is_loading_chunks(pid)
    return player.is_loading_chunks(pid)
end

function Player.set_loading_chunks(pid, enabled)
    player.set_loading_chunks(pid, enabled)
end

function Player.set_spawnpoint(pid, x, y, z)
    player.set_spawnpoint(pid, x, y, z)
end

function Player.get_spawnpoint(pid)
    return player.get_spawnpoint(pid)
end

function Player.is_suspended(pid)
    return player.is_suspended(pid)
end

function Player.set_suspended(pid, suspended)
    player.set_suspended(pid, suspended)
end

function Player.set_name(pid, name)
    player.set_name(pid, name)
end

function Player.get_name(pid)
    return player.get_name(pid)
end

function Player.set_selected_slot(pid, slotid)
    player.set_selected_slot(pid, slotid)
end

function Player.get_selected_block(pid)
    return player.get_selected_block(pid)
end

function Player.get_selected_entity(pid)
    return player.get_selected_entity(pid)
end

function Player.get_entity(pid)
    return player.get_entity(pid)
end

return Player