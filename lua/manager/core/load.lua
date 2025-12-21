local loaded_plugins = {}
local is_locked = false
local load_queue = {}

local M = {}

local function _do_load(id, plugins, logger)
    if loaded_plugins[id] then return end
    local plugin = plugins[id]
    vim.cmd('packadd ' .. plugin.spec.id)
    if type(plugin.spec.config) == 'function' then
        plugin.spec.config()
    end
    loaded_plugins[id] = true
    plugin.status = "loaded"
    logger:info("Successfuly loaded " .. id)
end

local function _load_with_deps_check(id, plugins, logger)
    if loaded_plugins[id] then return end
    local plugin = plugins[id]
    local dependencies = plugin.spec.dependencies or {}
    local all_deps_installed = true
    local pending_deps = {}

    for _, dep_id in ipairs(dependencies) do
        M.load(dep_id, plugins, logger)
        local dep_plugin = plugins[dep_id]
        if dep_plugin.status ~= 'installed' and dep_plugin.status ~= 'loaded' then
            all_deps_installed = false
            table.insert(pending_deps, dep_plugin)
        end
    end

    if all_deps_installed then
        _do_load(id, plugins, logger)
    else
        local loaded_deps_count = 0
        local total_deps = #pending_deps

        local function check_and_load_self()
            loaded_deps_count = loaded_deps_count + 1
            if loaded_deps_count == total_deps then
                _do_load(id, plugins, logger)
            end
        end

        for _, dep_plugin in ipairs(pending_deps) do
            table.insert(dep_plugin.on_installed_callbacks, check_and_load_self)
        end
    end
end

function M.lock()
    is_locked = true
end

function M.unlock(load_fn)
    is_locked = false
    local queue = load_queue
    load_queue = {}
    for _, id in ipairs(queue) do
        load_fn(id)
    end
end

function M.load(id, plugins, logger)
    if loaded_plugins[id] then return end
    local plugin = plugins[id]
    if not plugin then
        error("plugin '" .. id .. "' not found, please make sure you did add().")
    end

    if is_locked then
        table.insert(load_queue, id)
        return
    end

    if plugin.status == 'installed' or plugin.status == 'loaded' then
        _load_with_deps_check(id, plugins, logger)
    elseif plugin.status == 'installing' then
        table.insert(plugin.on_installed_callbacks, function()
            _load_with_deps_check(id, plugins, logger)
        end)
    else
        logger:error("Could not load '" .. id .. "' The status is not correct: " .. plugin.status)
    end
end

return M
