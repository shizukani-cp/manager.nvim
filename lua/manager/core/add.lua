return function(spec, plugins)
    if not spec.id or not spec.url then
        error("Plugin must have 'id' and 'url'. spec: " .. vim.inspect(spec))
    end
    if plugins[spec.id] then return end
    local install_path = require("manager.core.path").plugin_path(spec.id)
    local is_installed = vim.fn.isdirectory(install_path) == 1
    plugins[spec.id] = {
        spec = spec,
        status = is_installed and 'installed' or 'new',
        on_installed_callbacks = {},
    }
    if not is_installed then
        local plugin = plugins[spec.id]
        plugin.status = 'installing'
        local args = { 'git', 'clone', '--depth', '1' }
        if spec.branch then
            table.insert(args, '-b')
            table.insert(args, spec.branch)
        end
        table.insert(args, spec.url)
        table.insert(args, install_path)

        vim.fn.jobstart(args, {
            on_exit = function(_, code)
                vim.schedule(function()
                    if code == 0 then
                        plugin.status = 'installed'
                        vim.cmd('packloadall!')
                        for _, callback in ipairs(plugin.on_installed_callbacks) do
                            callback()
                        end
                        plugin.on_installed_callbacks = {}
                    else
                        plugin.status = 'failed'
                        vim.notify("'" .. spec.id .. "' installation failed.", vim.log.levels.ERROR)
                    end
                end)
            end,
        })
    end
end
