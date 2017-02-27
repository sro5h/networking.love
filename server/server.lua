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
    local address = tostring(peer) -- better use the index
    local index = peer:index()

    -- Add a client id
    self.ids[index] = id
    print(address .. " [id = " .. id .. "]" .. " connected.")
    print("Peer index: " .. peer:index())

    -- Call connect callback
    if self.callbacks["connect"] then
        self.callbacks["connect"](peer, nil)
    end

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
local function onDisconnect(self, peer, data)
    local address = tostring(peer)
    local index = peer:index()
    local id = self.ids[index]

    -- Remove the client id
    self.ids[index] = nil
    print(address .. " [id = " .. id .. "]" .. " disconnected.")
    print("Peer index: " .. index)

    -- Call disconnect callback
    if self.callbacks["disconnect"] then
        self.callbacks["disconnect"](peer, data)
    end

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
-- Processes the incoming packets and calls the related callbacks.
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
            -- Deserialize the packet
            local packet = self._deserialize(event.data)
            -- Check if packet is valid
            if type(packet.type) == "string" then
                if self.callbacks[packet.type] then
                    -- Call the callback of the event if not nil
                    self.callbacks[packet.type](event.peer, packet.data)
                end
            else
                -- Package has not the assumed structure
                print("Invalid packet received.")
                util.printTable(packet)
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
