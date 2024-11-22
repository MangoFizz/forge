-- SPDX-License-Identifier: GPL-3.0-only

local getObject = Engine.gameState.getObject
local getPlayer = Engine.gameState.getPlayer
local getTag = Engine.tag.getTag
local deleteObject = Engine.gameState.deleteObject
local objectTypes = Engine.tag.objectType
local tagClasses = Engine.tag.classes

local defaultState = {
    savedPosition = nil,
    blockInput = false
}

local playerState = defaultState
local inputTimeoutTimer

---@return MetaEngineBaseObject|MetaEngineBipedObject|nil @player biped object if exists
function playerState.getBipedObject()
    local player = getPlayer()
    if player then
        return getObject(player.objectHandle, objectTypes.biped)
    end
    return nil
end

function playerState:clearState()
    for k, v in pairs(defaultState) do
        self[k] = v
    end
end

function playerState:savePosition()
    local playerBiped = self.getBipedObject()
    if playerBiped then
        Logger:debug("Saving player position...")
        self.savedPosition = {
            x = playerBiped.position.x,
            y = playerBiped.position.y,
            z = playerBiped.position.z
        }
    else
        self.savedPosition = nil
    end
end

function playerState:restorePosition()
    if self.savedPosition then
        local playerBiped = self.getBipedObject()
        if playerBiped then
            Logger:debug("Restoring player position...")
            playerBiped.position.x = self.savedPosition.x
            playerBiped.position.y = self.savedPosition.y
            playerBiped.position.z = self.savedPosition.z + 0.1
            self.savedPosition = nil
        end
    end
end

function playerState:isMonitor()
    local playerBiped = self.getBipedObject()
    if playerBiped then
        return playerBiped.tagHandle.value == Forge.tags.bipeds.monitorNoLight.handle
    end
    return false
end

---@param bipedTagHandle? EngineTagHandle|integer
function playerState:swapBiped(bipedTagHandle) 
    local playerBiped = self.getBipedObject()
    if playerBiped then
        self:savePosition()
        playerBiped.vitals.health = 1
        playerBiped.vitals.shield = 1
        
        local globalsTag = getTag("globals\\globals", tagClasses.globals)
        if globalsTag then
            local globalsData = globalsTag.data
            local mpInfo = globalsData.multiplayerInformation.elements[1]
            local tags = Forge.tags
            local monitorBiped = tags.bipeds.monitorNoLight
            local spartanBiped = tags.bipeds.cyborg
            if not bipedTagHandle then
                if playerBiped.tagHandle.value == monitorBiped.handle then
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

            local player = getPlayer()
            deleteObject(player.objectHandle)
        end
    end
end

function playerState:setInputTimeout()
    playerState.blockInput = true
    inputTimeoutTimer = Balltze.misc.setTimer(500, function()
        playerState.blockInput = false
        inputTimeoutTimer.stop()
    end)    
end

return playerState
