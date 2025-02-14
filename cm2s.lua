local cm2Lua = require("OPTcm2Lua")

local cm2s = {}

-- this is probably just gonna be a wrapper that takes all the circuits and merges them into one

local zI = 0 --this increments and tells the structure what zindex to use

local masterSave = cm2Lua.new(0, 0) --save that is written to when structures are added, this file mainly just wraps all the structures together

function cm2s:initStruct(structure)
    structure._structureZ = zI
    zI = zI + 1
    return structure
end

local masterBID = 1 -- keeps track of the stacked block ids
local structureOrigins = {} -- had to do some wizardry for this and keeps track of each structures local bid in its time when it was generated

function cm2s:add(structure)
    --idfk why i did -2 to each, it just works
    masterSave:allocateBlocks(structure._blockIndex - 2)
    masterSave:allocateConnections(structure._connectionIndex - 2)

    --wizardry i did to get connections working
    structureOrigins[structure._hash] = masterSave._blockIndex

    for i = 1, structure._blockIndex - 1 do
        masterSave:addBlockRaw(structure._blocks[i])
    end

    for i = 1, structure._connectionIndex - 1 do
        local id1, id2 = structure._connections[i]:match("^(.-)%s*,%s*(.-)$")
        masterSave:addConnectionRaw(tostring(id1 + masterBID - 1) .. "," .. tostring(id2 + masterBID - 1))
    end

    masterBID = masterBID + structure._blockIndex - 1

    function structure:getInput(name)
        if self._inputs[name] == nil then
            error("{cm2s.lua} Error: no input manifest found with name " .. name)
        end
        return self._inputs[name]
    end

    function structure:getOutput(name)
        if self._outputs[name] == nil then
            error("{cm2s.lua} Error: no output manifest found with name " .. name)
        end
        return self._outputs[name]
    end

    return structure
end

--wizardry
function cm2s:connect(inp, out)
    if #inp ~= #out then
        error("{cm2s.lua} Error: input and output bits arent the same")
    end
    for i = 1, #inp do
        local inpOrigin = structureOrigins[inp._hash]
        local outOrigin = structureOrigins[out._hash]

        masterSave:addConnection(tostring(tonumber(inp[i] + inpOrigin - 1)), tostring(tonumber(out[i] + outOrigin - 1)))
    end
end
function cm2s:retrieve()
    return masterSave
end

return cm2s
