return function(id, plugins, logger)
    local plugin = plugins[id]
    if not plugin then
        logger:warn("Plugin '" .. id .. "' not found.")
        return
    end

    local path = require("manager.core.path").plugin_path(id)
    if vim.fn.isdirectory(path) == 1 then
        local ok, err = pcall(vim.fn.delete, path, 'rf')
        if ok then
            plugin.status = 'new'
            logger:info("Plugin '" .. id .. "' removed.")
        else
            logger:error("Failed to remove '" .. id .. "': " .. err)
        end
    else
        logger:warn("Plugin directory for '" .. id .. "' does not exist.")
    end
end
