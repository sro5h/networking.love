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
local sock = require("../lib/sock")
local tick = require("../tick")

-- ## variables
--
local isDown = love.keyboard.isDown
local client = {}

-- ### update variables
--
local updaterate = 1/16
local lag = 0

-- ## callbacks
--

-- ### onConnect
--
-- Called if the connection to the server is established
--
-- 'data' is null
--
local function onConnect(data)
    print("Connected to the server." .. data)
end

-- ### onPing
--
-- Called if the server sends a ping event
--
-- 'msg' is a string
--
local function onPing(msg)
    print(msg)
end

-- ## love.load
--
function love.load()
    client = sock.newClient("localhost", 22122)

    -- Wire up callbacks
    client:on("connect", onConnect)
    client:on("ping", onPing)

    client:connect()
end

-- ## love.update
--
function love.update(dt)
    lag = lag + dt
    if lag > updaterate then
        if isDown('a') then
            client:send("movement", {
                dx = -1,
                dy = 0
            })
        end

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
    client:disconnectNow(client:getIndex())
end
