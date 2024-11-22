-- SPDX-License-Identifier: GPL-3.0-only

Logger = {}
Forge = {}

local tags = require "forge.tags"
local player = require "forge.editor.player"
local menu = require "forge.editor.menu"
local controls = require "forge.editor.controls"

function PluginMetadata()
    return {
        name = "Forge",
        description = "A rewrite of Forge CE as a Balltze plugin.",
        author = "MangoFizz, Sledmine",
        version = "1.0.0",
        targetApi = "1.0.0",
        reloadable = true
    }
end

local function setUpEvents() 
    Balltze.event.mapLoad.subscribe(function (ev)
        if ev.time == "after" then
            if ev.context:mapName() == "forge_legacy" then
                tags.findAll()
            else
                player:clearState()
                tags.clean()
            end
        end
    end)

    Balltze.event.gameInput.subscribe(function (ev)
        if ev.time == "before" and not player.blockInput then
            if ev.context.device:label() == "keyboard" then
                local playerIsMonitor = player:isMonitor()
                local bindings = controls.keyboardBindings
                
                if (not playerIsMonitor and ev.context.keyCode == bindings.enterEditingMode) or 
                    (playerIsMonitor and ev.context.keyCode == bindings.exitEditingMode) then 
                    player:swapBiped()
                    player:setInputTimeout()
                end
    
                if playerIsMonitor and ev.context.keyCode == bindings.showItemsList then
                    menu.openItemsList()
                end
            end
        end
    end)

    Balltze.event.tick.subscribe(function (ev)
        if ev.time == "after" then
            player:restorePosition()
        end
    end)
end

function PluginInit()
    Logger = Balltze.logger.createLogger("Forge")
    return true
end

function PluginLoad()
    Forge.tags = tags
    Forge.player = player
    Forge.menu = menu
    Forge.controls = controls

    local currentMap = Engine.map.getCurrentMapHeader()
    if currentMap.name == "forge_legacy" then
        tags.findAll()
    end

    controls.loadSettings()

    setUpEvents()

    Balltze.features.setUIAspectRatio(16, 9)

    Logger:info("Forge loaded!")
end
