local renamer = {}

function renamer.rename(code)
    local names = {}
    local counter = 1
    local displayNames = {}

    local function is_valid_identifier(str)
        return str:match('^[_%a][_%w]*$')
    end

    local function escape_pattern(str)
        return str:gsub('([%(%)%.%%%+%-%*%?%[%^%$%]])', '%%%1')
    end

    local renamedCode = code:gsub('local%s+([%w_,]+)', function(vars)
        local renamedVars = {}
        for var in vars:gmatch('[%w_]+') do
            if not names[var] and is_valid_identifier(var) then
                names[var] = 'var' .. counter
                displayNames[names[var]] = var
                counter = counter + 1
            end
            table.insert(renamedVars, names[var] or var)
        end
        return 'local ' .. table.concat(renamedVars, ', ')
    end)

    renamedCode = renamedCode:gsub('([%w_]+)%s*:%s*([%w_]+)', function(obj, method)
        if is_valid_identifier(obj) and is_valid_identifier(method) then
            if not names[obj] then
                names[obj] = 'var' .. counter
                displayNames[names[obj]] = obj
                counter = counter + 1
            end
            if not names[method] then
                names[method] = 'var' .. counter
                displayNames[names[method]] = method
                counter = counter + 1
            end
            return names[obj] .. ':' .. names[method]
        else
            return obj .. ':' .. method
        end
    end)

    local function rename_identifier(identifier)
        if names[identifier] then
            return names[identifier]
        else
            return identifier
        end
    end

    renamedCode = renamedCode:gsub('([%w_]+)%s*%(%s*([%w_]+)%s*%)', function(func, param)
        if is_valid_identifier(func) and is_valid_identifier(param) then
            return rename_identifier(func) .. '(' .. rename_identifier(param) .. ')'
        else
            return func .. '(' .. param .. ')'
        end
    end)

    renamedCode = renamedCode:gsub('([%w_]+)%s*([=~<>!]+)%s*([%w_]+)', function(left, op, right)
        if is_valid_identifier(left) and is_valid_identifier(right) then
            return rename_identifier(left) .. ' ' .. op .. ' ' .. rename_identifier(right)
        else
            return left .. ' ' .. op .. ' ' .. right
        end
    end)

    renamedCode = renamedCode:gsub('if%s+([%w_]+)%.([%w_]+)%s*==', function(obj, prop)
        if is_valid_identifier(obj) and is_valid_identifier(prop) then
            return 'if ' .. rename_identifier(obj) .. '.' .. rename_identifier(prop) .. ' =='
        else
            return 'if ' .. obj .. '.' .. prop .. ' =='
        end
    end)

    renamedCode = renamedCode:gsub('do%s+if%s+([%w_]+)%.([%w_]+)%s*==', function(obj, prop)
        if is_valid_identifier(obj) and is_valid_identifier(prop) then
            return 'do if ' .. rename_identifier(obj) .. '.' .. rename_identifier(prop) .. ' =='
        else
            return 'do if ' .. obj .. '.' .. prop .. ' =='
        end
    end)

    renamedCode = renamedCode:gsub('([%w_]+)%s*:%s*([%w_]+)%s*%(%s*([%w_.]+)%s*%)', function(obj, method, param)
        local renamedObj = rename_identifier(obj)
        local renamedMethod = rename_identifier(method)
        local renamedParam = param:gsub('([%w_]+)', rename_identifier)
        return renamedObj .. ':' .. renamedMethod .. '(' .. renamedParam .. ')'
    end)

    renamedCode = renamedCode:gsub('([%w_.]+)%s*%(', function(func)
        local renamedFunc = func:gsub('([%w_]+)', rename_identifier)
        return renamedFunc .. '('
    end)

    renamedCode = renamedCode:gsub('do%s+if%s+([%w_]+)%.([%w_]+)%s*==%s*([%w_]+)%s+then', function(obj, prop, value)
        local renamedObj = rename_identifier(obj)
        local renamedProp = rename_identifier(prop)
        local renamedValue = rename_identifier(value)
        return 'do if ' .. renamedObj .. '.' .. renamedProp .. ' == ' .. renamedValue .. ' then'
    end)

    renamedCode = renamedCode:gsub(
        'for%s+([%w_]+)%s*,%s+([%w_]+)%s+in%s+ipairs%s*%(%s*([%w_]+)%s*%)%s+do%s+if%s+([%w_]+)%.([%w_]+)%s*==%s*([%w_]+)%s+then',
        function(index, item, items, obj, prop, value)
            local renamedIndex = rename_identifier(index)
            local renamedItem = rename_identifier(item)
            local renamedItems = rename_identifier(items)
            local renamedObj = rename_identifier(obj)
            local renamedProp = rename_identifier(prop)
            local renamedValue = rename_identifier(value)
            return 'for ' .. renamedIndex .. ', ' .. renamedItem .. ' in ipairs(' .. renamedItems .. ') do if ' ..
                       renamedObj .. '.' .. renamedProp .. ' == ' .. renamedValue .. ' then'
        end)

    for oldName, newName in pairs(names) do
        local escapedOldName = escape_pattern(oldName)

        renamedCode = renamedCode:gsub('([^%w_:])' .. escapedOldName .. '([^%w_])', function(a, b)
            if a == '.' or b == '.' then
                return a .. oldName .. b
            end
            return a .. newName .. b
        end)
        renamedCode = renamedCode:gsub('^' .. escapedOldName .. '([^%w_])', function(a)
            if a == '.' then
                return oldName .. a
            end
            return newName .. a
        end)
        renamedCode = renamedCode:gsub('([^%w_])' .. escapedOldName .. '$', function(a)
            if a == '.' then
                return a .. oldName
            end
            return a .. newName
        end)
        renamedCode = renamedCode:gsub('^' .. escapedOldName .. '$', newName)
    end

    renamedCode = renamedCode:gsub('(["\'])(.-)%1', function(quote, str)
        local newStr = str
        for newName, displayName in pairs(displayNames) do
            local escapedDisplayName = escape_pattern(displayName)
            newStr = newStr:gsub('{([_%w]*)}', function(innerContent)
                if innerContent == displayName then
                    return '{' .. newName .. '}'
                else
                    return '{' .. innerContent .. '}'
                end
            end)
        end
        return quote .. newStr .. quote
    end)

    return renamedCode
end

return renamer
