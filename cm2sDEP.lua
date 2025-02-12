--this is the core dependancy for all structure files
--this file is the main file to get forked in case of porting to luau/lua, aswell as making a cm2Lua version or somehow using other reg manips

local cm2Lua = require("OPTcm2Lua")
local zIndex = 0
local dep = {}

math.randomseed(os.time())
local function randstring(length)
    local result = ""
    for _ = 1, length do
        result = result .. string.char(math.random(97, 122))
    end
    return result
end

function dep:newSave(blocks, wires)
    local save = cm2Lua.new(blocks, wires)
    save._inputs = {}
    save._outputs = {}
    save._hash = randstring(10) -- hashing for the connection magic took place in cm2s.lua
    save._zIndex = zIndex
    zIndex = zIndex + 1

    function save:manifestInput(name)
        self._inputs[name] = { _hash = self._hash }
    end

    function save:manifestOutput(name)
        self._outputs[name] = { _hash = self._hash }
    end

    function save:addInput(block, name)
        assert(self._inputs[name] == nil, "{cm2sDEP} Error: no input manifested called " .. name)
        self._inputs[name][#self._inputs[name] + 1] = block
    end

    function save:addOutput(block, name)
        assert(not self._outputs[name], "{cm2sDEP} Error: no output manifested called " .. name)
        self._outputs[name][#self._outputs[name] + 1] = block
    end

    return save
end

local function strSplit(inputString, separator)
    separator = separator or "%s"
    local result = {}
    for str in string.gmatch(inputString, "([^" .. separator .. "]+)") do
        table.insert(result, str)
    end
    return result
end

-- no reason to look at this function its just for generating the manual ui
-- i give up. - moony
function dep:manStringify(man, options)
    options = options or {}
    local menuWidth = options.menuWidth or 40
    --│├─┰╭╮╰╯
    local outStr = ""
    --top bar
    outStr = outStr .. "╭─" .. man.name .. string.rep("─", menuWidth - 2 - #man.name - 1) .. "╮\n"
    ----desc
    outStr = outStr .. "│Desc:"
    local descSplitted = strSplit(man.desc, " ")
    local leftSideWidth = 6
    for i = 1, #descSplitted do
        local token = descSplitted[i]
        if leftSideWidth + #token + 1 < menuWidth - 1 then
            outStr = outStr .. token .. " "
            leftSideWidth = leftSideWidth + #token + 1
        else
            outStr = outStr .. string.rep(" ", menuWidth - leftSideWidth - 1) .. "│\n"
            outStr = outStr .. "│     " .. token .. " "
            leftSideWidth = 7 + #token
        end
    end
    outStr = outStr .. string.rep(" ", menuWidth - leftSideWidth - 1) .. "│\n"
    --functions
    outStr = outStr .. "├┄Functions" .. string.rep("┄", menuWidth - 12) .. "┤\n"
    for i = 1, #man.functions do
        local manfunc = man.functions[i]
        outStr = outStr .. "├┬─" .. manfunc.name .. "()" .. string.rep(" ", menuWidth - 6 - #manfunc.name) .. "│\n"
        outStr = outStr .. "│├─Desc:"
        descSplitted = strSplit(manfunc.desc, " ")
        leftSideWidth = 8
        for j = 1, #descSplitted do
            local token = descSplitted[j]
            if leftSideWidth + #token + 1 < menuWidth - 1 then
                if j == #descSplitted then
                    leftSideWidth = leftSideWidth + #token
                    outStr = outStr .. token
                else
                    leftSideWidth = leftSideWidth + #token + 1
                    outStr = outStr .. token .. " "
                end
            else
                outStr = outStr .. string.rep(" ", menuWidth - leftSideWidth - 1) .. "│\n"
                outStr = outStr .. "││      " .. token .. " "
                leftSideWidth = 8 + #token + 1
            end
        end
        outStr = outStr .. string.rep(" ", menuWidth - leftSideWidth - 1) .. "│\n"
        --params
        outStr = outStr .. "│├─Params:"
        leftSideWidth = 10
        for j = 1, #manfunc.params do
            local param = manfunc.params[j]
            if leftSideWidth + #param + 1 < menuWidth - 1 then
                if j == #manfunc.params then
                    outStr = outStr .. param .. " "
                    leftSideWidth = leftSideWidth + #param + 1
                else
                    outStr = outStr .. param .. ", "
                    leftSideWidth = leftSideWidth + #param + 2
                end
            else
                outStr = outStr .. string.rep(" ", menuWidth - leftSideWidth - 1) .. "│\n"
                if j == #manfunc.params then
                    outStr = outStr .. "││         " .. param .. " "
                    leftSideWidth = 12 + #param
                else
                    outStr = outStr .. "││         " .. param .. ", "
                    leftSideWidth = 13 + #param
                end
            end
        end
        outStr = outStr .. string.rep(" ", menuWidth - leftSideWidth - 1) .. "│\n"

        --inputs
        outStr = outStr .. "│├─Inputs:"
        leftSideWidth = 10
        for j = 1, #manfunc.inputs do
            local input = manfunc.inputs[j]
            if leftSideWidth + #input + 1 < menuWidth - 1 then
                if j == #manfunc.inputs then
                    outStr = outStr .. input .. " "
                    leftSideWidth = leftSideWidth + #input + 1
                else
                    outStr = outStr .. input .. ", "
                    leftSideWidth = leftSideWidth + #input + 2
                end
            else
                outStr = outStr .. string.rep(" ", menuWidth - leftSideWidth - 1) .. "│\n"
                if j == #manfunc.inputs then
                    outStr = outStr .. "││         " .. input .. " "
                    leftSideWidth = 12 + #input
                else
                    outStr = outStr .. "││         " .. input .. ", "
                    leftSideWidth = 13 + #input
                end
            end
        end
        outStr = outStr .. string.rep(" ", menuWidth - leftSideWidth - 1) .. "│\n"

        --outputs
        outStr = outStr .. "│╰─Outputs:"
        leftSideWidth = 11
        for j = 1, #manfunc.outputs do
            local output = manfunc.outputs[j]
            if leftSideWidth + #output + 1 < menuWidth - 1 then
                if j == #manfunc.outputs then
                    outStr = outStr .. output .. " "
                    leftSideWidth = leftSideWidth + #output + 1
                else
                    outStr = outStr .. output .. ", "
                    leftSideWidth = leftSideWidth + #output + 2
                end
            else
                outStr = outStr .. string.rep(" ", menuWidth - leftSideWidth - 1) .. "│\n"
                if j == #manfunc.outputs then
                    outStr = outStr .. "││         " .. output .. " "
                    leftSideWidth = 12 + #output
                else
                    outStr = outStr .. "││         " .. output .. ", "
                    leftSideWidth = 13 + #output
                end
            end
        end
        outStr = outStr .. string.rep(" ", menuWidth - leftSideWidth - 1) .. "│\n"
    end
    --bottombar
    outStr = outStr .. "╰" .. string.rep("─", menuWidth - 2) .. "╯"
    return outStr
end

return dep
