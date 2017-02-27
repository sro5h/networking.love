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

-- ### _newId
--
-- Returns a unique id.
--
local function _newId(self)
    local id = self.nextId
    self.nextId = self.nextId + 1
    return id
end

-- ### _call
--
-- Calls the callback related to 'event'.
--
-- 'event' is a string
-- 'peer'  is a peer
-- 'data'  is the packet data
--
local function _call(self, event, peer, data)
    local clientId = self.ids[peer:index()]
    -- Assume a valid client id
    assert(clientId)

    -- Call the callback if not nil
    if self.callbacks[event] then
        self.callbacks[event](clientId, data)
    end
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
    self:_call("connect", peer, nil)

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

    -- Call disconnect callback
    self:_call("disconnect", peer, data)

    -- Remove the client id
    self.ids[index] = nil
    print(address .. " [id = " .. id .. "]" .. " disconnected.")
    print("Peer index: " .. index)


    -- Remove later
    print("LOG: " .. "id count: " .. tablelength(self.ids))
end

-- ### onReceive
--
-- Gets called when a peer sends a packet.
--
-- 'peer' is the peer
-- 'data' is the packet
--
local function onReceive(self, peer, data)
    -- Deserialize the packet
    local packet = self._deserialize(data)
    -- Check if packet is valid
    if type(packet.type) == "string" then
        if self.callbacks[packet.type] then
            -- Call the callback of the event
            self:_call(packet.type, peer, packet.data)
        end
    else
        -- Package is not valid
        print("Invalid packet received.")
        util.printTable(packet)
    end
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
            self:onReceive(event.peer, event.data)
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
    _server._call = _call
    _server._serialize = nil
    _server._deserialize = nil

    _server.update = update
    _server.on = on
    _server.onConnect = onConnect
    _server.onDisconnect = onDisconnect
    _server.onReceive = onReceive
    _server.setSerialization = setSerialization

    return _server
end

return server
