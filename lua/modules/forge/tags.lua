-- SPDX-License-Identifier: GPL-3.0-only

local luna = require "luna"
local naming = require "naming"

local findTags = Engine.tag.findTags
local tagClasses = Engine.tag.classes

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
end

function tags.clean()
    Logger:debug("Cleaning up tags...")
    tags.bipeds = nil
end

return tags
