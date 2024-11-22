-- SPDX-License-Identifier: GPL-3.0-only

local controls = {}

controls.keyboardKeys = {
    Q = 31,
    CTRL = 69
}

controls.defaultBindings = {
    keyboard = {
        enterEditingMode = "Q",
        exitEditingMode = "CTRL",
        showItemsList = "Q"
    }
}

function controls.loadSettings() 
    local configFilePath = Balltze.filesystem.getPluginPath() .. "\\controls.json"
    local config = Balltze.config.open(configFilePath)
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

return controls
