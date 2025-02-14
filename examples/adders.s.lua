local dep=require("cm2sDEP")
local structure={}

local structureZ=0
local currentY=0
function structure:manual()
    return dep:manStringify({
        name="Adders",
        desc="ripple and CLA adders with both RMS and LMS",
        functions={
            {
                name="ripple",
                desc="simple ripple adder, (1=RMS,0=LMS)",
                params={'bits','significant'},
                inputs={'data1','data2'},
                outputs={'data'}
            },
            
        }
    },
    {
        --options
    })
end

function structure:ripple(bits,sig)
    structureZ=structure._structureZ
    local save=dep:newSave()
    
    save:manifestInput("data1")
    save:manifestInput("data2")

    save:manifestOutput("data")

    for i=1,bits do
        local inp1 = save:addBlock(15,i,currentY,structureZ)
        local inp2 = save:addBlock(15,i,currentY+1,structureZ)
        save:addInput(inp1,"data1")
        save:addInput(inp2,"data2")

        local xor1=save:addBlock(3,i,currentY+2,structureZ)
        local and1=save:addBlock(1,i,currentY+3,structureZ)
        
        save:addConnection(inp1,xor1)
        save:addConnection(inp1,and1)
        save:addConnection(inp2,xor1)
        save:addConnection(inp2,and1)
        
        if sig==1 then
            if i~=1 then
                local xor2=save:addBlock(3,i,currentY+4,structureZ)
                local and2=save:addBlock(1,i,currentY+5,structureZ)
                save:addConnection(xor1,xor2)
                save:addConnection(xor1,and2)
                
                if i~=bits then
                    local carryOr=save:addBlock(15,i,currentY+6,structureZ)
                    save:addConnection(and1,carryOr)
                    save:addConnection(and2,carryOr)
                    
                end
                if i==2 then
                    save:addConnection(save:findBlock(i-1,currentY+3,structureZ),xor2)
                    save:addConnection(save:findBlock(i-1,currentY+3,structureZ),and2)
                else
                    save:addConnection(save:findBlock(i-1,currentY+6,structureZ),xor2)
                    save:addConnection(save:findBlock(i-1,currentY+6,structureZ),and2)
                    
                end
            end
            local output=save:addBlock(15,i,currentY+7,structureZ)
            save:addOutput(output,"data")
            if i==1 then
                save:addConnection(xor1,output)
            else
                save:addConnection(save:findBlock(i,currentY+4,structureZ),output)
            end
        else 
            if i~=bits then

                local xor2=save:addBlock(3,i,currentY+4,structureZ)
                local and2=save:addBlock(1,i,currentY+5,structureZ)
                save:addConnection(xor1,xor2)
                save:addConnection(xor1,and2)
                if i~=1 then
                    local carryOr=save:addBlock(15,i,currentY+6,structureZ)
                    save:addConnection(and1,carryOr)
                    save:addConnection(and2,carryOr)
                end 
            end
            if i==bits then
                save:addConnection(and1,save:findBlock(i-1,currentY+4,structureZ))
                save:addConnection(and1,save:findBlock(i-1,currentY+5,structureZ))
            elseif i~=1 then
                save:addConnection(save:findBlock(i,currentY+6,structureZ),save:findBlock(i-1,currentY+4,structureZ))
                save:addConnection(save:findBlock(i,currentY+6,structureZ),save:findBlock(i-1,currentY+5,structureZ))
            end
            local output=save:addBlock(15,i,currentY+7,structureZ)
            if i~=bits then
                save:addConnection(save:findBlock(i,currentY+4,structureZ),output)
            else
                save:addConnection(save:findBlock(i,currentY+2,structureZ),output)
                
            end
        end

        
    end

    currentY=currentY+7
    return save
end

return structure
