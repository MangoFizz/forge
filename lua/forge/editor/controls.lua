-- SPDX-License-Identifier: GPL-3.0-only

local editorMenu = require "forge.editor.menu"
local playerState = require "forge.editor.player_state"

local getPluginPath = Balltze.filesystem.getPluginPath
local openConfigFile = Balltze.openConfigFile
local setTimer = Balltze.setTimer

local controls = {}
local inputTimeoutTimer
local isInputBlocked = false

controls.keyboardKeys = {
    Q = 31,
    CTRL = 69
}

controls.defaultBindings = {
    keyboard = {
        enterEditingMode = "Q",
        exitEditingMode = "CTRL",
        showItemsList = "E"
    }
}

-- Load keyboard bindings from config file
local function loadSettings() 
    local configFilePath = getPluginPath() .. "\\settings\\controls.json"
    local config = openConfigFile(configFilePath)
    controls.keyboardBindings = {}
    for key, _ in pairs(controls.defaultBindings.keyboard) do
        local value = config:getString("keyboard." .. key)
        if not value then
            value = controls.defaultBindings.keyboard[key]
            config:set("keyboard." .. key, value)
        end
        controls.keyboardBindings[key] = controls.keyboardKeys[value]
    end
    config:save()
end

-- Set a timeout to block input for a short duration 
local function setInputTimeout()
    isInputBlocked = true
    inputTimeoutTimer = setTimer(500, function()
        isInputBlocked = false
        inputTimeoutTimer.stop()
    end)    
end

---@param event PlayerInputEvent
local function onPlayerInput(event)
    if not isInputBlocked then
        if event:getDevice() == "keyboard" then
            local bindings = controls.keyboardBindings
            local keyCode = event:getKeyCode()

            if playerState.inEditingMode then
                if keyCode == bindings.exitEditingMode then
                    playerState:exitEditingMode()
                    setInputTimeout()

                elseif keyCode == bindings.showItemsList then
                    editorMenu.openItemsList()
                    event:cancel()
                end
            else
                if keyCode == bindings.enterEditingMode then
                    playerState:enterEditingMode()
                    setInputTimeout()
                end
            end
        end
    end
end

-- Set up the editor controls module
function controls.setup() 
    loadSettings()
    Balltze.addEventListener("player_input", onPlayerInput)
end

return controls
