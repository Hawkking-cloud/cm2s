--this is the core dependency for all structure files
--this file is the main file to get forked in case of porting to luau/lua, aswell as making a cm2Lua version
package.path="?.lua" -- THIS IS ENVIRONMENT SPECIFIC AND REQUIRES CHANGING BASED ON YOUR HEIRACHY
local cm2Lua=require("OPTcm2Lua")
local dep = {}

function dep:newSave(blocks,wires)
    local save=cm2Lua.new(blocks,wires)
    save._inputs={}
    save._Iid=1
    save._outputs={}
    save._Oid=1
    function save:addInput(blockID)
        self._inputs[self._Iid]=blockID
        self._Iid = self._Iid + 1

    end
    function save:addOutput(blockID)
        save._outputs[save._Oid]=blockID
        save._Oid=save._Oid+1
    end
    return save
end
-- yoinked from https://stackoverflow.com/questions/1426954/split-string-in-lua
local function strSplit(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
  end
function dep:manStringify(man,options)
    local menuWidth=options.menuWidth or 40
    --│├─┰╭╮╰╯
    local outStr=""
    --top bar
    outStr=outStr..'╭─'..man.name..string.rep('─',menuWidth-2-#man.name-1).."╮\n"
    ----desc
    outStr=outStr..'│Desc:'
    local descSplitted=strSplit(man.desc,' ')
    local leftSideWidth=6
    for i=1,#descSplitted do
        local token=descSplitted[i]
        if leftSideWidth+#token+1<menuWidth-1 then
            outStr=outStr..token..' '
            leftSideWidth=leftSideWidth+#token+1
        else
            outStr=outStr..string.rep(' ',menuWidth-leftSideWidth-1)..'│\n'
            outStr=outStr..'│     '..token..' '
            leftSideWidth=7+#token
        end
    end
    outStr=outStr..string.rep(' ',menuWidth-leftSideWidth-1).."│\n"
    --functions
    outStr=outStr..'├┄Functions'..string.rep('┄',menuWidth-12)..'┤\n'
    for i=1,#man.functions do
        local manfunc=man.functions[i]
        outStr=outStr..'├┬─'..manfunc.name..string.rep(' ',menuWidth-4-#manfunc.name)..'│\n'
        outStr=outStr..'│├─Desc:'
        descSplitted=strSplit(manfunc.desc,' ')
        leftSideWidth=8
        for j=1,#descSplitted do
            local token=descSplitted[j]
            if leftSideWidth+#token+1<menuWidth-1 then
                if j==#descSplitted then
                    leftSideWidth=leftSideWidth+#token 
                    outStr=outStr..token
                else
                    leftSideWidth=leftSideWidth+#token+1 
                    outStr=outStr..token..' '
                end
            else
                outStr=outStr..string.rep(' ',menuWidth-leftSideWidth-1)..'│\n'
                outStr=outStr.."││      "..token..' '
                leftSideWidth=8+#token+1
            end
        end
        outStr=outStr..string.rep(' ',menuWidth-leftSideWidth-1)..'│\n'
        --params
        outStr=outStr..'│├─Params:'
        leftSideWidth=10
        for j=1,#manfunc.params do
            local param=manfunc.params[j]
            if leftSideWidth+#param+1<menuWidth-1 then
                if j==#manfunc.params then
                    outStr=outStr..param..' '
                    leftSideWidth=leftSideWidth+#param+1
                else
                    outStr=outStr..param..', '
                    leftSideWidth=leftSideWidth+#param+2
                end
            else 
                outStr=outStr..string.rep(' ',menuWidth-leftSideWidth-1)..'│\n'
                if j==#manfunc.params then
                    outStr=outStr..'││         '..param..' '
                    leftSideWidth=12+#param
                else
                    outStr=outStr..'││         '..param..', '
                    leftSideWidth=13+#param
                
                end
            end
        end
        outStr=outStr..string.rep(' ',menuWidth-leftSideWidth-1)..'│\n'

        --inputs
        outStr=outStr..'│├─Inputs:'
        leftSideWidth=10
        for j=1,#manfunc.inputs do
            local input=manfunc.inputs[j]
            if leftSideWidth+#input+1<menuWidth-1 then
                if j==#manfunc.inputs then
                    outStr=outStr..input..' '
                    leftSideWidth=leftSideWidth+#input+1
                else
                    outStr=outStr..input..', '
                    leftSideWidth=leftSideWidth+#input+2
                end
            else 
                outStr=outStr..string.rep(' ',menuWidth-leftSideWidth-1)..'│\n'
                if j==#manfunc.inputs then
                    outStr=outStr..'││         '..input..' '
                    leftSideWidth=12+#input
                else
                    outStr=outStr..'││         '..input..', '
                    leftSideWidth=13+#input
                
                end
            end
        end
        outStr=outStr..string.rep(' ',menuWidth-leftSideWidth-1)..'│\n'

        --outputs
        outStr=outStr..'│╰─Outputs:'
        leftSideWidth=11
        for j=1,#manfunc.outputs do
            local output=manfunc.outputs[j]
            if leftSideWidth+#output+1<menuWidth-1 then
                if j==#manfunc.outputs then
                    outStr=outStr..output..' '
                    leftSideWidth=leftSideWidth+#output+1
                else
                    outStr=outStr..output..', '
                    leftSideWidth=leftSideWidth+#output+2
                end
            else 
                outStr=outStr..string.rep(' ',menuWidth-leftSideWidth-1)..'│\n'
                if j==#manfunc.outputs then
                    outStr=outStr..'││         '..output..' '
                    leftSideWidth=12+#output
                else
                    outStr=outStr..'││         '..output..', '
                    leftSideWidth=13+#output
                
                end
            end
        end
        outStr=outStr..string.rep(' ',menuWidth-leftSideWidth-1)..'│\n'
    end
    --bottombar
    outStr=outStr..'╰'..string.rep('─',menuWidth-2)..'╯'
    return outStr
end


return dep
