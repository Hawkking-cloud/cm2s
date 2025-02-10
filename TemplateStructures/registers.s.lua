package.path="cm2s/?.lua"
local dep=require("cm2sDEP")
local structure={}
-- this is a structure object
--node: when modeling circuits of a structure file, make sure to use STRUCTZ for your z values of every block or the blocks will overlap with others
local STRUCTZ=0
local ObjY=0
function structure:manual()
    -- dep:manStringify() can be substituted with your own manual format 
    -- dep:manStringify() may not be compatible with all string lengths
    -- best used when strings are kept brief
    return dep:manStringify({
        name="Registers",
        desc="Simple register structure.",
        functions={
            {
                name="lite",
                desc="Comes with just the writing.",
                params={"bits"},
                inputs={"data","write"},
                outputs={"data"}
            },
            {
                name="normal",
                desc="Comes with the write and clear.",
                params={"bits"},
                inputs={"data","write","clear"},
                outputs={"data"}
            },
            
        }
    },
    {
        --options
    })
end

function structure:lite(bits)
    local save=dep:newSave(1+(bits*4),bits*5)

    local write=save:addBlock(15,-2,ObjY,STRUCTZ)
    save:addInput(save._bid-1) -- use save._bid-1 to refrence the block just created (save._bid is prepped for the future block)
    local xor
    for i=1,bits do
        save:addBlock(15,i,ObjY,STRUCTZ)
        save:addInput(save._bid)
        xor=save:addBlock(3,i,ObjY+1,STRUCTZ)
        save:addConnection(save._bid-2,xor)
        save:addBlock(1,i,ObjY+2,STRUCTZ)
        save:addConnection(xor,save._bid-1) 
        save:addConnection(write,save._bid-1)
        save:addBlock(5,i,ObjY+3,STRUCTZ)
        save:addConnection(save._bid-2,save._bid-1) --wire the prior block to this block
        save:addConnection(save._bid-1,xor)
        save:addOutput(save._bid)
    end 
    save.zI=STRUCTZ
    ObjY=ObjY+4 -- make sure to increment this by the max Y of your blocks or youll have overlapping blocks
    return save
end

function structure:normal(bits)
    local save=dep:newSave(1+(bits*4),bits*5)
    local clear=save:addBlock(15,-3,ObjY,STRUCTZ)
    save:addInput(save._bid-1) 
    local write=save:addBlock(15,-2,ObjY,STRUCTZ)
    save:addInput(save._bid-1) 
    local xor
    for i=1,bits do
        save:addBlock(15,i,ObjY,STRUCTZ)
        save:addInput(save._bid)
        xor=save:addBlock(3,i,ObjY+1,STRUCTZ)
        save:addConnection(save._bid-2,xor)
        save:addBlock(1,i,ObjY+2,STRUCTZ)
        save:addConnection(xor,save._bid-1) 
        save:addConnection(write,save._bid-1)
        save:addBlock(1,i,ObjY+3,STRUCTZ)
        save:addConnection(clear,save._bid-1)
        save:addConnection(save._bid-4,save._bid-1)
        
        save:addBlock(5,i,ObjY+4,STRUCTZ)
        save:addConnection(save._bid-1,save._bid-2)
        save:addConnection(save._bid-2,save._bid-1)
        
        save:addConnection(save._bid-3,save._bid-1)
        save:addConnection(save._bid-1,xor)
        save:addOutput(save._bid)
    end 
    save.zI=STRUCTZ
    ObjY=ObjY+5
    return save
end

return structure
