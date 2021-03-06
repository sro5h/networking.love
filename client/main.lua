--
-- # client
--
-- Basic networking tests using the [Love2d](http://love2d.org) framework
--
-- **License:** MIT
-- **Source:**  [Github](https://github.com/sro5h/networking.love)
--

-- ## modules
--
local Client = require("client")
local Bitser = require("lib/bitser")

-- ## variables
--
local isDown = love.keyboard.isDown
local client
local player

-- ### update variables
--
local updaterate = 1/32
local lag = 0

-- ## methods
--

-- ### updateMovement
--
-- Sends movement events to the server
--
local function sendUpdate()
    movement = {
        dx = 0,
        dy = 0
    }

    if isDown('a') then
        movement.dx = movement.dx - 1
    end
    if isDown('d') then
        movement.dx = movement.dx + 1
    end
    if isDown('w') then
        movement.dy = movement.dy - 1
    end
    if isDown('s') then
        movement.dy = movement.dy + 1
    end

    client:send("update", movement)
end

-- ## love.load
--
function love.load()
    -- Set window title
    love.window.setTitle("Client")

    client = Client.new()
    client:setSerialization(Bitser.dumps, Bitser.loads)
    client:connect("localhost:22122")
    client:on("tick", function(data)
        player = {
            x = data.x,
            y = data.y,
            size = 15
        }
    end)
    client:on("clientConnect", function(data)
        print("Client connected: " .. data.id)
    end)
    client:on("clientDisconnect", function(data)
        print("Client disconnected: " .. data.id)
    end)
    client:on("init", function(data)
        print("Init received.")
    end)
end

-- ## love.update
--
function love.update(dt)
    lag = lag + dt
    if lag > updaterate then
        -- Update movement
        sendUpdate()

        -- Update client
        client:update()

        lag = lag - updaterate
    end
end

-- ## love.draw
--
function love.draw()
    if player then
        love.graphics.circle("line", player.x, player.y, player.size)
    end
end

-- ## love.quit
function love.quit()
    client:disconnect()
end
