---@class manager.Spec
---@field id string
---@field url string
---@field branch? string
---@field config? fun()
---@field dependencies? string[]

---@class manager.Plugin
---@field spec manager.Spec
---@field status 'new'|'installing'|'installed'|'loaded'|'failed'
---@field on_installed_callbacks fun()[]

---@class manager
local M = {}

---@type table<string, manager.Plugin>
M.plugins = {}

---@type manager.core.Logger
M.logger = require("manager.core.logger").new()

---@param spec manager.Spec
M.add = function(spec)
    require("manager.core.add")(spec, M.plugins, M.logger)
end

M.clean = function()
    require("manager.core.clean")(M.plugins, M.logger)
end

---@param id string
M.load = function(id)
    require("manager.core.load").load(id, M.plugins, M.logger)
end

M.lock = function()
    require("manager.core.load").lock()
end

---@param id string
M.remove = function(id)
    require("manager.core.remove")(id, M.plugins, M.logger)
end

M.unlock = function()
    require("manager.core.load").unlock(M.load, M.logger)
end

---@param id? string
M.update = function(id)
    require("manager.core.update")(id, M.plugins, M.logger)
end

return M
