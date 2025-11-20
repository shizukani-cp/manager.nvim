local function _process_update_queue(queue, plugins, install_base_path)
    if #queue == 0 then
        return
    end
    local id = table.remove(queue, 1)
    local plugin = plugins[id]
    local install_path = vim.fs.joinpath(install_base_path, id)
    if plugin.status ~= 'installed' then
        _process_update_queue(queue)
        return
    end
    vim.fn.jobstart({ 'git', '-C', install_path, 'pull' }, {
        on_exit = function(_, code)
            vim.schedule(function()
                if code ~= 0 then
                    vim.notify("'" .. id .. "' update failed.", vim.log.levels.ERROR)
                end
                _process_update_queue(queue)
            end)
        end,
    })
end

return function(target_id, plugins, install_base_path)
    local queue = {}

    if target_id then
        if plugins[target_id] then
            table.insert(queue, target_id)
        else
            return
        end
    else
        for id, _ in pairs(plugins) do
            table.insert(queue, id)
        end

        if #queue == 0 then
            return
        end
    end

    _process_update_queue(queue, plugins, install_base_path)
end
