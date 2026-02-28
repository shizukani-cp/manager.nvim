---@class manager.Spec
---@field id string
---@field url string
---@field branch? string
---@field config? fun()
---@field dependencies? string[]
---@field dev? boolean
---@field dir? string

---@class manager.Plugin
---@field spec manager.Spec
---@field status 'new'|'installing'|'installed'|'loaded'|'failed'
---@field on_installed_callbacks fun()[]

---@class Manager
---@field plugins table<string, manager.Plugin>
---@field logger manager.core.Logger
---@field name string
---@field manager_installed_path string
---@field install_base_path string
local Manager = {}
Manager.__index = Manager

---@return Manager
function Manager.new(name)
    local self = setmetatable({}, Manager)
    self.name = name or "manager"
    self.manager_installed_path =
        vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", self.name, "start", "manager.nvim")
    self.install_base_path = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", self.name, "opt")
    self.plugins = {}
    self.logger = require("manager.core.logger").new()
    return self
end

Manager.add = require("manager.core.add")

Manager.clean = require("manager.core.clean")

Manager.load = require("manager.core.load").load

Manager.remove = require("manager.core.remove")

Manager.update = require("manager.core.update")

Manager.plugin_path = function(self, plugin_id)
    return vim.fs.joinpath(self.install_base_path, plugin_id)
end

return Manager
