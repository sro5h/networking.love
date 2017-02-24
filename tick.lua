--
-- # tick module
--

local tick = {}

tick.count = 0

function tick.new()
    local _tick = {}

    _tick.id = tick.count

    -- Increment the count
    tick.count = tick.count + 1

    return _tick
end

return tick
