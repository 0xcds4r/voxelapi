--[[
////////////////////////////////////////////////////////////////////////////////
//  
//  FILE:   "modules/logger/logger.lua"
//  BY:     0xcds4r
//  FOR:    Voxel API
//  ON:     16 Mar 2025
//  WHAT:   Centralized logging utility for VoxelAPI.
//
////////////////////////////////////////////////////////////////////////////////
]]

local Logger = {}

Logger.LEVEL = {
    ERROR = 1,  
    WARN  = 2,  
    INFO  = 3,  
    DEBUG = 4
}

Logger.current_level = Logger.LEVEL.INFO
Logger.prefix = "VoxelAPI"

local function format_message(level, message)
    local prefix = "[" .. os.date("%Y/%m/%d %H:%M:%S") .. "] [".. Logger.prefix .." / " .. level .. "] "
    return prefix .. message
end

function Logger.error(message)
    if Logger.current_level >= Logger.LEVEL.ERROR then
        print(format_message("ERROR", message))
    end
end

function Logger.warn(message)
    if Logger.current_level >= Logger.LEVEL.WARN then
        print(format_message("WARN", message))
    end
end

function Logger.info(message)
    if Logger.current_level >= Logger.LEVEL.INFO then
        print(format_message("INFO", message))
    end
end

function Logger.debug(message)
    if Logger.current_level >= Logger.LEVEL.DEBUG then
        print(format_message("DEBUG", message))
    end
end

function Logger.set_level(level)
    Logger.current_level = level
end

return Logger