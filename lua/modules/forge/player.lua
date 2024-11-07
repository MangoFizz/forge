-- SPDX-License-Identifier: GPL-3.0-only

local getObject = Engine.gameState.getObject
local getPlayer = Engine.gameState.getPlayer
local getTag = Engine.tag.getTag
local deleteObject = Engine.gameState.deleteObject
local objectTypes = Engine.tag.objectType
local tagClasses = Engine.tag.classes

local defaultState = {
    position = nil
}

local playerState = {}

function playerState:init()
    for k, v in pairs(defaultState) do
        self[k] = v
    end
end

function playerState:savePosition()
    local player = Engine.gameState.getPlayer()
    if player then
        self.position = {
            x = player.position.x,
            y = player.position.y,
            z = player.position.z
        }
    else
        self.position = nil
    end
end

---@param bipedTagHandle? EngineTagHandle|integer
local function swapBiped(bipedTagHandle) 
    local player = getPlayer()
    if not player or player.objectHandle:isNull() then
        return
    end

    playerState:savePosition()

    local playerObj = getObject(player.objectHandle, objectTypes.biped)
    if playerObj then
        playerObj.vitals.health = 1
        playerObj.vitals.shield = 1
        
        local globalsTag = getTag("globals\\globals", tagClasses.globals)
        if globalsTag then
            local globalsData = globalsTag.data
            local mpInfo = globalsData.multiplayerInformation.elements[1]
            if not bipedTagHandle then
                local tags = Forge.tags
                local monitorBiped = tags.bipeds.monitorNoLight
                local spartanBiped = tags.bipeds.cyborg
                if playerObj.tagHandle.value == monitorBiped.handle then
                    mpInfo.unit.tagHandle.value = spartanBiped.handle
                else
                    mpInfo.unit.tagHandle.value = monitorBiped.handle
                end
            else
                local bipedTag = getTag(bipedTagHandle, tagClasses.biped)
                if bipedTag then
                    mpInfo.unit.tagHandle = bipedTag.handle
                else
                    error("biped tag not found")
                end
            end
            deleteObject(player.objectHandle)
        end
    end
end

return {
    state = playerState,
    swapBiped = swapBiped
}
