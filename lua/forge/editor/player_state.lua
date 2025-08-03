-- SPDX-License-Identifier: GPL-3.0-only

local editorTags = require "forge.tags"

local getObject = Engine.object.getObject
local getPlayer = Engine.player.getPlayer
local getTagData = Engine.tag.getTagData
local lookupTag = Engine.tag.lookupTag
local deleteObject = Engine.object.deleteObject

local defaultState = {
    savedPosition = { x = 0, y = 0, z = 0 },
    shouldRestoreSavedPosition = false,
    isInputBlocked = false,
    inEditingMode = false
}

local playerState = defaultState

-- Replace the player biped in the globals multiplayer info
local function swapBiped(tagHandle)
    local globalsTagHandle = lookupTag("globals\\globals", "globals")
    if not globalsTagHandle:isNull() then
        local globalsData = getTagData(globalsTagHandle, "globals")
        local mpInfo = globalsData.multiplayerInformation[1]
        mpInfo.unit.tagHandle.value = tagHandle
        deleteObject(getPlayer().unitHandle)
    end
end

-- Get the player biped object if it exists
---@return BipedObject|nil @player biped object if exists
function playerState.getBipedObject()
    local player = getPlayer()
    if player then
        return getObject(player.unitHandle, "biped")
    end
    return nil
end

-- Clear the player state to default values
function playerState:clearState()
    for k, v in pairs(defaultState) do
        self[k] = v
    end
end

-- Save the current player position
function playerState:savePosition()
    local playerBiped = self.getBipedObject()
    if playerBiped then
        self.savedPosition = {
            x = playerBiped.position.x,
            y = playerBiped.position.y,
            z = playerBiped.position.z
        }
        self.shouldRestoreSavedPosition = true
        Logger.debug("Player position saved: {}, {}, {}", self.savedPosition.x, self.savedPosition.y, self.savedPosition.z)
    else
        self.savedPosition = nil
    end
end

-- Restore the player position to the saved state
function playerState:restorePosition()
    if self.shouldRestoreSavedPosition then
        local playerBiped = self.getBipedObject()
        if playerBiped then
            Logger.debug("Restoring player position...")
            playerBiped.position.x = self.savedPosition.x
            playerBiped.position.y = self.savedPosition.y
            playerBiped.position.z = self.savedPosition.z + 0.1
            self.shouldRestoreSavedPosition = false
        end
    end
end

-- Entering editing mode; if already in editing mode do nothing
function playerState:enterEditingMode()
    if not self.inEditingMode then
        local playerBiped = self.getBipedObject()
        if playerBiped then
            Logger.debug("Entering editing mode...")
            self.inEditingMode = true
            self:savePosition()
            playerBiped.vitals.health = 1
            playerBiped.vitals.shield = 1
            swapBiped(editorTags.bipeds.monitorNoLight.handle)
        end
    end
end

-- Exit editing mode; if not in editing mode do nothing
function playerState:exitEditingMode()
    if self.inEditingMode then
        local playerBiped = self.getBipedObject()
        if playerBiped then
            Logger.debug("Exiting editing mode...")
            self.inEditingMode = false
            self:savePosition()
            playerBiped.vitals.health = 1
            playerBiped.vitals.shield = 1
            swapBiped(editorTags.bipeds.cyborg.handle)
        end
    end
end

local function onTick()
    playerState:restorePosition()
end

-- Set up the player state module
function playerState.setup()
    Balltze.addEventListener("tick", onTick)
end

return playerState
