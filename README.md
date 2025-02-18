# cm2s

## a Lua-Powered way to create and connect modules of Circuits in circuit maker 2

![GitHub last commit](https://img.shields.io/github/last-commit/Hawkking-Cloud/cm2s)

This project is entirely made by Hawk with some help from the Circuit Maker 2 Community. This tool is the first of its kind and allows you to create seperate modules and connect them all together with code. For example instead of making a generator for an adder and a register and wiring it by hand, cm2 Script does it for you. This uses OPTcm2Lua, a heavily optimized register manipulator for Circuit Maker 2.

The following documentation shows

- Functions of cm2s.lua (the dependency for usage files)
- Functions of cm2sDEP.lua (the dependency for structure files)
- Functions of OPTcm2Lua.lua (the reg manip for both structure files and the master save in cm2s.lua)
- A small tutorial (at the bottom of the readme

⚠ **Work in Progress** – Might get abandoned at some point.

## Simple Tutorial (Linux)

Easiest way to get started with cm2s

1. Clone the repo `git clone https://github.com/Hawkking-cloud/cm2s.git` and get into it `cd cm2s`
2. Install luajit/lua

- **Debian/Ubuntu:**

  - `sudo apt update`
  - `sudo apt install luarocks`
  - `sudo luarocks install luajit`
  - `luajit -v`

- **Arch Linux:**
  - `sudo pacman -S luarocks`
  - `sudo luarocks install luajit`
  - `luajit -v`

3. Make a usage file `touch usage.lua`

- Template Code:

```lua
package.path = package.path .. ";?.lua;TemplateStructures/?.s.lua" -- this is how you tell the require() function what files to include
local cm2s = require("cm2s")
local registers = cm2s:initStruct( require("registers") ) -- the registers structure file (TemplateStructures/registers.s.lua)

cm2s:add( registers:lite(4) )

print( cm2s:retrieve():export() )
```

4. Change usage code and generate structure files to your hearts desire!

## Links:

[cm2s.lua](#cm2slua)  
[cm2sDEP.lua](#cm2sdeplua)  
[OPTcm2Lua.lua](#optcm2lualua)  
[.s.lua files](#slua-files)
---

# cm2s.lua

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

# cm2sDEP.lua

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

## dep string:

This is the save you will generate in a structure file using `dep:newSave()`
below will refrence depSave as this save

### `depSave:manifestInput(name)`

This function manifests/initalizes an input, `depSave:addInput()` will error if the input isnt manifested

### `depSave:manifestOutput(name)`

This function manifests/initalizes an output, `depSave:addOutput()` will error if the output isnt manifested

### `depSave:addInput(block,name)`

This function adds a block to the input name

### `depSave:addOutput(block,name)`

This function adds a block to the output name

---

# OPTcm2Lua.lua

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

### `save._blockIndex`

Stores the next block ID.  
Doesn’t use `#save._blocks` for performance reasons.  
To reference the last block added: `save._blockIndex - 1`

### `save:addBlock(id, x, y, z, meta)`

Adds a block to the save.

- `id` = The [respective block ID](https://static.wikia.nocookie.net/cm2/images/1/1d/Image_2024-03-16_200149325.png/revision/latest/scale-to-width-down/201?cb=20240529015257)
- `x, y, z` = Position, optional
- `meta` = The meta tag, eg: the rgb in an LED, optional

### `save:addConnection(block_1, block_2)`

Creates a connection between two blocks using their indices (e.g., `save._bid`).

### `save:findBlock(x, y, z)`

Returns either the block index at that postion, or nil

---

# .s.lua files

- This type of file is what defines a structure file
- A structure file is a group of circuit functions, ex: adder, register
- Circuit functions to generate type of circuit

Explanation of the Template structure and/or a tutorial

1. Require "cm2sDep"
   - This is the dependency file for all structure files and contains functions that a save returned by a structure file must have
2. define the returned structure
   - Remember, structure files are modules to be required() by usage files, so create a structure object and return it at the end
3. structureZ and currentY
   - These variables are what you use to correctly position your circuits so they dont overlap
   - structureZ is set by cm2s.lua and therefore you must run `structureZ = structure._structureZ` at the beginning of a circuit function to make sure its valid
4. structure:manual()
   - This is an unnecesary yet cool feature to cm2s, where you can define an object that briefly documents what your structure file does and cm2sDEP.lua will format it with box characters for you!
     - This can use its own format but using the built in formatter is simpler
   - For the format of the object, just copy the one off of `template.s.lua` and change it to your structures needs
   - Format used: `return dep:manStringify({data here},{options here})`
5. Circuit functions
   - These are what return the save files for cm2s to process
   - As mentioned before, run `structureZ = structure._structureZ` before adding any blocks to ensure your saves at the right Z level
   - Use OPTcm2Lua to add and generate blocks and connections to add to the save
   - Make sure to keep track of currentY or else youll have overlapping blocks
     - This can be theoretically be substituted with your own maximum of block finder
   - Return the save so cm2s can process it

Note:
This format can possible be tweaked just as long as it has circuit functions that return saves
