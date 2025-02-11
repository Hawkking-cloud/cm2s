
local cm2Lua=require("OPTcm2Lua")
local cm2s = {}
-- this is probably just gonna be a wrapper that takes all the circuits and merges them into one 
local zI=0
local masterSave=cm2Lua.new(0,0)
function cm2s:initStruct(structure)
    structure.STRUCTZ=zI
    zI=zI+1
    return structure
end
local masterBID=1 -- keeps track of the stacked block ids 
local structureOrigins={}
function cm2s:add(structure)
    masterSave:allocateBlocks(structure._bid-2)
    masterSave:allocateConnections(structure._cid-2)
    structureOrigins[structure._hash]=masterSave._bid
    for i=1,structure._bid-1 do
        masterSave:addBlockRaw(structure._blocks[i])
    end
    for i=1,structure._cid-1 do
        local id1, id2 = structure._connections[i]:match("^(.-)%s*,%s*(.-)$")
        masterSave:addConnectionRaw(tostring(id1+masterBID-1)..','..tostring(id2+masterBID-1))
    end
    masterBID=masterBID+structure._bid-1
    function structure:getInput(name)
        if self._inputs[name]==nil then error("{cm2s.lua} Error: no input manifest found with name "..name) end
        return self._inputs[name]
    end
    function structure:getOutput(name)
        if self._outputs[name]==nil then error("{cm2s.lua} Error: no output manifest found with name "..name) end
        return self._outputs[name]
    end
    return structure
end
function cm2s:connect(inp,out)
    if #inp~=#out then error("{cm2s.lua} Error: input and output bits arent the same") end
    for i=1,#inp do
        local inpOrigin=structureOrigins[inp._hash]
        local outOrigin=structureOrigins[out._hash]
        
        masterSave:addConnection(tostring(tonumber(inp[i]+inpOrigin-1)),tostring(tonumber(out[i]+outOrigin-1)))
    end
end
function cm2s:retrieve()
    return masterSave
end

return cm2s 
