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
            elseif event.type == "disconnect" then
                print(event.peer, " disconnected.")
            elseif event.type == "receive" then
                local data = bitser.loads(event.data)
                print(event.peer, " " .. data.msg)
            end

            event = server:service(0)
        end

        lag = lag - updaterate
    end
end

-- ## love.draw
--
function love.draw()

end
