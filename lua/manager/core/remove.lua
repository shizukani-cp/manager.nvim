---@param id string
return function(self, id)
    local plugin = self.plugins[id]
    if not plugin then
        self.logger:warn("Plugin '" .. id .. "' not found.")
        return
    end

    local path = self:plugin_path(id)
    if vim.fn.isdirectory(path) == 1 then
        local ok, err = pcall(vim.fn.delete, path, "rf")
        if ok then
            plugin.status = "new"
            self.logger:info("Plugin '" .. id .. "' removed.")
        else
            self.logger:error("Failed to remove '" .. id .. "': " .. err)
        end
    else
        self.logger:warn("Plugin directory for '" .. id .. "' does not exist.")
    end
end
