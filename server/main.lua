--
-- # server
-- Basic networking tests using the [Love2d](http://love2d.org) framework
--
-- **License:** MIT
-- **Source:**  [Github](https://github.com/sro5h/networking.love)
--

-- ## modules
--
local sock = require("../lib/sock")
local tick = require("../tick")

local server = {}
-- update variables
local updaterate = 0.5
local lag = 0

-- ## love.load
--
function love.load()
    server = sock.newServer("localhost", 22122)

    -- If the connect/disconnect callbacks aren't defined some warnings will
    -- be thrown, but nothing bad will happen.

    -- Called when someone connects to the server
    server:on("connect", function(data, peer)
        local msg = "Hello from server!"
        peer:send("hello", msg)
    end)
end

-- ## love.update
--
function love.update(dt)
    lag = lag + dt
    if lag > updaterate then
        server:update()

        -- test tick module
        print(tick.new().id)

        lag = lag - updaterate
    end
end

-- ## love.draw
--
function love.draw()

end
