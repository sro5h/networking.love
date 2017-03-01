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
    server:on("connect", function(clientId)
        players[clientId] = newPlayer()
    end)
    server:on("disconnect", function(clientId)
        players[clientId] = nil
    end)
    server:on("update", function(clientId, data)
        local i = clientId
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
        if players[1] then
            server:sendToAll("tick", { x = players[1].x, y = players[1].y })
        end

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
