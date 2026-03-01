local uv = vim.uv or vim.loop

---@param spec manager.Spec
return function(self, spec)
    if not spec.id or not spec.url then
        error("Plugin must have 'id' and 'url'. spec: " .. vim.inspect(spec))
    end
    if self.plugins[spec.id] then
        return
    end
    local install_path = self:plugin_path(spec.id)
    local is_ok = (function()
        if vim.fn.isdirectory(install_path) == 1 then
            local stat = uv.fs_lstat(install_path)
            local current_type = stat and stat.type
            if current_type == "link" and spec.dev then
                return true
            elseif current_type == "directory" and not spec.dev then
                return true
            else
                return false
            end
        end
        return false
    end)()
    self.plugins[spec.id] = {
        spec = spec,
        status = is_ok and "installed" or "new",
        on_installed_callbacks = {},
    }
    if not is_ok then
        local plugin = self.plugins[spec.id]
        plugin.status = "installing"

        if vim.fn.isdirectory(install_path) == 1 or uv.fs_lstat(install_path) then
            vim.fn.delete(install_path, "rf")
        end

        if plugin.spec.dev then
            local src = vim.fn.expand(plugin.spec.dir)

            if uv.fs_lstat(install_path) then
                uv.fs_unlink(install_path)
            end

            local success, err = uv.fs_symlink(src, install_path, { dir = true, junction = true })

            if success then
                plugin.status = "installed"
                vim.cmd("packloadall!")
                self.logger:info("Linked " .. spec.id .. " from " .. src)
                for _, callback in ipairs(plugin.on_installed_callbacks) do
                    callback()
                end
                plugin.on_installed_callbacks = {}
            else
                plugin.status = "failed"
                self.logger:error("Failed to link " .. spec.id .. ": " .. tostring(err))
            end
            return
        end
        local args = { "git", "clone", "--depth", "1" }
        if spec.branch then
            table.insert(args, "-b")
            table.insert(args, spec.branch)
        end
        table.insert(args, spec.url)
        table.insert(args, install_path)

        vim.fn.jobstart(args, {
            on_exit = function(_, code)
                vim.schedule(function()
                    if code == 0 then
                        plugin.status = "installed"
                        vim.cmd("packloadall!")
                        self.logger:info("Successfuly installed " .. spec.id)
                        for _, callback in ipairs(plugin.on_installed_callbacks) do
                            callback()
                        end
                        plugin.on_installed_callbacks = {}
                    else
                        plugin.status = "failed"
                        self.logger:error("'" .. spec.id .. "' installation failed.")
                    end
                end)
            end,
        })
    end
end
