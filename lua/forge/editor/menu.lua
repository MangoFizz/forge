-- SPDX-License-Identifier: GPL-3.0-only

local naming = require "naming"
local memory = require "memory"
local forgeTags = require "forge.tags"

local getTagData = Engine.tag.getTagData
local getTagEntry = Engine.tag.getTagEntry
local launchWidget = Engine.uiWidget.launchWidget
local findWidgets = Engine.uiWidget.findWidgets
local focusWidget = Engine.uiWidget.focusWidget
local unfocusWidget = Engine.uiWidget.unfocusWidget
local enableWidget = Engine.uiWidget.enableWidget
local disableWidget = Engine.uiWidget.disableWidget

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
    local itemsTagCollection = forgeTags.collections.forgeObjects
    local tagCollection = getTagData(itemsTagCollection.handle, "tag_collection")
    if not tagCollection then
        Logger.warning("Items tag collection not found.")
        return
    end

    for index, tag in ipairs(tagCollection.tags) do
        local sceneryTagEntry = getTagEntry(tag.reference.tagHandle)
        local tagName = forgeTags.getTagName(sceneryTagEntry)
        local sceneryName = naming.toSentenceCase(tagName)
        itemsList[index] = {
            name = sceneryName,
            handle = sceneryTagEntry.handle.value
        }
    end
end

local function updateItemsSelectListWidget(pageIndex)
    local selectListWidget = forgeTags.widgets.itemsListSelectList
    if not selectListWidget then
        Logger.warning("Items list select list widget not found.")
        return
    end
    
    local listWidgetDefinition = getTagData(selectListWidget.handle, "ui_widget_definition")
    if not listWidgetDefinition then
        Logger.warning("Items list select list widget tag not found.")
        return
    end

    for i = 1, 6, 1 do
        local childWidget = listWidgetDefinition.childWidgets[i]
        local childWidgetDefinition = getTagData(childWidget.widgetTag.tagHandle, "ui_widget_definition")
        if not childWidgetDefinition then
            Logger.warning("Items list select list child widget tag not found.")
            return
        end

        local stringIndex = childWidgetDefinition.stringListIndex
        local unicodeStringListTagHandle = childWidgetDefinition.textLabelUnicodeStringsList.tagHandle
        local unicodeStringList = getTagData(unicodeStringListTagHandle, "unicode_string_list")
        if not unicodeStringList then
            Logger.warning("Items list select list child widget unicode string list tag not found.")
            return
        end

        local btnWidget = findWidgets(childWidget.widgetTag.tagHandle, nil, true)[1]
        local childWidgetLabel = unicodeStringList.strings[stringIndex + 1].string
        local itemIndex = (pageIndex - 1) * itemsListElemsPerPage + i
        if itemsList[itemIndex] then
            memory.writeUnicodeString(childWidgetLabel.pointer, itemsList[itemIndex].name, itemsListStringLen)
            if btnWidget then
                enableWidget(btnWidget)
            end
        else
            memory.writeUnicodeString(childWidgetLabel.pointer, " ", 1)
            if btnWidget then
                disableWidget(btnWidget)
            end
            if btnWidget.parent.focusedChild == btnWidget then
                focusWidget(btnWidget.parent.child)
            end
        end
    end
end

local function updateItemsPageLabel(pageIndex, totalPages)
    -- Update page label
    local pageLabelWidget = forgeTags.widgets.itemsListPageLabel
    if not pageLabelWidget then
        Logger.warning("Items list page label widget not found.")
        return
    end

    local pageLabelWidgetDefinition = getTagData(pageLabelWidget.handle, "ui_widget_definition")
    if not pageLabelWidgetDefinition then
        Logger.warning("Items list page label widget tag not found.")
        return
    end

    local pageLabelWidgetStringIndex = pageLabelWidgetDefinition.stringListIndex
    local pageLabelStringTagHandle = pageLabelWidgetDefinition.textLabelUnicodeStringsList.tagHandle
    local pageLabelUnicodeStringList = getTagData(pageLabelStringTagHandle, "unicode_string_list")
    if not pageLabelUnicodeStringList then
        Logger.warning("Items list page label widget unicode string tag not found.")
        return
    end

    local pageLabelWidgetLabel = pageLabelUnicodeStringList.strings[pageLabelWidgetStringIndex + 1].string
    memory.writeUnicodeString(pageLabelWidgetLabel.pointer, pageIndex .. "/" .. totalPages, itemsListStringLen)
end

local function updateButtonBar(pageIndex, totalPages)
    local prevButtonWidget = findWidgets(forgeTags.widgets.navPrevBtn.handle, nil, true)[1]
    if prevButtonWidget then
        if pageIndex == 1 then
            disableWidget(prevButtonWidget)
        else
            enableWidget(prevButtonWidget)
        end
    end

    local nextButtonWidget = findWidgets(forgeTags.widgets.navNextBtn.handle, nil, true)[1]
    if nextButtonWidget then
        if pageIndex == totalPages then
            disableWidget(nextButtonWidget)
        else
            enableWidget(nextButtonWidget)
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

    if currentMenuState.widgetDefinition ~= forgeTags.widgets.itemsListScreen.handle then
        Logger.warning("Items list screen widget definition mismatch. {} vs {}", currentMenuState.widgetDefinition, forgeTags.widgets.itemsListScreen.handle)
        return
    end
    
    updateItemsSelectListWidget(pageIndex)
    updateItemsPageLabel(pageIndex, totalPages)
    updateButtonBar(pageIndex, totalPages)

    currentMenuState.currentPage = pageIndex
end

function menu.openItemsList()
    local widgets = forgeTags.widgets
    local itemsListScreen = widgets.itemsListScreen.handle
    if itemsListScreen then
        currentMenuState = {
            widgetDefinition = itemsListScreen,
            currentPage = 1
        }
        
        local previousPage = function(widget)
            itemsListSetPage(currentMenuState.currentPage - 1)
        end
        
        local nextPage = function(widget)
            itemsListSetPage(currentMenuState.currentPage + 1)
        end
        
        local initialize = function(widget)
            populateItemsList()
            itemsListSetPage(1)
        end

        currentMenuState.listeners = {
            ["a_button"] = {
                [widgets.navNextBtn.handle] = nextPage,
                [widgets.navPrevBtn.handle] = previousPage
            },
            ["dpad_left"] = {
                [widgets.itemsListItem1.handle] = previousPage,
                [widgets.itemsListItem2.handle] = previousPage,
                [widgets.itemsListItem3.handle] = previousPage,
                [widgets.itemsListItem4.handle] = previousPage,
                [widgets.itemsListItem5.handle] = previousPage,
                [widgets.itemsListItem6.handle] = previousPage
            },
            ["dpad_right"] = {
                [widgets.itemsListItem1.handle] = nextPage,
                [widgets.itemsListItem2.handle] = nextPage,
                [widgets.itemsListItem3.handle] = nextPage,
                [widgets.itemsListItem4.handle] = nextPage,
                [widgets.itemsListItem5.handle] = nextPage,
                [widgets.itemsListItem6.handle] = nextPage
            },
            ["created"] = {
                [widgets.itemsListScreen.handle] = initialize
            }
        }
        launchWidget(itemsListScreen)
    end
end

---@param event WidgetEventDispatchEvent
local function onWidgetEventDispatch(event)
    local widget = event:getWidget()
    local eventHandler = event:getEventHandlerReference()
    local widgetHandle = widget.definitionTagHandle.value

    Logger.debug("Widget event dispatch: {} for widget {}", eventHandler.eventType, widget.name)

    local eventListeners = currentMenuState.listeners[eventHandler.eventType]
    if eventListeners then
        local listener = eventListeners[widgetHandle]
        if listener then
            listener(widget)
        end
    end
end

function menu.setup()
    Balltze.addEventListener("widget_event_dispatch", onWidgetEventDispatch)
end

return menu
