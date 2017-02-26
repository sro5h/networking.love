--
-- # server
-- Basic networking tests using the [Love2d](http://love2d.org) framework
--
-- **License:** MIT
-- **Source:**  [Github](https://github.com/sro5h/networking.love)
--

-- ## modules
--
local Bitser = require("lib/bitser")
local Server = require("server")
local Util = require("../util")

-- ## variables
--
local server = {}

-- ### update variables
--
local updaterate = 1/32
local lag = 0

-- ## love.load
--
function love.load()
    -- Set window title
    love.window.setTitle("Server")

    server = Server.new("localhost:22122")
    server:setSerialization(Bitser.dumps, Bitser.loads)
    server:on("test", function(client, data)
        print("Test received: " .. data)
    end)
end

-- ## love.update
--
function love.update(dt)
    lag = lag + dt
    if lag > updaterate then
        -- Update server
        server:update()

        lag = lag - updaterate
    end
end

-- ## love.draw
--
function love.draw()

end
