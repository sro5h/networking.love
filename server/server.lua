local enet = require("enet")

local server = {}

local function onConnect(self, peer)
    print(peer, " connected.")
end

local function update(self, timeout)
    timeout = timeout or 0
    local event = self.host:service(timeout)
    while event do
        if event.type == "connect" then
            self:onConnect(event.peer)
        end

        event = self.host:service()
    end
end

function server.new(address)
    local _server = {}

    _server.host = enet.host_create(address)

    _server.update = update
    _server.onConnect = onConnect

    return _server
end

return server
