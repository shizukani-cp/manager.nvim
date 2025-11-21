return function(plugins)
    local installed_dirs = vim.fn.globpath(require("manager.core.path").install_base_path, '*', true, true)
    local removed_plugins = {}

    if #installed_dirs == 0 then
        return
    end

    for _, path in ipairs(installed_dirs) do
        if vim.fn.isdirectory(path) == 1 then
            local id = vim.fn.fnamemodify(path, ':t')

            if not plugins[id] then
                local ok, err = pcall(vim.fn.delete, path, 'rf')
                if ok then
                    table.insert(removed_plugins, id)
                else
                    vim.notify("Failed to remove '" .. id .. "': " .. err, vim.log.levels.ERROR)
                end
            end
        end
    end
end
