local function _process_update_queue(queue, plugins, logger)
    if #queue == 0 then
        return
    end

    local id = table.remove(queue, 1)
    local install_path

    if id == "self" then
        install_path = require("manager.core.path").manager_installed_path
    else
        install_path = require("manager.core.path").plugin_path(id)
    end

    install_path = vim.fn.expand(install_path)

    local stderr_data = {}

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
                    logger:error("Update failed [" .. id .. "]:\n" .. msg)
                else
                    logger:info("Successfuly Updated " .. id)
                end
                _process_update_queue(queue, plugins, logger)
            end)
        end,
    })
end

return function(target_id, plugins, logger)
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
    _process_update_queue(queue, plugins, logger)
end
