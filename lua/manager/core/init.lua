local install_base_path = vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'pack', 'manager', 'opt')
local manager_installed_path = vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'pack', 'manager', 'start', 'manager.nvim')

local M = {}

M.plugins = {}

M.add = function(spec)
    require("manager.core.add")(spec, M.plugins, install_base_path)
end

M.clean = function()
    require("manager.core.clean")(M.plugins, install_base_path)
end

M.load = function(id)
    require("manager.core.load").load(id, M.plugins)
end

M.lock = function()
    require("manager.core.load").lock()
end

M.remove = function(id)
    require("manager.core.remove")(id, M.plugins, install_base_path)
end

M.unlock = function()
    require("manager.core.load").unlock(M.load)
end

M.update = function(id)
    require("manager.core.update")(id, M.plugins, install_base_path, manager_installed_path)
end

return M
