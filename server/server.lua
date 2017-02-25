--
-- # server
--
-- A server implementation using lua-enet.
--

-- ## modules
--
local enet = require("enet")

-- ## server
--
local server = {}

-- ## helpers
--

-- ### tablefind
--
-- Find a 'value' in the table 't' and return its index.
--
-- 't'     is a table
-- 'value' is the value
--
local function tablefind(t, value)
    for index, val in pairs(t) do
        if val == value then
            return index
        end
    end
end

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
    self.ids[peer:connect_id()] = id
    print(peer,"[id = " .. id .. "]" .. " connected.")

    -- Send id to peer
    peer:send(self._serialize({
        type = "id",
        data = id
    }))

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
local function onDisconnect(self, peer, id)
    local index = tablefind(self.ids, id)
    if index then
        self.ids[tablefind(self.ids, id)] = nil
        print(peer, "[id = " .. id .. "]" .. " disconnected.")
    else
        print(peer, "[id = " .. id .. " (not found)]" .. " disconnected.")
    end

    -- Remove later
    print("LOG: " .. "id count: " .. tablelength(self.ids))
end

-- ### update
--
-- Processes the incomming packages and calls the related callbacks.
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

    _server._newId = _newId
    _server._serialize = nil
    _server._deserialize = nil

    _server.update = update
    _server.onConnect = onConnect
    _server.onDisconnect = onDisconnect
    _server.setSerialization = setSerialization

    return _server
end

return server
