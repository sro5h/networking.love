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
local players = {}

-- ### update variables
--
local updaterate = 1/32
local lag = 0

-- ## methods
--

-- ### newPlayer
--
-- Returns a new player object.
--
function newPlayer()
    return {
        x = math.random(512),
        y = math.random(512),
        size = 15
    }
end

-- ## love.load
--
function love.load()
    -- Set window title
    love.window.setTitle("Server")

    server = Server.new("localhost:22122")
    server:setSerialization(Bitser.dumps, Bitser.loads)
    server:on("connect", function(client)
        players[1] = newPlayer()
    end)
    server:on("update", function(client, data)
        local i = 1
        players[i].x = players[i].x + data.dx
        players[i].y = players[i].y + data.dy
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
    for _, player in pairs(players) do
        love.graphics.circle("line", player.x, player.y, player.size)
    end
end
