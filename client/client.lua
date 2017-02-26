--
-- # client
--
-- A client implementation using lua-enet
--

-- ## modules
--
local enet = require("enet")

-- ## client
--
local client = {}

local function connect(self, address)
    self.server = self.host:connect(address)
    print("Connecting to " .. address .. ".")
end

-- ### disconnect
--
-- Attempts to immediately disconnect the client from its server
--
local function disconnect(self)
    if self.server then
        self.server:disconnect()
        self.host:flush()

        print("Disconnecting from server.")
    end
end

-- ### onConnect
--
-- Gets called when this client connects to its server.
--
-- 'peer' is the server
--
local function onConnect(self, peer)
    print("Connected to ", peer, ".")
end

-- ### onDisconnect
--
-- Gets called when this client disconnects from its server.
--
-- 'peer' is the server
-- 'data' is a number
--
local function onDisconnect(self, peer, data)
    print("Disconnected from " .. tostring(peer) .. ".")
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
            local package = self._deserialize(event.data)
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

-- ### client.new
--
-- Returns a new client instance
--
function client.new()
    _client = {}

    _client.host = enet.host_create()
    _client.server = {}
    _client.id = nil

    _client._serialize = nil
    _client._deserialize = nil

    _client.connect = connect
    _client.disconnect = disconnect
    _client.update = update
    _client.onConnect = onConnect
    _client.onDisconnect = onDisconnect
    _client.onIdReceived = onIdReceived
    _client.setSerialization = setSerialization

    return _client
end

return client
