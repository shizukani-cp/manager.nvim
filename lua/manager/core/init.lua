local M = {}

M.plugins = {}

M.add = function(spec)
    require("manager.core.add")(spec, M.plugins)
end

M.clean = function()
    require("manager.core.clean")(M.plugins)
end

M.load = function(id)
    require("manager.core.load").load(id, M.plugins)
end

M.lock = function()
    require("manager.core.load").lock()
end

M.remove = function(id)
    require("manager.core.remove")(id, M.plugins)
end

M.unlock = function()
    require("manager.core.load").unlock(M.load)
end

M.update = function(id)
    require("manager.core.update")(id, M.plugins)
end

return M
