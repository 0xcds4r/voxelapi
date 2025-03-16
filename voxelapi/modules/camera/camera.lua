--[[
////////////////////////////////////////////////////////////////////////////////
//  
//  FILE:   "scripts/camera.lua"
//  BY:     0xcds4r
//  FOR:    Voxel API
//  ON:     16 Mar 2025
//  WHAT:   Wrapper around the built-in cameras library for easier camera management.
//
////////////////////////////////////////////////////////////////////////////////
]]

local Camera = {}
local Logger = require "logger/logger"
local aCams = nil

function Camera.getInstance(identifier)
    local cam = cameras.get(identifier)
    if not cam then
        Logger.warn("Camera not found for identifier: " .. tostring(identifier))
        return nil
    end

    aCams = cam

    return aCams
end

function Camera.get_index()
    return aCams:get_index()
end

function Camera.get_name()
    return aCams:get_name()
end

function Camera.get_pos()
    local pos = aCams:get_pos()
    Logger.debug("Camera '" .. Camera.get_name() .. "' position: (" .. pos[1] .. ", " .. pos[2] .. ", " .. pos[3] .. ")")
    return {x = pos[1], y = pos[2], z = pos[3]}
end

function Camera.set_pos(pos)
    aCams:set_pos({pos.x, pos.y, pos.z})
    Logger.debug("Set camera '" .. Camera.get_name() .. "' position to (" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. ")")
end

function Camera.get_rot()
    local rot = aCams:get_rot()
    Logger.debug("Camera '" .. Camera.get_name() .. "' rotation retrieved")
    return rot
end

function Camera.set_rot(rot)
    -- todo Matrix
    Logger.debug("Set camera '" .. Camera.get_name() .. "' rotation")
end

function Camera.get_zoom()
    local zoom = aCams:get_zoom()
    Logger.debug("Camera '" .. Camera.get_name() .. "' zoom: " .. zoom)
    return zoom
end

function Camera.set_zoom(zoom)
    aCams:set_zoom(zoom)
    Logger.debug("Set camera '" .. Camera.get_name() .. "' zoom to " .. zoom)
end

function Camera.get_fov()
    local fov = aCams:get_fov()
    Logger.debug("Camera '" .. Camera.get_name() .. "' FOV: " .. fov)
    return fov
end

function Camera.set_fov(fov)
    aCams:set_fov(fov)
    Logger.debug("Set camera '" .. Camera.get_name() .. "' FOV to " .. fov)
end

function Camera.is_flipped()
    local flipped = aCams:is_flipped()
    Logger.debug("Camera '" .. Camera.get_name() .. "' flipped: " .. tostring(flipped))
    return flipped
end

function Camera.set_flipped(flipped)
    aCams:set_flipped(flipped)
    Logger.debug("Set camera '" .. Camera.get_name() .. "' flipped to " .. tostring(flipped))
end

function Camera.is_perspective()
    local perspective = aCams:is_perspective()
    Logger.debug("Camera '" .. Camera.get_name() .. "' perspective: " .. tostring(perspective))
    return perspective
end

function Camera.set_perspective(perspective)
    aCams:set_perspective(perspective)
    Logger.debug("Set camera '" .. Camera.get_name() .. "' perspective to " .. tostring(perspective))
end

function Camera.get_front()
    local front = aCams:get_front()
    Logger.debug("Camera '" .. Camera.get_name() .. "' front: (" .. front.x .. ", " .. front.y .. ", " .. front.z .. ")")
    return {x = front[1], y = front[2], z = front[3]}
end

function Camera.get_right()
    local right = aCams:get_right()
    Logger.debug("Camera '" .. Camera.get_name() .. "' right: (" .. right.x .. ", " .. right.y .. ", " .. right.z .. ")")
    return {x = right[1], y = right[2], z = right[3]}
end

function Camera.get_up()
    local up = aCams:get_up()
    Logger.debug("Camera '" .. Camera.get_name() .. "' up: (" .. up.x .. ", " .. up.y .. ", " .. up.z .. ")")
    return {x = up[1], y = up[2], z = up[3]}
end

function Camera.look_at(point, t)
    if t then
        aCams:look_at({point.x, point.y, point.z}, t)
        Logger.debug("Camera '" .. Camera.get_name() .. "' looking at (" .. point.x .. ", " .. point.y .. ", " .. point.z .. ") with interpolation " .. t)
    else
        aCams:look_at({point.x, point.y, point.z})
        Logger.debug("Camera '" .. Camera.get_name() .. "' looking at (" .. point.x .. ", " .. point.y .. ", " .. point.z .. ")")
    end
end

return Camera