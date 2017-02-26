--
-- # server
--
-- A server implementation using lua-enet.
--

-- ## modules
--
local enet = require("enet")
local util = require("../util")

-- ## server
--
local server = {}

-- ## helpers
--

-- ### tablelength
--
-- Return the length of a table by iterating over 't' and counting each item.
--
-- 't' is a table
--
function tablelength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

-- ## module methods
--

-- ### newId
--
-- Returns a unique id.
--
local function _newId(self)
    local id = self.nextId
    self.nextId = self.nextId + 1
    return id
end

-- ### onConnect
--
-- Gets called when a peer connects.
--
-- 'peer' is the peer
--
local function onConnect(self, peer)
    local id = self:_newId()
    local address = tostring(peer)

    -- Add a client id
    self.ids[address] = id
    print(address .. " [id = " .. id .. "]" .. " connected.")

    -- Remove later
    print("LOG: " .. "id count: " .. tablelength(self.ids))
end

-- ### onDisconnect
--
-- Gets called when a peer disconnects.
--
-- 'peer' is the peer
-- 'id'   is a number
--
local function onDisconnect(self, peer)
    local address = tostring(peer)
    local id = self.ids[address]

    -- Remove the client id
    self.ids[address] = nil
    print(address .. " [id = " .. id .. "]" .. " disconnected.")

    -- Remove later
    print("LOG: " .. "id count: " .. tablelength(self.ids))
end

-- ### on
--
-- Sets a callback for an event.
--
-- 'event'    is a string
-- 'callback' is callable
--
local function on(self, event, callback)
    assert(util.isCallable(callback))
    self.callbacks[event] = callback
end

-- ### update
--
-- Processes the incoming packages and calls the related callbacks.
--
-- 'timeout' is a number
--
local function update(self, timeout)
    timeout = timeout or 0
    local event = self.host:service(timeout)
    while event do
        if event.type == "connect" then
            self:onConnect(event.peer)
        elseif event.type == "disconnect" then
            self:onDisconnect(event.peer, event.data)
        elseif event.type == "receive" then
            -- Deserialize the package
            local package = self._deserialize(event.data)
            -- Check if package is valid
            if type(package.type) == "string" then
                if self.callbacks[package.type] then
                    -- Call the callback of the event if not nil
                    self.callbacks[package.type](event.peer, package.data)
                end
            else
                -- Package has not the assumed structure
                print("Invalid package received.")
                util.printTable(package)
            end
        end

        event = self.host:service()
    end
end

-- ### setSerialization
--
-- Sets the (de)serialization methods to use before sending and after
-- receiving data.
--
-- 'serialize' is a function
-- 'deserialize' is a function
--
local function setSerialization(self, serialize, deserialize)
    self._serialize = serialize
    self._deserialize = deserialize
end

-- ### server.new
--
-- Returns a new server instance
--
-- 'address' is a string
--
function server.new(address)
    local _server = {}

    _server.host = enet.host_create(address)
    _server.ids = {}
    _server.nextId = 1
    _server.callbacks = {}

    _server._newId = _newId
    _server._serialize = nil
    _server._deserialize = nil

    _server.update = update
    _server.on = on
    _server.onConnect = onConnect
    _server.onDisconnect = onDisconnect
    _server.setSerialization = setSerialization

    return _server
end

return server
