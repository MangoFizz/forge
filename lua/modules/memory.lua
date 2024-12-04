-- SPDX-License-Identifier: GPL-3.0-only

-- Read/Write functions for unicode strings from lua-blam
-- https://github.com/Sledmine/lua-blam/

local readByte = Balltze.memory.readInt8
local writeByte = Balltze.memory.writeInt8
local writeWord = Balltze.memory.writeInt16

local memory = {}

--- Return the string of a unicode string given address
---@param address integer
---@param length? integer
---@return string|nil
function memory.readUnicodeStringToUtf8(address, length)
    if address == 0 then
        return nil
    end
    
    if length == 0 then
        return ""
    end

    local output = ""
    local i = 1
    while true do
        local char = readByte(address + (i-1)*2)
        if char == 0 then
            break
        end
        output = output .. string.char(char)
        if i == length then
            break
        end
        i = i + 1
    end
    return output
end

--- Writes a unicode string in a given address
---@param address number
---@param str string
---@param length? integer
function memory.writeUnicodeString(address, str, length)
    if address == 0 or length == 0 then
        return
    end

    local input = tostring(str)
    local i = 1
    while i <= input:len() and i ~= length do
        local char = input:byte(i)
        writeByte(address + (i-1)*2, char)
        writeByte(address + (i-1)*2 + 1, 0)
        i = i + 1
    end
    writeWord(address + (i-1)*2, 0)
end

return memory
