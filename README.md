# cm2s
cm2: scripted, a way to generate circuits via lua

# this is currently a wip and might get abandoned

this project uses OPTcm2Lua to generate the cm2 save strings
- structure dependency file can be forked to use other registry manipulators



usage template
```lua
local cm2s=require("cm2s/cm2s")
package.path="cm2s/?.s.lua"
local registers=cm2s:initStruct(require("registers"))
package.path="cm2s/?.s.lua"
local template=cm2s:initStruct(require("template"))

--prints the manual of the structure "registers"
print(registers:manual())

```
