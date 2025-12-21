local Logger = {}
Logger.__index = Logger
local levels = vim.log.levels

function Logger.new(options)
    local self = setmetatable({}, Logger)
    self.entries = {}
    self.max_entries = (options and options.max_entries) or 1000
    self.handlers = {}
    self._next_id = 1
    return self
end

function Logger:on(callback)
    local id = self._next_id
    self.handlers[id] = callback
    self._next_id = self._next_id + 1

    return function() self:off(id) end
end

function Logger:off(id)
    self.handlers[id] = nil
end

function Logger:log(level, msg)
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

function Logger:get_logs(level_filter)
    if not level_filter then return self.entries end
    return vim.tbl_filter(function(e)
        return e.level >= level_filter
    end, self.entries)
end

function Logger:debug(m) self:log(levels.DEBUG, m) end

function Logger:info(m) self:log(levels.INFO, m) end

function Logger:warn(m) self:log(levels.WARN, m) end

function Logger:error(m) self:log(levels.ERROR, m) end

return Logger
