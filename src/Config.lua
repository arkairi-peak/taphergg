--[[
    TapherLib/Config.lua
    Handles saving and loading of UI component states via writefile/readfile.
    Falls back gracefully if file I/O is unavailable.
]]

local Config = {}

local HttpService = game:GetService("HttpService")

local FOLDER_NAME = "TapherLib"
local FILE_EXT    = ".json"

-- ── Internal ─────────────────────────────────────────────────────────────────

local function canUseFiles()
    return pcall(function()
        if not isfolder then error() end
    end) == false and (isfolder ~= nil)
end

local function ensureFolder()
    if isfolder and not isfolder(FOLDER_NAME) then
        makefolder(FOLDER_NAME)
    end
end

local function getPath(name)
    return FOLDER_NAME .. "/" .. name .. FILE_EXT
end

-- ── API ──────────────────────────────────────────────────────────────────────

-- Save a table to a named config file
function Config.Save(name, data)
    if not writefile then
        warn("[TapherLib:Config] writefile not available — skipping save.")
        return false
    end
    ensureFolder()
    local ok, err = pcall(function()
        local encoded = HttpService:JSONEncode(data)
        writefile(getPath(name), encoded)
    end)
    if not ok then
        warn("[TapherLib:Config] Save failed: " .. tostring(err))
        return false
    end
    return true
end

-- Load a named config file, returns table or nil
function Config.Load(name)
    if not readfile then
        warn("[TapherLib:Config] readfile not available — skipping load.")
        return nil
    end
    local path = getPath(name)
    if isfile and not isfile(path) then return nil end
    local ok, result = pcall(function()
        local raw = readfile(path)
        return HttpService:JSONDecode(raw)
    end)
    if ok then
        return result
    else
        warn("[TapherLib:Config] Load failed: " .. tostring(result))
        return nil
    end
end

-- Delete a config file
function Config.Delete(name)
    if not delfile then return false end
    local path = getPath(name)
    if isfile and isfile(path) then
        pcall(function() delfile(path) end)
    end
    return true
end

-- List all saved configs
function Config.List()
    if not listfiles then return {} end
    ensureFolder()
    local results = {}
    local ok, files = pcall(listfiles, FOLDER_NAME)
    if ok then
        for _, f in ipairs(files) do
            local name = f:match("([^/\\]+)" .. FILE_EXT .. "$")
            if name then
                table.insert(results, name)
            end
        end
    end
    return results
end

-- ── Auto-save manager ────────────────────────────────────────────────────────
-- Components register themselves here; call Config.SaveAll() to persist everything

Config._registry = {}

function Config.Register(name, getState, setState)
    Config._registry[name] = { get = getState, set = setState }
end

function Config.SaveAll(profileName)
    local snapshot = {}
    for key, entry in pairs(Config._registry) do
        local ok, val = pcall(entry.get)
        if ok then snapshot[key] = val end
    end
    return Config.Save(profileName or "default", snapshot)
end

function Config.LoadAll(profileName)
    local data = Config.Load(profileName or "default")
    if not data then return false end
    for key, entry in pairs(Config._registry) do
        if data[key] ~= nil then
            pcall(entry.set, data[key])
        end
    end
    return true
end

return Config
