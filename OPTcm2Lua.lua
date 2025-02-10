-- this file is still in "beta" and may have errors,
-- dm me or some shit if you find one i can fix

--- OPTcm2Lua: The fullest extent of an optimized cm2Lua
-- @module: OPTcm2Lua

local OPTcm2Lua={}
OPTcm2Lua.__index = OPTcm2Lua

local bit = require('bit')

function  OPTcm2Lua.new(PREALLOCblocks,PREALLOCconnections)
    local self = setmetatable({},OPTcm2Lua)
    self._blocks = {}  
    self._connections = {}
    if PREALLOCblocks then
        for i = 1, PREALLOCblocks do self._blocks[i] = false end  
    end
    if PREALLOCconnections then

        for i = 1, PREALLOCconnections do self._connections[i] = false end  
    end
    self._bid=1
    self._cid=1
    self._blockHash={}
    return self
end
function OPTcm2Lua:allocateBlocks(amt)
    for i=1, amt do self._blocks[self._bid+i] = false end
end
function OPTcm2Lua:allocateConnections(amt)
    for i=1, amt do self._connections[self._cid+i] = false end
end
function OPTcm2Lua:addBlock(id,x,y,z)
    x = x or 0
    y = y or 0
    z = z or 0
    local bid = self._bid  
    local blockStr = id .. ",0," .. x .. "," .. y .. "," .. z .. ","

    self._blocks[bid]=blockStr
    self._bid=bid+1
    self._blockHash[bit.bxor(x * 73856093, y * 19349663, z * 83492791)] = bid 
    return bid
end
--TODO: implement block hashing for this
function OPTcm2Lua:addBlockRaw(string)
    local bid = self._bid
    self._blocks[bid]=string
    self._bid=bid+1
    return bid
end
function OPTcm2Lua:findBlock(x,y,z)
    return self._blockHash[bit.bxor(x * 73856093, y * 19349663, z * 83492791)] or 1
end
function OPTcm2Lua:addConnection(id1,id2)
    local cid = self._cid
    self._connections[cid]=string.format("%d,%d",id1,id2)
    self._cid=cid+1
end
function OPTcm2Lua:addConnectionRaw(string)
    local cid = self._cid
    self._connections[cid]=string
    self._cid=cid+1
    return cid
end
function OPTcm2Lua:export()
    local blocksStr = table.concat(self._blocks, ";")
    local connectionsStr = table.concat(self._connections, ";")
    return blocksStr .. (connectionsStr ~= "" and "?" .. connectionsStr or "") .. "??"
end

return OPTcm2Lua
