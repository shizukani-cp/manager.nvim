return function(self)
    local installed_dirs = vim.fn.globpath(self.install_base_path, "*", true, true)
    local removed_plugins = {}

    if #installed_dirs == 0 then
        return
    end

    for _, path in ipairs(installed_dirs) do
        if vim.fn.isdirectory(path) == 1 then
            local id = vim.fn.fnamemodify(path, ":t")

            if not self.plugins[id] then
                local ok, err = pcall(vim.fn.delete, path, "rf")
                if ok then
                    table.insert(removed_plugins, id)
                else
                    self.logger:error("Failed to remove '" .. id .. "': " .. err)
                end
            end
        end
    end
    self.logger:info("Successfully cleared untracked plugins.")
end
