---@type table<string, boolean>
local loaded_plugins = {}

local M = {}

---@param id string
local function _do_load(manager, id)
    if loaded_plugins[id] then
        return
    end
    local plugin = manager.plugins[id]
    vim.cmd("packadd " .. plugin.spec.id)
    if type(plugin.spec.config) == "function" then
        plugin.spec.config(manager)
    end
    loaded_plugins[id] = true
    plugin.status = "loaded"
    manager.logger:info("Successfuly loaded " .. id)
end

---@param id string
local function _load_with_deps_check(manager, id)
    if loaded_plugins[id] then
        return
    end
    local plugin = manager.plugins[id]
    local dependencies = plugin.spec.dependencies or {}
    local all_deps_installed = true
    ---@type manager.Plugin[]
    local pending_deps = {}

    for _, dep_id in ipairs(dependencies) do
        M.load(manager, dep_id)
        local dep_plugin = manager.plugins[dep_id]
        if dep_plugin.status ~= "installed" and dep_plugin.status ~= "loaded" then
            all_deps_installed = false
            table.insert(pending_deps, dep_plugin)
        end
    end

    if all_deps_installed then
        _do_load(manager, id)
    else
        local loaded_deps_count = 0
        local total_deps = #pending_deps

        local function check_and_load_self()
            loaded_deps_count = loaded_deps_count + 1
            if loaded_deps_count == total_deps then
                _do_load(manager, id)
            end
        end

        for _, dep_plugin in ipairs(pending_deps) do
            table.insert(dep_plugin.on_installed_callbacks, check_and_load_self)
        end
    end
end

---@param id string
function M.load(self, id)
    if loaded_plugins[id] then
        return
    end
    local plugin = self.plugins[id]
    if not plugin then
        error("plugin '" .. id .. "' not found, please make sure you did add().")
    end

    if plugin.status == "installed" or plugin.status == "loaded" then
        _load_with_deps_check(self, id)
    elseif plugin.status == "installing" then
        table.insert(plugin.on_installed_callbacks, function()
            _load_with_deps_check(self, id)
        end)
    else
        self.logger:error("Could not load '" .. id .. "' The status is not correct: " .. plugin.status)
    end
end

return M
