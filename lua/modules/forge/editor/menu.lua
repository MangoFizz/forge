-- SPDX-License-Identifier: GPL-3.0-only

local menu = {}

function menu.openItemsList()
    local itemsListScreen = Forge.tags.widgets.itemsListScreen
    if itemsListScreen then
        Engine.userInterface.openWidget(itemsListScreen.handle, false)
    end
end

return menu
