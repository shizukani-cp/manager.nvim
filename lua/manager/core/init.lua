local M = {}

M.plugins = {}

M.logger = require("manager.core.logger").new()

M.add = function(spec)
    require("manager.core.add")(spec, M.plugins, M.logger)
end

M.clean = function()
    require("manager.core.clean")(M.plugins, M.logger)
end

M.load = function(id)
    require("manager.core.load").load(id, M.plugins, M.logger)
end

M.lock = function()
    require("manager.core.load").lock()
end

M.remove = function(id)
    require("manager.core.remove")(id, M.plugins, M.logger)
end

M.unlock = function()
    require("manager.core.load").unlock(M.load, M.logger)
end

M.update = function(id)
    require("manager.core.update")(id, M.plugins, M.logger)
end

return M
