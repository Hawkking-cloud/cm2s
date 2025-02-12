--- OPTcm2Lua: The fullest extent of an optimized cm2Lua
-- @module: OPTcm2Lua

local OPTcm2Lua = {}
OPTcm2Lua.__index = OPTcm2Lua

local bit = require("bit")
local function blockHash(x, y, z)
  return bit.bxor(x * 73856093, y * 19349663, z * 83492791)
end

function OPTcm2Lua.new(PREALLOCblocks, PREALLOCconnections)
    local self = setmetatable({}, OPTcm2Lua)
    self._blocks = {}
    self._connections = {}
    self._blockHash = {}
    self._blockIndex = 1
    self._connectionIndex = 1
    self.allocateBlocks(PREALLOCblocks)
    self.allocateConnections(PREALLOCconnections)

    return self
end

function OPTcm2Lua:allocateBlocks(amount)
    amount = amount + self._blockIndex
    for i = self._blockIndex, amount do
        self._blocks[i] = false
    end
end

function OPTcm2Lua:allocateConnections(amount)
    amount = amount + self._connectionIndex
    for i = self._connectionIndex, amount do
        self._connections[i] = false
    end
end

function OPTcm2Lua:addBlock(id, x, y, z, meta)
    x = x or 0
    y = y or 0
    z = z or 0
    meta = meta or ""

    local blockStr = id .. ",0," .. x .. "," .. y .. "," .. z .. ","
    self._blocks[self._blockIndex] = blockStr
    self._blockIndex = self._blockIndex + 1
    self._blockHash[blockHash(x, y, z)] = self._blockIndex
end

-- TODO: implement block hashing for this
function OPTcm2Lua:addBlockRaw(string)
    self._blocks[self._blockIndex] = string
    self._blockIndex = self._blockIndex + 1
end

function OPTcm2Lua:findBlock(x, y, z)
    return self._blockHash[blockHash(x, y, z)] or 1
end

function OPTcm2Lua:addConnection(id1, id2)
    self._connections[self._connectionIndex] = string.format("%d,%d", id1, id2)
    self._connectionIndex = self._connectionIndex + 1
end

function OPTcm2Lua:addConnectionRaw(string)
    self._connections[self._connectionIndex] = string
    self._connectionIndex = self._connectionIndex + 1
end

function OPTcm2Lua:export()
    local blocksString = table.concat(self._blocks, ";")
    local connectionsString = table.concat(self._connections, ";")
    return blocksString .. (connectionsString ~= "" and "?" .. connectionsString or "") .. "??"
end

return OPTcm2Lua
