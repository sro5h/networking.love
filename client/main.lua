--
-- # client
-- Basic networking tests using the [Love2d](http://love2d.org) framework
--
-- **License:** MIT
-- **Source:**  [Github](https://github.com/sro5h/networking.love)
--

-- ## modules
--
local sock = require("../lib/sock")
local tick = require("../tick")

local client = {}
-- update variables
local updaterate = 0.5
local lag = 0

-- ## love.load
--
function love.load()
    client = sock.newClient("localhost", 22122)

    -- If the connect/disconnect callbacks aren't defined some warnings will
    -- be thrown, but nothing bad will happen.

    -- Called when a connection is made to the server
    client:on("connect", function(data)
        print("Client connected to the server.")
    end)

    -- Custom callback, called whenever you send the event from the server
    client:on("hello", function(msg)
        print(msg)
    end)

    client:connect()
end

-- ## love.update
--
function love.update(dt)
    lag = lag + dt
    if lag > updaterate then
        client:update()

        -- test tick module
        print(tick.new().id)

        lag = lag - updaterate
    end
end

-- ## love.draw
--
function love.draw()

end
