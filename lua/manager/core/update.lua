local function _process_update_queue(queue, plugins)
    if #queue == 0 then
        return
    end

    local id = table.remove(queue, 1)

    if id == "self" then
        vim.fn.jobstart({ 'git', '-C', require("manager.core.path").manager_installed_path, 'pull' }, {
            on_exit = function(_, code)
                vim.schedule(function()
                    if code ~= 0 then
                        vim.notify("manager ('self') update failed.", vim.log.levels.ERROR)
                    end
                    _process_update_queue(queue, plugins)
                end)
            end,
        })
        return
    end

    local plugin = plugins[id]
    local install_path = require("manager.core.path").plugin_path(id)

    if not plugin or plugin.status ~= 'installed' then
        _process_update_queue(queue, plugins)
        return
    end

    vim.fn.jobstart({ 'git', '-C', install_path, 'pull' }, {
        on_exit = function(_, code)
            vim.schedule(function()
                if code ~= 0 then
                    vim.notify("'" .. id .. "' update failed.", vim.log.levels.ERROR)
                end
                _process_update_queue(queue, plugins)
            end)
        end,
    })
end

return function(target_id, plugins)
    local queue = {}

    if target_id then
        table.insert(queue, target_id)
    else
        for id, _ in pairs(plugins) do
            table.insert(queue, id)
        end
    end

    if #queue == 0 then
        return
    end

    _process_update_queue(queue, plugins)
end
