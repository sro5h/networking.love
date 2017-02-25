--
-- # server
-- Basic networking tests using the [Love2d](http://love2d.org) framework
--
-- **License:** MIT
-- **Source:**  [Github](https://github.com/sro5h/networking.love)
--

-- ## modules
--
local enet = require("enet")
local bitser = require("lib/bitser")
local tick = require("../tick")
local util = require("../util")

-- ## variables
--
local server = {}
local players = {}

-- ### update variables
--
local updaterate = 1/32
local lag = 0

-- ### methods
--

-- ### newPlayer
--
-- Returns a new player
--
local function newPlayer()
    return {
        x = math.random(512),
        y = math.random(512),
        size = 20
    }
end

-- ## love.load
--
function love.load()
    -- Set window title
    love.window.setTitle("Server")

    server = enet.host_create("localhost:22122")
end

-- ## love.update
--
function love.update(dt)
    lag = lag + dt
    if lag > updaterate then
        -- Get events
        local event = server:service(0)
        while event do
            if event.type == "connect" then
                print(event.peer, " connected.")
                players[event.peer] = newPlayer()

            elseif event.type == "disconnect" then
                print(event.peer, "[" .. event.data .. "]" .. " disconnected.")
                players[event.peer] = nil

            elseif event.type == "receive" then
                local package = bitser.loads(event.data)
                if package.type == "movement" then
                    players[event.peer].x = players[event.peer].x + package.data.dx
                    players[event.peer].y = players[event.peer].y + package.data.dy
                end
            end

            event = server:service(0)
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
