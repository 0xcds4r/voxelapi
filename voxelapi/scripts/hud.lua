--[[
////////////////////////////////////////////////////////////////////////////////
//  
//  FILE:   "scripts/components/hud.lua"
//  BY:     0xcds4r
//  FOR:    Voxel API - HUD Events
//  ON:     16 Mar 2025
//  WHAT:   Handles HUD-related events and initializes local player for VoxelAPI.
//
////////////////////////////////////////////////////////////////////////////////
]]

local VoxelAPI = _G.VoxelAPI or {}
local Player = VoxelAPI.Player or require "player/player"
local Logger = require "logger/logger"

function on_hud_open(playerid)
    Logger.debug("HUD opened for player: " .. playerid)
    
    local pid = hud.get_player()
    if pid then
        Player.set_local(pid)
        Logger.debug("Local player set: PID " .. pid .. ", UID: " .. Player.get_entity(pid))
    else
        Logger.warn("Failed to get local player via hud.get_player()")
    end

    VoxelAPI.emit("hud_open")
end

function on_hud_close(playerid)
    Logger.debug("HUD closed for player: " .. playerid)
    VoxelAPI.emit("hud_close")
end