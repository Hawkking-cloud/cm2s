# cm2s  
**cm2 script** – A Lua-powered way to generate circuits in CM2.  

⚠ **Work in Progress** – Might get abandoned at some point.  

This project uses **OPTcm2Lua** to generate CM2 save strings.  
- The structure dependency file can be forked to support other registry manipulators.  

_Readme format is kinda rough right now. Probably gonna use AI to clean it up once the core stuff is done._  

---

## cm2s.lua  
The main interaction point and wrapper for everything.  

### `cm2s:initStruct(structure)`  
Called when importing a structure. Example:  
```lua
local template = cm2s:initStruct(require("template"))
```
This function assigns a z-index to the structure and updates the global structure count.  

### `cm2s:add(structure)`  
Allocates and appends blocks/wires from the local save to the master/global one.  
Used when adding a new circuit. Example:  
```lua
local reg1 = cm2s:add(registers:normal(8))
```
Also adds functions like `structure:getInput()` and `structure:getOutput()`.  

### `cm2s:connect(input, output)`  
Connects an input to an output. Example:  
```lua
local reg1 = cm2s:add(registers:normal(8))
local reg2 = cm2s:add(registers:normal(8))

cm2s:connect(reg1:getOutput("data"), reg2:getInput("data"))
```
Small function, but will throw an error if bus/bit sizes don’t match.  

### `cm2s:retrieve()`  
Returns the master save. Example:  
```lua
-- Exports the global save
print(registers:retrieve():export())
```

---

## cm2sDEP.lua  
This is the dependency file used by all structure files.  
If you want to use different register manipulators, **this is the file to modify**.  

### `dep:manStringify(data)`  
Default formatter for manuals (can be overridden in structure files).  
Only available option right now:  
- `options.menuWidth` (default: 40)  

### `dep:newSave(blocks, wires)`  
A wrapper for OPTcm2Lua save generation.  
Adds variables:  
- `save._inputs`  
- `save._outputs`  
- `save._hash`  
- `save._zID`  

Adds functions:  
- `save:manifestInput()`  
- `save:manifestOutput()`  
- `save:addInput()`  
- `save:addOutput()`  

---

## OPTcm2Lua.lua  
The fastest Lua register manipulator, and the one used by base cm2s.  
Low-level, minimal, and optimized for speed.  

### `cm2Lua:new(blocks, wires)`  
Creates a new save object. Example:  
```lua
local save = cm2Lua:new(2,1)
save:addBlock(5, 0, 0, 0)
save:addBlock(5, 2, 0, 0)
save:addConnection(save._bid-2, save._bid-1) -- more info on save._bid below
```

### `save._bid`  
Stores the next block ID.  
Doesn’t use `#save._blocks` for performance reasons.  
To reference the last block added: `save._bid - 1`  

### `save:addBlock(id, x, y, z)`  
Adds a block to the save.  
- `id` = The [respective block ID](https://static.wikia.nocookie.net/cm2/images/1/1d/Image_2024-03-16_200149325.png/revision/latest/scale-to-width-down/201?cb=20240529015257)  
- `x, y, z` = Position  

### `save:addConnection(block_id_1, block_id_2)`  
Creates a connection between two blocks using their indices (e.g., `save._bid`).  

# First Time Tutorial on how to use!
1. Clone the repo `git clone https://github.com/Hawkking-cloud/cm2s.git` and get into it `cd cm2s`
2. Install luajit/lua (this part of the tutorial is focused on linux, either use wsl or use a linux computer

- **Debian/Ubuntu:**
    - `sudo apt update`
    - `sudo apt install luarocks`
    - `sudo luarocks install luajit`
    - `luajit -v`

- **Arch Linux:**
    - `sudo pacman -S luarocks`
    - `sudo luarocks install luajit`
    - `luajit -v`
  
3. make a usage file `touch usage.lua`
  - this is the file that will utilize and "wrap" all the files together
  - template code: 
```lua
package.path="?.lua;TemplateStructures/?.s.lua" -- this is how you tell the require() function what files to include
local cm2s = require("cm2s") 
local registers = cm2s:initStruct( require("registers") ) -- the registers structure file (TemplateStructures/registers.s.lua)

cm2s:add( registers:lite(4) )

print( cm2s:retrieve():export() )
```
4. execute it `luajit usage.lua`
  - should return a cm2 save string cooresponding to one lite register
 
