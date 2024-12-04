-- SPDX-License-Identifier: GPL-3.0-only

local getTag = Engine.tag.getTag
local tagClasses = Engine.tag.classes
local naming = require "naming"

local memory = require "memory"

local menu = {}
local currentMenuState = {
    widgetDefinition = nil,
}

local itemsList = {}
local itemsListElemsPerPage = 6
local itemsListStringLen = 18

local function populateItemsList()
    if #itemsList > 0 then
        return
    end
    
    itemsList = {}
    local itemsTagCollection = Forge.tags.collections.forgeObjects
    local tag = getTag(itemsTagCollection.handle, tagClasses.tagCollection)
    if not tag then
        Logger:warning("Items tag collection not found.")
        return
    end

    local tagsList = tag.data.tags
    for i = 1, tagsList.count, 1 do
        local entry = tagsList.elements[i]
        local sceneryTag = getTag(entry.reference.tagHandle, tagClasses.scenery)
        if sceneryTag then
            local tagName = Forge.tags.getTagName(sceneryTag)
            local sceneryName = naming.toSentenceCase(tagName)
            itemsList[i] = {
                name = sceneryName,
                handle = sceneryTag.handle.value
            }
        end
    end
end

local function itemsListSetPage(pageIndex) 
    local totalPages = math.ceil(#itemsList / itemsListElemsPerPage)

    if pageIndex < 1 then
        pageIndex = 1
    elseif pageIndex > totalPages then
        pageIndex = totalPages
    end

    if currentMenuState.widgetDefinition ~= Forge.tags.widgets.itemsListScreen.handle then
        Logger:warning("Items list screen widget definition mismatch. {} vs {}", currentMenuState.widgetDefinition, Forge.tags.widgets.itemsListScreen.handle)
        return
    end

    local selectListWidget = Forge.tags.widgets.itemsListSelectList
    if not selectListWidget then
        Logger:warning("Items list select list widget not found.")
        return
    end

    local selectListWidgetTag = getTag(selectListWidget.handle, tagClasses.uiWidgetDefinition)
    if not selectListWidgetTag then
        Logger:warning("Items list select list widget tag not found.")
        return
    end

    local selectListWidgetData = selectListWidgetTag.data
    local selectListWidgetItems = selectListWidgetData.childWidgets
    for i = 1, 6, 1 do
        local childWidget = selectListWidgetItems.elements[i]
        local childWidgetTag = getTag(childWidget.widgetTag.tagHandle, tagClasses.uiWidgetDefinition)
        if not childWidgetTag then
            Logger:warning("Items list select list child widget tag not found.")
            return
        end

        local childWidgetData = childWidgetTag.data
        local stringIndex = childWidgetData.stringListIndex
        local unicodeString = childWidgetData.textLabelUnicodeStringsList.tagHandle
        local unicodeStringTag = getTag(unicodeString, tagClasses.unicodeStringList)
        if not unicodeStringTag then
            Logger:warning("Items list select list child widget unicode string tag not found.")
            return
        end

        local unicodeStringData = unicodeStringTag.data
        local childWidgetLabel = unicodeStringData.strings.elements[stringIndex + 1].string
        local itemIndex = (pageIndex - 1) * itemsListElemsPerPage + i
        if itemsList[itemIndex] then
            memory.writeUnicodeString(childWidgetLabel.pointer, itemsList[itemIndex].name, itemsListStringLen)
        end
    end

    -- Update page label
    local pageLabelWidget = Forge.tags.widgets.itemsListPageLabel
    if not pageLabelWidget then
        Logger:warning("Items list page label widget not found.")
        return
    end

    local pageLabelWidgetTag = getTag(pageLabelWidget.handle, tagClasses.uiWidgetDefinition)
    if not pageLabelWidgetTag then
        Logger:warning("Items list page label widget tag not found.")
        return
    end

    local pageLabelWidgetData = pageLabelWidgetTag.data
    local pageLabelWidgetStringIndex = pageLabelWidgetData.stringListIndex
    local pageLabelWidgetUnicodeString = pageLabelWidgetData.textLabelUnicodeStringsList.tagHandle
    local pageLabelWidgetUnicodeStringTag = getTag(pageLabelWidgetUnicodeString, tagClasses.unicodeStringList)
    if not pageLabelWidgetUnicodeStringTag then
        Logger:warning("Items list page label widget unicode string tag not found.")
        return
    end

    local pageLabelWidgetUnicodeStringData = pageLabelWidgetUnicodeStringTag.data
    local pageLabelWidgetLabel = pageLabelWidgetUnicodeStringData.strings.elements[pageLabelWidgetStringIndex + 1].string
    memory.writeUnicodeString(pageLabelWidgetLabel.pointer, pageIndex .. "/" .. totalPages, itemsListStringLen)

    currentMenuState.currentPage = pageIndex
end

function menu.openItemsList()
    local widgets = Forge.tags.widgets
    local itemsListScreen = widgets.itemsListScreen.handle
    if itemsListScreen then
        currentMenuState = {
            widgetDefinition = itemsListScreen,
            currentPage = 1
        }
        currentMenuState.listeners = {
            onAccept = {
                [widgets.navNextBtn.handle] = function()
                    itemsListSetPage(currentMenuState.currentPage + 1)
                end,
                [widgets.navPrevBtn.handle] = function()
                    itemsListSetPage(currentMenuState.currentPage - 1)
                end
            }
        }
        populateItemsList()
        itemsListSetPage(1)
        Engine.userInterface.openWidget(itemsListScreen, false)
    end
end

---@type BalltzeUIWidgetAcceptEventCallback
function menu.acceptEventHandler(ev)
    if ev.time == "before" then
        local listeners = currentMenuState.listeners.onAccept
        if listeners then
            local widgetHandle = ev.context.widget.definitionTagHandle.value
            local listener = listeners[widgetHandle]
            if listener then
                listener()
            end
        end
    end
end

return menu
