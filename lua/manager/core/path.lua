---@class manager.core.Path
local M = {}

---@type string
M.install_base_path = vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'pack', 'manager', 'opt')
---@type string
M.manager_installed_path = vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'pack', 'manager', 'start', 'manager.nvim')

---@param plugin_id string
---@return string
M.plugin_path = function(plugin_id)
    return vim.fs.joinpath(M.install_base_path, plugin_id)
end

return M
