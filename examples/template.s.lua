local dep = require("cm2sDEP")
-- this is a structure object
local structure = dep:newSave(0, 0)
-- note: when modeling circuits of a structure file, make sure to use STRUCTZ for
-- your z values of every block or the blocks will overlap with others
local structureZ = structure._zIndex
local currentY = 0

function structure:manual()
    -- manStringify() can be substituted with your own manual format
    -- manStringify() may not be compatible with all string lengths
    -- best used when strings are kept brief
    return dep:manStringify({
        name = "Template",
        desc = "Template for a .s.lua file (structure file)",
        functions = {
            {
                name = "foo",
                desc = "bar",
                params = { "foo", "bar", "foobar" },
                inputs = { "foo", "bar", "foobar" },
                outputs = { "foo", "bar", "foobar" }
            }
        }
    }, {}) -- options, can be omitted
end

function structure:foo()
    local save = dep:newSave()

    -- logic generation here
    -- use dep:manifestInput(string) and dep:manifestOutput(string) for structure I/O

    save.zIindex = structureZ
    currentY = currentY + 1 -- make sure to increment this by the max Y of your blocks or youll have overlapping blocks
    return save
end

return structure
