-- SPDX-License-Identifier: GPL-3.0-only

local luna = require "luna"
local naming = require "naming"

local findTags = Engine.tag.findTags
local getTag = Engine.tag.getTag
local tagClasses = Engine.tag.classes

local paths = {
    widgets = {
        "forge\\ui\\editing_mode\\items_list\\items_list_screen"
    }
}

local tags = {}

function tags.getTagName(tag)
    local pathSplit = luna.string.split(tag.path, "\\")
    return pathSplit[#pathSplit]
end

function tags.findAll() 
    Logger:debug("Loading tags...")
    tags.bipeds = {}
    for _, bipedTag in ipairs(findTags("characters", tagClasses.biped)) do
        local tagName = tags.getTagName(bipedTag)
        local bipedName = naming.toCamelCase(tagName:gsub("_mp", ""))
        tags.bipeds[bipedName] = {
            handle = bipedTag.handle.value,
            path = bipedTag.path,
        }
    end

    tags.widgets = {}
    for _, widgetTagPath in ipairs(paths.widgets) do
        local widgetTag = getTag(widgetTagPath, tagClasses.uiWidgetDefinition)
        if widgetTag then
            local tagName = tags.getTagName(widgetTag)
            local widgetName = naming.toCamelCase(tagName)
            tags.widgets[widgetName] = {
                handle = widgetTag.handle.value,
                path = widgetTag.path,
            }
        else
            Logger:warn("Widget tag not found: " .. widgetTagPath)
        end
    end
end

function tags.clean()
    Logger:debug("Cleaning up tags...")
    tags.bipeds = nil
end

return tags
