--[[
////////////////////////////////////////////////////////////////////////////////
//  
//  FILE:   "scripts/world.lua"
//  BY:     0xcds4r
//  FOR:    Voxel API
//  ON:     16 Mar 2025
//  WHAT:   API for managing world events, utilities, and game logic in VoxelCore.
//
////////////////////////////////////////////////////////////////////////////////
]]

local Logger = require "logger/logger"
Logger.set_level(Logger.LEVEL.DEBUG)

Logger.info("--------------------------------------------------")
Logger.info("|       VoxelAPI v1.0 by 0xcds4r loaded!         |")
Logger.info("--------------------------------------------------")

local VoxelAPI = {
    events = {},     
    utils = {},     
    data = {}        
}

VoxelAPI.Player = require "player/player"
VoxelAPI.Camera = require "camera/camera"
VoxelAPI.Storage = require "../scripts/components/storage"

VoxelAPI.Storage.register('voxelapi_storage')

function VoxelAPI.on(event_name, callback)
    VoxelAPI.events[event_name] = VoxelAPI.events[event_name] or {}
    table.insert(VoxelAPI.events[event_name], callback)
end

function VoxelAPI.emit(event_name, ...)
    local handlers = VoxelAPI.events[event_name]
    if handlers then
        for _, callback in ipairs(handlers) do
            callback(...)
        end
    end
end

function on_world_open()
    VoxelAPI.emit("world_open")

    if not VoxelAPI.Storage.exists("vonka") then
        Logger.debug("vonka not exists, putting data..")
        VoxelAPI.Storage.put("vonka", "sdifsdvonkatext")
    else
        Logger.debug("vonka exists: " .. VoxelAPI.Storage.get("vonka"))
    end

    Logger.debug("Opening world..")
end

function on_world_save()
    VoxelAPI.emit("world_save")
    Logger.debug("Saving world..")
end

function on_world_tick()
    VoxelAPI.emit("world_tick")
end

function on_world_quit()
    VoxelAPI.emit("world_quit")
    Logger.debug("Quit world..")
end

function on_block_placed(blockid, x, y, z, pid)
    VoxelAPI.emit("block_placed", blockid, x, y, z, pid)
end

function on_block_replaced(blockid, x, y, z, pid)
    VoxelAPI.emit("block_replaced", blockid, x, y, z, pid)
end

function on_block_broken(blockid, x, y, z, pid)
    VoxelAPI.emit("block_broken", blockid, x, y, z, pid)
end

function on_block_interact(blockid, x, y, z, pid)
    local prevent_default = false
    local handlers = VoxelAPI.events["block_interact"]
    if handlers then
        for _, callback in ipairs(handlers) do
            if callback(blockid, x, y, z, pid) == true then
                prevent_default = true
            end
        end
    end
    return prevent_default
end

function on_player_tick(pid, tps)
    VoxelAPI.emit("player_tick", pid, tps)
end

function on_chunk_present(x, z, loaded)
    VoxelAPI.emit("chunk_present", x, z, loaded)
end

function on_chunk_remove(x, z)
    VoxelAPI.emit("chunk_remove", x, z)
end

function on_inventory_open(invid, pid)
    VoxelAPI.emit("inventory_open", invid, pid)
end

function on_inventory_closed(invid, pid)
    VoxelAPI.emit("inventory_closed", invid, pid)
end

function on_use(playerid)
    VoxelAPI.emit("use", playerid)
end

function on_use_on_block(x, y, z, playerid, normal)
    local prevent_default = false
    local handlers = VoxelAPI.events["use_on_block"]
    if handlers then
        for _, callback in ipairs(handlers) do
            if callback(x, y, z, playerid, normal) == true then
                prevent_default = true
            end
        end
    end
    return prevent_default
end

function on_block_break_by(x, y, z, playerid)
    VoxelAPI.emit("block_break_by", x, y, z, playerid)
end

_G.VoxelAPI = VoxelAPI

VoxelAPI.on("world_open", function()
    Logger.debug("world_open")
end)

VoxelAPI.on("world_save", function()
    Logger.debug("world_save")
end)

VoxelAPI.on("world_tick", function()
    VoxelAPI.data.tick_counter = (VoxelAPI.data.tick_counter or 0) + 1
    if VoxelAPI.data.tick_counter % 20 == 0 then
        Logger.debug("World tick counter: " .. VoxelAPI.data.tick_counter)
    end
end)

VoxelAPI.on("world_quit", function()
    Logger.debug("world_quit")
end)

VoxelAPI.on("hud_open", function()
    Logger.debug("Hud has been opened!")
    local local_player = VoxelAPI.Player.get_local()
    if local_player then
        Logger.debug("Local player set: PID: " .. local_player.pid .. ", UID: " .. local_player.uid)
        local x, y, z = VoxelAPI.Player.get_pos(local_player.pid)
        Logger.debug("Player position: (" .. x .. ", " .. y .. ", " .. z .. ")")
        VoxelAPI.Player.set_pos(local_player.pid, 0, 85, 0)
        VoxelAPI.Player.add_item(local_player.pid, 7, 10)

        local cam = VoxelAPI.Camera.getInstance("core:first-person")
        if cam then
            local pos = VoxelAPI.Camera.get_pos()
            Logger.info("Switched to camera '" .. cam:get_name() .. " Pos: (x: '" .. pos.x .. "' y: '" .. pos.y .. "' z: '" .. pos.z .. "') (index " .. cam:get_index() .. ") for player " .. local_player.pid)
        else
            Logger.warn("Third-person camera not found, using default")
        end
    else
        Logger.error("Failed to set local player!")
    end
end)

VoxelAPI.on("block_placed", function(blockid, x, y, z, pid)
    Logger.debug("Block " .. blockid .. " placed at (" .. x .. ", " .. y .. ", " .. z .. ") by player " .. pid)
end)

VoxelAPI.on("block_replaced", function(blockid, x, y, z, pid)
    Logger.debug("Block " .. blockid .. " replaced at (" .. x .. ", " .. y .. ", " .. z .. ") by player " .. pid)
end)

VoxelAPI.on("block_broken", function(blockid, x, y, z, pid)
    Logger.debug("Block " .. blockid .. " broken at (" .. x .. ", " .. y .. ", " .. z .. ") by player " .. pid)
    if pid >= 0 then  -- Проверяем, что pid валиден (не отрицательный)
        local vx, vy, vz = VoxelAPI.Player.get_vel(pid)
        if vx and vy and vz then
            Logger.debug("Player velocity: (" .. vx .. ", " .. vy .. ", " .. vz .. ")")
        else
            Logger.warn("Could not retrieve velocity for player " .. pid)
        end
    else
        Logger.debug("Velocity not available for system entity (pid = " .. pid .. ")")
    end
end)

VoxelAPI.on("block_interact", function(blockid, x, y, z, pid)
    Logger.debug("Player " .. pid .. " interacted with block " .. blockid .. " at (" .. x .. ", " .. y .. ", " .. z .. ")")
    if blockid == "base:stone" then
        Logger.debug("Interaction with stone blocked!")
        return true
    end
    return false
end)

VoxelAPI.on("player_tick", function(pid, tps)
    local local_player = VoxelAPI.Player.get_local()
    if local_player and local_player.pid == pid then
        local x, y, z = VoxelAPI.Player.get_pos(pid)
        if y < 0 then
            Logger.warn("Player " .. pid .. " fell below y=0! Teleporting back.")
            VoxelAPI.Player.set_pos(pid, x, 85, z)
        end
    end
end)

--[[VoxelAPI.on("chunk_present", function(x, z, loaded)
    if loaded then
        Logger.debug("Chunk (" .. x .. ", " .. z .. ") loaded from save.")
    else
        Logger.debug("Chunk (" .. x .. ", " .. z .. ") generated.")
    end
end)

VoxelAPI.on("chunk_remove", function(x, z)
    Logger.debug("Chunk (" .. x .. ", " .. z .. ") unloaded.")
end)]]

VoxelAPI.on("inventory_open", function(invid, pid)
    if pid == -1 then
        Logger.debug("Inventory " .. invid .. " opened by system.")
    else
        Logger.debug("Player " .. pid .. " opened inventory " .. invid .. ".")
    end
end)

VoxelAPI.on("inventory_closed", function(invid, pid)
    Logger.debug("Inventory " .. invid .. " closed for player " .. pid .. ".")
end)

VoxelAPI.on("use", function(playerid)
    Logger.debug("Player " .. playerid .. " used an item (right-click in air).")
    local local_player = VoxelAPI.Player.get_local()
    if local_player and local_player.pid == playerid then
        local x, y, z = VoxelAPI.Player.get_pos(playerid)
        Logger.debug("Player position during use: (" .. x .. ", " .. y .. ", " .. z .. ")")
    end
end)

VoxelAPI.on("use_on_block", function(x, y, z, playerid, normal)
    Logger.debug("Player " .. playerid .. " right-clicked block at (" .. x .. ", " .. y .. ", " .. z .. ") with normal (" .. normal.x .. ", " .. normal.y .. ", " .. normal.z .. ")")
    if x == 7 and y == 72 and z == 4 then
        Logger.debug("Block placement prevented at (" .. x .. ", " .. y .. ", " .. z .. ")!")
        return true
    end
    return false
end)

VoxelAPI.on("block_break_by", function(x, y, z, playerid)
    Logger.debug("Block broken at (" .. x .. ", " .. y .. ", " .. z .. ") by player " .. playerid)
    if playerid >= 0 then  
        local vx, vy, vz = VoxelAPI.Player.get_vel(playerid)
        if vx and vy and vz then
            Logger.debug("Player velocity: (" .. vx .. ", " .. vy .. ", " .. vz .. ")")
        else
            Logger.warn("Could not retrieve velocity for player " .. playerid)
        end
    else
        Logger.debug("Velocity not available for system entity (pid = " .. playerid .. ")")
    end
end)