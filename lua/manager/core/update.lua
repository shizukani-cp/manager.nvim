local function _process_update_queue(queue, plugins)
    if #queue == 0 then
        return
    end

    local id = table.remove(queue, 1)
    local stderr_data = {}

    if id == "self" then
        local install_path = vim.fn.expand(require("manager.core.path").manager_installed_path)
        vim.fn.jobstart({ 'git', '-C', install_path, 'pull', '--ff-only' }, {
            on_stderr = function(_, data)
                for _, line in ipairs(data) do
                    if line ~= "" then table.insert(stderr_data, line) end
                end
            end,
            on_exit = function(_, code)
                vim.schedule(function()
                    if code ~= 0 and #stderr_data > 0 then
                        vim.notify("manager ('self') update failed:\n" .. table.concat(stderr_data, "\n"),
                            vim.log.levels.ERROR)
                    end
                    _process_update_queue(queue, plugins)
                end)
            end,
        })
        return
    end

    local install_path = vim.fn.expand(require("manager.core.path").plugin_path(id))

    vim.fn.jobstart({ 'git', '-C', install_path, 'pull', '--ff-only' }, {
        on_stderr = function(_, data)
            for _, line in ipairs(data) do
                if line ~= "" then table.insert(stderr_data, line) end
            end
        end,
        on_exit = function(_, code)
            vim.schedule(function()
                if code ~= 0 and #stderr_data > 0 then
                    local msg = table.concat(stderr_data, "\n")
                    vim.notify("'" .. id .. "' update failed:\n" .. msg, vim.log.levels.ERROR)
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
