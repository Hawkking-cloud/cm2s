local cm2Lua = require("OPTcm2Lua")
local zIndex = 0 --this increments and tells the structure what zindex to use
local masterSave = cm2Lua.new(0, 0) --save that is written to when structures are added, this file mainly just wraps all the structures together
local masterBlockIndex = 1 -- keeps track of the stacked block ids
local structureOrigins = {} -- had to do some wizardry for this and keeps track of each structures local bid in its time when it was generated

local cm2s = {}

function cm2s:initStruct(structure)
    structure.STRUCTZ = zIndex
    zIndex = zIndex + 1
    return structure
end

function cm2s:add(structure)
    masterSave:allocateBlocks(structure._blockIndex - 2)
    masterSave:allocateConnections(structure._connectionIndex - 2)
    structureOrigins[structure._hash] = masterSave._blockIndex

    for i = 1, structure._blockIndex - 1 do
        masterSave:addBlockRaw(structure._blocks[i])
    end

    for i = 1, structure._connectionIndex - 1 do
        local id1, id2 = structure._connections[i]:match("^(.-)%s*,%s*(.-)$")
        masterSave:addConnection(id1 + masterBlockIndex - 1, id2 + masterBlockIndex - 1)
    end

    masterBlockIndex = masterBlockIndex + structure._blockIndex - 1

    function structure:getInput(name)
        assert(not self._inputs[name], "{cm2s.lua} Error: no input manifest found with name " .. name)
        return self._inputs[name]
    end

    function structure:getOutput(name)
        assert(not self._outputs[name], "{cm2s.lua} Error: no output manifest found with name " .. name)
        return self._outputs[name]
    end

    return structure
end

function cm2s:connect(input, output)
    assert(#input ~= #output, "{cm2s.lua} Error: input and output bits arent the same")
    for i = 1, #input do
        local inputOrigin = structureOrigins[input._hash]
        local outputOrigin = structureOrigins[output._hash]
        masterSave:addConnection(input[i] + inputOrigin - 1, output[i] + outputOrigin - 1)
    end
end

function cm2s:getMasterSave()
    return masterSave
end

return cm2s
