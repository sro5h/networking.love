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
local enet = require("enet")
local bitser = require("lib/bitser")
local tick = require("../tick")

-- ## variables
--
local isDown = love.keyboard.isDown
local client
local clientId
local server

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
        type = "movement",
        data = movement
    }))
end

-- ## love.load
--
function love.load()
    -- Set window title
    love.window.setTitle("Client")

    client = enet.host_create()
    server = client:connect("localhost:22122")
end

-- ## love.update
--
function love.update(dt)
    lag = lag + dt
    if lag > updaterate then
        -- Update movement
        updateMovement()

        -- Get events
        local event = client:service(0)
        while event do
            if event.type == "connect" then
                print("Connected to server.")

            elseif event.type == "disconnect" then
                print(event.peer, " disconnected.")

            elseif event.type == "receive" then
                local package = bitser.loads(event.data)
                if package.type == "id" then
                    print("Received id [" .. package.data .. "].")
                    clientId = package.data
                end
            end

            event = client:service(0)
        end

        lag = lag - updaterate
    end
end

-- ## love.draw
--
function love.draw()

end

-- ## love.quit
function love.quit()
    if clientId then
        server:disconnect(clientId)
        client:flush()
    end
end
