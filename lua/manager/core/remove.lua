return function(id, plugins)
    local plugin = plugins[id]
    if not plugin then
        vim.notify("Plugin '" .. id .. "' not found.", vim.log.levels.WARN)
        return
    end

    local path = require("manager.core.path").plugin_path(id)
    if vim.fn.isdirectory(path) == 1 then
        local ok, err = pcall(vim.fn.delete, path, 'rf')
        if ok then
            plugin.status = 'new'
            vim.notify("Plugin '" .. id .. "' removed.", vim.log.levels.INFO)
        else
            vim.notify("Failed to remove '" .. id .. "': " .. err, vim.log.levels.ERROR)
        end
    else
        vim.notify("Plugin directory for '" .. id .. "' does not exist.", vim.log.levels.WARN)
    end
end
