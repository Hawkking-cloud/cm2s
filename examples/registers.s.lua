local dep = require("cm2sDEP")
local structure = {}
local STRUCTZ = structure._zIndex
local currentY = 0

function structure:manual()
    return dep:manStringify({
        name = "Registers",
        desc = "Simple register structure.",
        functions = {
            {
                name = "lite",
                desc = "Comes with just the writing.",
                params = { "bits" },
                inputs = { "data", "write" },
                outputs = { "data" }
            },
            {
                name = "normal",
                desc = "Comes with the write and clear.",
                params = { "bits" },
                inputs = { "data", "write", "clear" },
                outputs = { "data" }
            }
        }
    })
end

function structure:lite(bits)
    local save = dep:newSave(1 + (bits * 4), bits * 5)

    -- manifesting the inputs and outputs
    save:manifestInput("write")
    save:manifestInput("data")
    save:manifestOutput("data")

    local write = save:addBlock(15, -2, currentY, STRUCTZ)
    save:addInput(write, "write")

    for i = 1, bits do
        local input = save:addBlock(15, i, currentY, STRUCTZ)
        local xorGate = save:addBlock(3, i, currentY + 1, STRUCTZ)
        local andGate = save:addBlock(1, i, currentY + 2, STRUCTZ)
        local output = save:addBlock(5, i, currentY + 3, STRUCTZ)

        save:addInput(input, "data")
        save:addOutput(output, "data")
        save:addConnection(input, xorGate)
        save:addConnection(write, andGate)
        save:addConnection(xorGate, andGate)
        save:addConnection(output, xorGate)
        save:addConnection(andGate, output)
    end
    currentY = currentY + 4
    save.zIndex = STRUCTZ
    return save
end

function structure:normal(bits)
    local save = dep:newSave(1 + (bits * 4), bits * 5)

    save:manifestInput("write")
    save:manifestInput("clear")
    save:manifestInput("data")
    save:manifestOutput("data")

    local write = save:addBlock(15, -2, currentY, STRUCTZ)
    local clear = save:addBlock(15, -2, currentY + 1, STRUCTZ)
    save:addInput(write, "write")
    save:addInput(clear, "clear")

    for i = 1, bits do
        local input = save:addBlock(15, i, currentY, STRUCTZ)
        local xorGate = save:addBlock(3, i, currentY + 1, STRUCTZ)
        local andGate = save:addBlock(1, i, currentY + 2, STRUCTZ)
        local andGate2 = save:addBlock(1, i, currentY + 2, STRUCTZ)
        local output = save:addBlock(5, i, currentY + 3, STRUCTZ)

        save:addInput(input, "data")
        save:addOutput(output, "data")
        save:addConnection(input, xorGate)
        save:addConnection(write, andGate)
        save:addConnection(xorGate, andGate)
        save:addConnection(clear, andGate2)
        save:addConnection(output, xorGate)
        save:addConnection(andGate, output)
        save:addConnection(output, andGate2)
        save:addConnection(andGate2, output)
    end

    currentY = currentY + 5
    save.zIndex = STRUCTZ
    return save
end

return structure
