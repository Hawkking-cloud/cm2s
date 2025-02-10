package.path="?.lua" -- THIS IS ENVIRONMENT SPECIFIC AND REQUIRES CHANGING BASED ON YOUR HEIRACHY
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
function cm2s:add(structure)
    masterSave:allocateBlocks(structure._bid-2)
    masterSave:allocateConnections(structure._cid-2)
    for i=1,structure._bid-1 do
        masterSave:addBlockRaw(structure._blocks[i])
    end
    for i=1,structure._cid-1 do
        local id1, id2 = structure._connections[i]:match("^(.-)%s*,%s*(.-)$")
        masterSave:addConnectionRaw(tostring(id1+masterBID-1)..','..tostring(id2+masterBID-1))
    end
    masterBID=masterBID+structure._bid-1
end
function cm2s:retrieve()
    return masterSave
end

return cm2s
