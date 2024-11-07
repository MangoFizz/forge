-- SPDX-License-Identifier: GPL-3.0-only

local function splitWords(input)
    local words = {}
    input = input:gsub("[-_%s]", " ")
    input = input:gsub("([a-z])([A-Z])", "%1 %2")
    for word in input:gmatch("%S+") do
        table.insert(words, word:lower())
    end
    return words
end

local function toPascalCase(input)
    local words = splitWords(input)
    for i = 1, #words do
        words[i] = words[i]:sub(1, 1):upper() .. words[i]:sub(2)
    end
    return table.concat(words)
end

local function toCamelCase(input)
    local words = splitWords(input)
    for i = 2, #words do
        words[i] = words[i]:sub(1, 1):upper() .. words[i]:sub(2)
    end
    return table.concat(words)
end

local function toSnakeCase(input)
    local words = splitWords(input)
    return table.concat(words, "_")
end

local function toKebabCase(input)
    local words = splitWords(input)
    return table.concat(words, "-")
end

local function toSentenceCase(input)
    local words = splitWords(input)
    words[1] = words[1]:sub(1, 1):upper() .. words[1]:sub(2)
    return table.concat(words, " ")
end

return {
    toPascalCase = toPascalCase,
    toCamelCase = toCamelCase,
    toSnakeCase = toSnakeCase,
    toKebabCase = toKebabCase,
    toSentenceCase = toSentenceCase
}
