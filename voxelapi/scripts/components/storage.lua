--[[
////////////////////////////////////////////////////////////////////////////////
//  
//  FILE:   "scripts/components/storage.lua"
//  BY:     0xcds4r
//  FOR:    Voxel API
//  ON:     16 Mar 2025
//  WHAT:   Storage management module with binary file persistence (no bit32).
//
////////////////////////////////////////////////////////////////////////////////
]]

local Storage = {}

local Logger = require "logger/logger"
local base_util = require "base:util"

local currentStorage = nil

local STORAGE_DATA = {
    storage = {
        data = {}
    }
}

local STORAGE_FILE = "config:storage/storage_data.bin"

local TYPE_STRING = 1
local TYPE_NUMBER = 2
local TYPE_TABLE = 3
local TYPE_END = 4

local function serialize_to_bytes(data, bytes)
    bytes = bytes or {}
    local data_type = type(data)

    if data_type == "string" then
        table.insert(bytes, TYPE_STRING)
        local len = #data
        table.insert(bytes, math.floor(len % 256))
        table.insert(bytes, math.floor((len / 256) % 256))
        table.insert(bytes, math.floor((len / (256 * 256)) % 256))
        table.insert(bytes, math.floor((len / (256 * 256 * 256)) % 256))
        for i = 1, len do
            table.insert(bytes, string.byte(data, i))
        end
    elseif data_type == "number" then
        table.insert(bytes, TYPE_NUMBER)
        local num = math.floor(data)
        table.insert(bytes, math.floor(num % 256))
        table.insert(bytes, math.floor((num / 256) % 256))
        table.insert(bytes, math.floor((num / (256 * 256)) % 256))
        table.insert(bytes, math.floor((num / (256 * 256 * 256)) % 256))
    elseif data_type == "table" then
        table.insert(bytes, TYPE_TABLE)
        for key, value in pairs(data) do
            serialize_to_bytes(key, bytes)   
            serialize_to_bytes(value, bytes)  
        end
        table.insert(bytes, TYPE_END)  
    end
    return bytes
end

local function deserialize_from_bytes(bytes, pos)
    pos = pos or 1
    local data_type = bytes[pos]
    pos = pos + 1

    if data_type == TYPE_STRING then
        local len = bytes[pos] +
                    (bytes[pos + 1] * 256) +
                    (bytes[pos + 2] * 256 * 256) +
                    (bytes[pos + 3] * 256 * 256 * 256)
        pos = pos + 4
        local chars = {}
        for i = 1, len do
            chars[i] = string.char(bytes[pos])
            pos = pos + 1
        end
        return table.concat(chars), pos
    elseif data_type == TYPE_NUMBER then
        local num = bytes[pos] +
                    (bytes[pos + 1] * 256) +
                    (bytes[pos + 2] * 256 * 256) +
                    (bytes[pos + 3] * 256 * 256 * 256)
        pos = pos + 4
        return num, pos
    elseif data_type == TYPE_TABLE then
        local tbl = {}
        while bytes[pos] ~= TYPE_END do
            local key, new_pos = deserialize_from_bytes(bytes, pos)
            pos = new_pos
            local value, next_pos = deserialize_from_bytes(bytes, pos)
            pos = next_pos
            tbl[key] = value
        end
        pos = pos + 1
        return tbl, pos
    end
end

function Storage.register(identifier)
    if type(identifier) ~= "string" then
        Logger.error("Invalid identifier type for register: expected string, got " .. type(identifier))
        return nil
    end

    if not next(STORAGE_DATA.storage.data) and file.exists(STORAGE_FILE) then
        local byte_data = file.read_bytes(STORAGE_FILE)
        if byte_data and #byte_data > 0 then
            local loaded_data, pos = deserialize_from_bytes(byte_data, 1)
            if loaded_data and loaded_data.storage and loaded_data.storage.data then
                STORAGE_DATA.storage.data = loaded_data.storage.data
                Logger.info("Loaded storage data from file: " .. STORAGE_FILE)
            else
                Logger.warn("Failed to deserialize valid storage data from file: " .. STORAGE_FILE)
            end
        else
            Logger.warn("Failed to read storage file or file is empty: " .. STORAGE_FILE)
        end
    end

    if STORAGE_DATA.storage.data[identifier] then
        Logger.info("Storage already registered, setting current: " .. identifier)
        currentStorage = STORAGE_DATA.storage.data[identifier]
        return currentStorage
    end

    STORAGE_DATA.storage.data[identifier] = {
        identifier = identifier,
        test = "testtesttest"
    }
    currentStorage = STORAGE_DATA.storage.data[identifier]
    Logger.info("Registering new storage with identifier: " .. identifier)
    return currentStorage
end

function Storage.put(key, value)
    local storage = Storage.getCurrentStorage()
    if not storage then
        Logger.error("Cannot put value: no current storage set")
        return false
    end

    if type(key) ~= "string" and type(key) ~= "number" then
        Logger.error("Invalid key type for put: expected string or number, got " .. type(key))
        return false
    end

    local value_type = type(value)
    if value_type ~= "string" and value_type ~= "number" and value_type ~= "table" then
        Logger.error("Invalid value type for put: expected string, number or table, got " .. value_type)
        return false
    end

    storage[key] = value
    Logger.debug("Stored value for key '" .. tostring(key) .. "' in storage '" .. storage.identifier .. "'")
    return true
end

function Storage.exists(key)
    local storage = Storage.getCurrentStorage()
    if not storage then
        Logger.error("Cannot check existence: no current storage set")
        return false
    end

    if type(key) ~= "string" and type(key) ~= "number" then
        Logger.error("Invalid key type for exists: expected string or number, got " .. type(key))
        return false
    end

    local exists = storage[key] ~= nil
    Logger.debug("Checked existence of key '" .. tostring(key) .. "' in storage '" .. storage.identifier .. "': " .. tostring(exists))
    return exists
end

function Storage.get(key)
    local storage = Storage.getCurrentStorage()
    if not storage then
        Logger.error("Cannot get value: no current storage set")
        return nil
    end

    if type(key) ~= "string" and type(key) ~= "number" then
        Logger.error("Invalid key type for get: expected string or number, got " .. type(key))
        return nil
    end

    local value = storage[key]
    if value ~= nil then
        Logger.debug("Retrieved value for key '" .. tostring(key) .. "' from storage '" .. storage.identifier .. "'")
        return value
    else
        Logger.warn("Key '" .. tostring(key) .. "' not found in storage '" .. storage.identifier .. "'")
        return nil
    end
end

function Storage.remove(key)
    local storage = Storage.getCurrentStorage()
    if not storage then
        Logger.error("Cannot remove value: no current storage set")
        return false
    end

    if type(key) ~= "string" and type(key) ~= "number" then
        Logger.error("Invalid key type for remove: expected string or number, got " .. type(key))
        return false
    end

    if storage[key] ~= nil then
        storage[key] = nil
        Logger.debug("Removed key '" .. tostring(key) .. "' from storage '" .. storage.identifier .. "'")
        return true
    else
        Logger.warn("Key '" .. tostring(key) .. "' not found in storage '" .. storage.identifier .. "'")
        return false
    end
end

function on_save()
    Logger.info("Saving storages..")
    
    if not file.is_writeable(STORAGE_FILE) then
        Logger.error("Storage file is not writable: " .. STORAGE_FILE)
        return
    end

    local dir_path = "config:storage"
    if not file.isdir(dir_path) then
        if file.mkdirs(dir_path) then
            Logger.debug("Created storage directory: " .. dir_path)
        else
            Logger.error("Failed to create storage directory: " .. dir_path)
            return
        end
    end

    local byte_data = serialize_to_bytes(STORAGE_DATA)
    local success, err = pcall(file.write_bytes, STORAGE_FILE, byte_data)
    if success then
        Logger.debug("Saved storage data to file: " .. STORAGE_FILE .. " (size: " .. (file.length(STORAGE_FILE) or -1) .. " bytes)")
    else
        Logger.error("Failed to write storage data to file: " .. STORAGE_FILE .. " - " .. err)
    end
end

function Storage.getCurrentStorage()
    if currentStorage then
        return currentStorage
    else
        Logger.warn("No current storage set")
        return nil
    end
end

function Storage.getId()
    local storage = Storage.getCurrentStorage()
    if storage then
        return storage.identifier
    else
        Logger.warn("Cannot get ID: no current storage")
        return nil
    end
end

function Storage.getTest()
    local storage = Storage.getCurrentStorage()
    if storage then
        return storage.test
    else
        Logger.warn("Cannot get test value: no current storage")
        return nil
    end
end

return Storage