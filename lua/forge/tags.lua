-- SPDX-License-Identifier: GPL-3.0-only

local luna = require "luna"
local naming = require "naming"

local filterTags = Engine.tag.filterTags
local getTagEntry = Engine.tag.getTagEntry
local lookupTag = Engine.tag.lookupTag

local paths = {
    widgets = {
        "forge\\ui\\editing_mode\\items_list\\items_list_screen",
        "forge\\ui\\editing_mode\\items_list\\items_list_select_list",
        "forge\\ui\\editing_mode\\items_list\\items_list_page_label",
        "forge\\ui\\editing_mode\\items_list\\nav_button_bar",
        "forge\\ui\\editing_mode\\items_list\\nav_next_btn",
        "forge\\ui\\editing_mode\\items_list\\nav_prev_btn",
        "forge\\ui\\editing_mode\\items_list\\items_list_item_1",
        "forge\\ui\\editing_mode\\items_list\\items_list_item_2",
        "forge\\ui\\editing_mode\\items_list\\items_list_item_3",
        "forge\\ui\\editing_mode\\items_list\\items_list_item_4",
        "forge\\ui\\editing_mode\\items_list\\items_list_item_5",
        "forge\\ui\\editing_mode\\items_list\\items_list_item_6"
    },
    collections = {
        "forge\\forge_objects"
    }
}

local tags = {}

function tags.getTagName(tag)
    local pathSplit = luna.string.split(tag.path, "\\")
    return pathSplit[#pathSplit]
end

local function loadUiWidgetTags()
    tags.widgets = {}
    for _, widgetTagPath in ipairs(paths.widgets) do
        local widgetTagHandle = lookupTag(widgetTagPath, "ui_widget_definition")
        if not widgetTagHandle:isNull() then
            local widgetTag = getTagEntry(widgetTagHandle)
            local tagName = tags.getTagName(widgetTag)
            local widgetName = naming.toCamelCase(tagName)
            tags.widgets[widgetName] = {
                handle = widgetTagHandle.value,
                path = widgetTag.path,
            }
        else
            Logger.warning("Widget tag not found: " .. widgetTagPath)
        end
    end
end

local function loadBipedTags()
    tags.bipeds = {}
    local characters = filterTags("biped", "characters")
    for _, bipedTag in ipairs(characters) do
        local tagName = tags.getTagName(bipedTag)
        local bipedName = naming.toCamelCase(tagName:gsub("_mp", ""))
        Logger.debug("Found biped tag: " .. bipedName)
        tags.bipeds[bipedName] = {
            handle = bipedTag.handle.value,
            path = bipedTag.path,
        }
    end
end

local function loadCollectionTags()
    tags.collections = {}
    for _, collectionTagPath in ipairs(paths.collections) do
        local collectionTagHandle = lookupTag(collectionTagPath, "tag_collection")
        if not collectionTagHandle:isNull() then
            local collectionTag = getTagEntry(collectionTagHandle)
            local tagName = tags.getTagName(collectionTag)
            local collectionName = naming.toCamelCase(tagName)
            tags.collections[collectionName] = {
                handle = collectionTagHandle.value,
                path = collectionTag.path,
            }
        else
            Logger.warning("Collection tag not found: " .. collectionTagPath)
        end
    end
end

function tags.findAll() 
    Logger.debug("Loading tags...")
    loadBipedTags()
    loadUiWidgetTags()
    loadCollectionTags()
end

function tags.clean()
    Logger.debug("Cleaning up tags...")
    tags.bipeds = nil
    tags.widgets = nil
    tags.collections = nil
end

---@param event MapLoadedEvent
local function onMapLoaded(event)
    tags.findAll()
end

function tags.setup()
    Balltze.addEventListener("map_loaded", onMapLoaded)
end

return tags
