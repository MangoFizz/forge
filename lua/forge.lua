-- SPDX-License-Identifier: GPL-3.0-only

Logger = Balltze.logger

local forgeTags = require "forge.tags"
local editorControls = require "forge.editor.controls"
local editorPlayer = require "forge.editor.player_state"
local editorMenu = require "forge.editor.menu"

forgeTags.setup()
editorControls.setup()
editorPlayer.setup()
editorMenu.setup()

Logger.info("Forge loaded!")
