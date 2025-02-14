local dep = require("cm2sDEP")
local structure = {}
-- this is a structure object
--node: when modeling circuits of a structure file, make sure to use structureZ for your z values of every block or the blocks will overlap with others
local structureZ = 0
local currentY = 0
function structure:manual()
    -- dep:manStringify() can be substituted with your own manual format
    -- dep:manStringify() may not be compatible with all string lengths
    -- best used when strings are kept brief
    return dep:manStringify(
        {
            name = "Registers",
            desc = "Simple register structure.",
            functions = {
                {
                    name = "lite",
                    desc = "Comes with just the writing.",
                    params = {"bits"},
                    inputs = {"data", "write"},
                    outputs = {"data"}
                },
                {
                    name = "normal",
                    desc = "Comes with the write and clear.",
                    params = {"bits"},
                    inputs = {"data", "write", "clear"},
                    outputs = {"data"}
                }
            }
        },
        {}
    )
end

function structure:lite(bits)
    structureZ = structure._structureZ
    local save = dep:newSave(1 + (bits * 4), bits * 5)

    --manifesting the inputs and outputs
    save:manifestInput("write")
    save:manifestInput("data")

    save:manifestOutput("data")

    local write = save:addBlock(15, -2, currentY, structureZ)
    save:addInput(write, "write")

    for i = 1, bits do
        local input = save:addBlock(15, i, currentY, structureZ)
        save:addInput(input, "data")

        local xorGate = save:addBlock(3, i, currentY + 1, structureZ)
        save:addConnection(input, xorGate)

        local andGate = save:addBlock(1, i, currentY + 2, structureZ)
        save:addConnection(write, andGate)
        save:addConnection(xorGate, andGate)

        local output = save:addBlock(5, i, currentY + 3, structureZ)
        save:addOutput(output, "data")

        save:addConnection(output, xorGate)
        save:addConnection(andGate, output)
    end

    save.zI = structureZ
    currentY = currentY + 4 -- make sure to increment this by the max Y of your blocks or youll have overlapping blocks
    return save
end
function structure:normal(bits)
    structureZ = structure._structureZ
    local save = dep:newSave(1 + (bits * 4), bits * 5)

    save:manifestInput("write")
    save:manifestInput("clear")
    save:manifestInput("data")

    save:manifestOutput("data")

    local write = save:addBlock(15, -2, currentY, structureZ)
    save:addInput(write, "write")

    local clear = save:addBlock(15, -2, currentY + 1, structureZ)
    save:addInput(clear, "clear")

    for i = 1, bits do
        local input = save:addBlock(15, i, currentY, structureZ)
        save:addInput(input, "data")

        local xorGate = save:addBlock(3, i, currentY + 1, structureZ)
        save:addConnection(input, xorGate)

        local andGate = save:addBlock(1, i, currentY + 2, structureZ)
        save:addConnection(write, andGate)
        save:addConnection(xorGate, andGate)

        local andGate2 = save:addBlock(1, i, currentY + 2, structureZ)
        save:addConnection(clear, andGate2)

        local output = save:addBlock(5, i, currentY + 3, structureZ)
        save:addOutput(output, "data")

        save:addConnection(output, xorGate)
        save:addConnection(andGate, output)
        save:addConnection(output, andGate2)
        save:addConnection(andGate2, output)
    end

    currentY = currentY + 5
    return save
end

return structure
