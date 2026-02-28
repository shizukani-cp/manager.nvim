---@class manager.core.Logger.Entry
---@field level number -- vim.log.levels
---@field msg string
---@field time number

---@class manager.core.Logger
---@field entries manager.core.Logger.Entry[]
---@field max_entries number
---@field handlers table<number, fun(entry: manager.core.Logger.Entry)>
---@field _next_id number
local Logger = {}
Logger.__index = Logger
local levels = vim.log.levels

---@param options? { max_entries?: number }
---@return manager.core.Logger
function Logger.new(options)
    local self = setmetatable({}, Logger)
    self.entries = {}
    self.max_entries = (options and options.max_entries) or 1000
    self.handlers = {}
    self._next_id = 1
    return self
end

---@param callback fun(entry: manager.core.Logger.Entry)
---@return fun()
function Logger:on(callback)
    local id = self._next_id
    self.handlers[id] = callback
    self._next_id = self._next_id + 1

    return function()
        self:off(id)
    end
end

---@param id number
function Logger:off(id)
    self.handlers[id] = nil
end

---@param level "DEBUG"|"INFO"|"WARN"|"ERROR"
---@param msg string
function Logger:log(level, msg)
    ---@type manager.core.Logger.Entry
    local entry = {
        level = level,
        msg = msg,
        time = os.time(),
    }

    table.insert(self.entries, entry)
    if #self.entries > self.max_entries then
        table.remove(self.entries, 1)
    end

    for _, handler in pairs(self.handlers) do
        vim.schedule(function()
            handler(entry)
        end)
    end
end

---@param level_filter? "DEBUG"|"INFO"|"WARN"|"ERROR"
---@return manager.core.Logger.Entry[]
function Logger:get_logs(level_filter)
    if not level_filter then
        return self.entries
    end
    return vim.tbl_filter(function(e)
        return e.level >= level_filter
    end, self.entries)
end

---@param m string
function Logger:debug(m)
    self:log(levels.DEBUG, m)
end

---@param m string
function Logger:info(m)
    self:log(levels.INFO, m)
end

---@param m string
function Logger:warn(m)
    self:log(levels.WARN, m)
end

---@param m string
function Logger:error(m)
    self:log(levels.ERROR, m)
end

return Logger
