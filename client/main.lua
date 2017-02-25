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

    client:send("movement", movement)
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
        -- Get events
        local event = client:service(0)
        while event do
            if event.type == "connect" then
                print(event.peer, " connected.")
                event.peer:send(bitser.dumps({ msg="ping" }))
            elseif event.type == "disconnect" then
                print(event.peer, " disconnected.")
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
    server:disconnect()
    client:flush()
end
