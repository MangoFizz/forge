-- SPDX-License-Identifier: GPL-3.0-only

Logger = {}
Forge = {}

local tags = require "forge.tags"
local player = require "forge.player"

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
        if ev.time == "before" then
            if (not player.isMonitor and ev.context.keyCode == 31) or (player.isMonitor and ev.context.keyCode == 69) then -- "Q" / "Ctrl" key
                player:swapBiped()
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

    local currentMap = Engine.map.getCurrentMapHeader()
    if currentMap.name == "forge_legacy" then
        tags.findAll()
    end

    setUpEvents()

    Logger:info("Forge loaded!")
end
