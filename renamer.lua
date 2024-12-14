local renamer = {}

local function extract_identifiers(code)
    local identifiers = {}
    local seen_identifiers = {}

    local patterns = {"local%s+([%w_]+)", "([%w_]+)%s*=", "function%s*[%w_]*%(([^%)]+)%)", "for%s+([%w_]+)%s*=",
                      "for%s+([%w_]+),%s*([%w_]+)%s+in%s+ipairs%(", "([%w_]+):[%w_]+%(", "if%s+([%w_]+)%s*==",
                      "function%s+([%w_]+):[%w_]+%(", ":[%s]*([%w_]+)%s*%(", "function[%s]*[%w_]+:[%w_]+%(([^%)]+)%)"}

    for _, pattern in ipairs(patterns) do
        for identifier in code:gmatch(pattern) do
            if not seen_identifiers[identifier] and not identifier:match(
                "^(and|break|do|else|elseif|end|false|for|function|goto|if|in|local|nil|not|or|repeat|return|then|true|until|while)$") then
                table.insert(identifiers, identifier)
                seen_identifiers[identifier] = true
            end
        end
    end

    return identifiers
end

local function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

function renamer.rename(code)
    local identifiers = extract_identifiers(code)
    local rename_map = {}

    for i, identifier in ipairs(identifiers) do
        rename_map[identifier] = string.format("v%d", i)
    end

    local renamed_code = code
    for original, replacement in pairs(rename_map) do
        local escaped_original = escape_pattern(original)
        renamed_code = renamed_code:gsub("(%f[%w_])" .. escaped_original .. "(%f[^%w_])", "%1" .. replacement .. "%2")
    end

    renamed_code = renamed_code:gsub('(["\'])(.-)%1', function(quote, str)
        local restored_str = str
        for original, replacement in pairs(rename_map) do
            restored_str = restored_str:gsub(escape_pattern(replacement), original)
        end
        return quote .. restored_str .. quote
    end)

    return renamed_code
end

return renamer
