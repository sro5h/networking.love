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
        size = 10
    }
end

-- ## callbacks
--

-- ### onConnect
--
-- Called if a client connects
--
-- 'data'
-- 'client' is the client
--
local function onConnect(data, client)
    print("Client " .. client:getIndex() .. " connected.")
    local msg = "Ping."
    client:send("ping", msg)

    table.insert(players, client:getIndex(), newPlayer())
end

-- ### onDisconnect
--
-- Called if a client disconnects
--
-- 'data'
-- 'client' is the client
--
local function onDisconnect(data, client)
        print("Client " .. client:getIndex() .. " disconnected.")

        table.remove(players, client:getIndex())
end

-- ### onMovement
--
-- Called if a client moves
--
-- 'data'   is a table
-- 'client' is the client
--
local function onMovement(data, client)
    print("Client " .. client:getIndex() .. " moves (" .. data.dx .. ", " .. data.dy .. ").")
    players[client:getIndex()].x = players[client:getIndex()].x + data.dx
    players[client:getIndex()].y = players[client:getIndex()].y + data.dy
end

-- ## love.load
--
function love.load()
    server = sock.newServer("localhost", 22122)

    -- Wire up callbacks
    server:on("connect", onConnect)
    server:on("disconnect", onDisconnect)
    server:on("movement", onMovement)
end

-- ## love.update
--
function love.update(dt)
    lag = lag + dt
    if lag > updaterate then
        server:update()

        lag = lag - updaterate
    end
end

-- ## love.draw
--
function love.draw()
    for _, player in pairs(players) do
        love.graphics.circle("fill", player.x, player.y, player.size)
    end
end
