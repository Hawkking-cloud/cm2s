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
    self:allocateBlocks(PREALLOCblocks)
    self:allocateConnections(PREALLOCconnections)

    return self
end

function OPTcm2Lua:allocateBlocks(amt)
    amt = amt or 0
    for i = 1, amt do
        self._blocks[self._blockIndex + i] = false
    end
end

function OPTcm2Lua:allocateConnections(amt)
    amt = amt or 0
    for i = 1, amt do
        self._connections[self._connectionIndex + i] = false
    end
end

function OPTcm2Lua:addBlock(id, x, y, z, meta)
    x = x or 0
    y = y or 0
    z = z or 0
    meta = meta or ""

    local blockIndex = self._blockIndex
    local blockStr = id .. ",0," .. x .. "," .. y .. "," .. z .. ","
    self._blocks[blockIndex] = blockStr
    self._blockIndex = blockIndex + 1
    self._blockHash[blockHash(x, y, z)] = blockIndex
    return blockIndex
end

--TODO: implement block hashing for this
function OPTcm2Lua:addBlockRaw(string)
    local blockIndex = self._blockIndex
    self._blocks[blockIndex] = string
    self._blockIndex = blockIndex + 1
    return blockIndex
end

function OPTcm2Lua:findBlock(x, y, z)
    return self._blockHash[blockHash(x, y, z)] or nil
end

function OPTcm2Lua:addConnection(id1, id2)
    local connectionIndex = self._connectionIndex

    self._connections[connectionIndex] = string.format("%d,%d", id1, id2)
    self._connectionIndex = connectionIndex + 1
end

function OPTcm2Lua:addConnectionRaw(string)
    local connectionIndex = self._connectionIndex
    self._connections[connectionIndex] = string
    self._connectionIndex = connectionIndex + 1
    return connectionIndex
end

function OPTcm2Lua:export()
    local blocksString = table.concat(self._blocks, ";")
    local connectionsString = table.concat(self._connections, ";")
    return blocksString .. "?" .. connectionsString .. "??"
end

return OPTcm2Lua
