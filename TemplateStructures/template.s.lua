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
            name = "Template",
            desc = "Template for a .s.lua file (structure file)",
            functions = {
                {
                    name = "foo",
                    desc = "bar",
                    params = {"foo", "bar", "foobar"},
                    inputs = {"foo", "bar", "foobar"},
                    outputs = {"foo", "bar", "foobar"}
                }
            }
        },
        {}
    )
end

function structure:foo()
    local save = dep:newSave()
    structureZ = structure._structureZ

    -- logic generation here

    currentY = currentY + 1 -- make sure to increment this by the max Y of your blocks or youll have overlapping blocks
    return save
end

return structure
