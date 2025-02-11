# cm2s
cm2: scripted, a way to generate circuits via lua

# this is currently a wip and might get abandoned

this project uses OPTcm2Lua to generate the cm2 save strings
- structure dependency file can be forked to use other registry manipulators

readme format super ass rn, prolly gonna use ai to improve it once im done with the boiler plate

# cm2s.lua
main interaction point and wrapper of everything

cm2s:initStruct(structure)
this is called when "importing" a structure, example:
```lua
local template=cm2s:initStruct(require("template"))
```
this is a small function and just increments the global structz value and tells the struct what z index to use

cm2s:add(structure)
this mediumly sized function does some wizardry to allocate and append the blocks and wires from the local save to the master/global one
used whenever adding a new circuit, example:
```lua
local reg1=cm2s:add(registers:normal(8))
```
adds functions like `structure:getInput()` and `structure:getOutput()`

cm2s:connect(input,output)
this connects an input and an output, duh
usage example:
```lua
local reg1=cm2s:add(registers:normal(8))
local reg2=cm2s:add(registers:normal(8))

cm2s:connect(reg1:getOutput("data"),reg2:getInput("data"))
```
relatively small, will error if you try to wire invalid bus/bit sizes

cm2s:retrieve()
just returns the masterSave, thats it
usage example:
```lua
--exports the global save
print(registers:retrieve():export())
```

# cm2sDEP.lua
this is the dependency that all the structure files use
this is the file to be forked and modified if you want to use different register manipulators
(refrences of dep are refrencing cm2sDEP.lua)

dep:manStringify(data)
this is the default formatter for manuals i wrote, this can be changed in the structure file code (eg: not use the func and using your own)
only option for this rn is `options.menuWidth` (default 40)

dep:newSave(blocks,wires)
this is mostly just a cm2s wrapper for the default OPTcm2Lua save generation
it adds variables: `save._inputs`,`save._outputs`,`save._hash`,`save._zID` 
and functions:  `save:manifestInput()`,`save:manifestOutput()`,`save:addInput()`,`save:addOutput()`

# OPTcm2Lua.lua
this is the fastest lua reg manip out there and the main one used by base cm2s
low level, minimal objects, focused on optimization
(refrences of cm2lua below are refrencing OPTcm2Lua.lua)
(refrences of save are refrencing a new save using cm2Lua.new())

cm2Lua:new(blocks,wires)
returns a new save object with functions within it, initalizes blocks and wires/connections 
```lua
local save=cm2Lua:new(2,1)
save:addBlock(5,0,0,0)
save:addBlock(5,2,0,0)
save:addConnection(save._bid-2,save._bid-1) --more information on save._bid below
```

## save._bid
this is the future block id of the save
doesnt use `#save._blocks` for preformance
to refrence the block just placed do `save._bid-1` (future-1=present no?) 

## save:addBlock(id,x,y,z)
id = the [respective block id](https://static.wikia.nocookie.net/cm2/images/1/1d/Image_2024-03-16_200149325.png/revision/latest/scale-to-width-down/201?cb=20240529015257) 
all parameters are needed

## save:addConnection(block_id_1,block_id_2)
the block ids refrence the index of the block in the save (eg: save._bid)

