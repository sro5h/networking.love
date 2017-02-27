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
local function updateMovement()
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

    server:send(bitser.dumps({
        type = "update",
        data = movement
    }))
end

-- ## love.load
--
function love.load()
    -- Set window title
    love.window.setTitle("Client")

    client = Client.new()
    client:setSerialization(Bitser.dumps, Bitser.loads)
    client:connect("localhost:22122")
end

-- ## love.update
--
function love.update(dt)
    lag = lag + dt
    if lag > updaterate then
        -- Update movement
        --updateMovement()
        client:send("update", { dx = 1, dy = 1 })

        -- Update client
        client:update()

        lag = lag - updaterate
    end
end

-- ## love.draw
--
function love.draw()

end

-- ## love.quit
function love.quit()
    client:disconnect()
end
