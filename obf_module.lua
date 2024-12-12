local obfuscator = {}

local function generate_complex_name(length)
    length = length or math.random(30, 50)
    local chars = {}
    local char_sets = {{48, 57}, {65, 90}, {97, 122}, {95, 95}}

    for i = 1, length do
        local set = char_sets[math.random(#char_sets)]
        chars[i] = string.char(math.random(set[1], set[2]))
    end

    return "_" .. table.concat(chars)
end

local function encrypt_arithmetic(code)
    local operations = {
        ["+"] = function(a, b)
            return a + b
        end,
        ["-"] = function(a, b)
            return a - b
        end,
        ["*"] = function(a, b)
            return a * b
        end,
        ["/"] = function(a, b)
            return a / b
        end,
        ["%"] = function(a, b)
            return a % b
        end
    }

    local function generate_math_wrapper()
        local math_wrapper_name = generate_complex_name()
        local op_names = {}
        for _ = 1, 5 do
            table.insert(op_names, generate_complex_name())
        end

        local wrapper_code = string.format(
            [[local %s={["%s"]=function(a,b)return a+b end,["%s"]=function(a,b)return a-b end,["%s"]=function(a,b)return a*b end,["%s"]=function(a,b)return a/b end,["%s"]=function(a,b)return a%%b end}
]], math_wrapper_name, op_names[1], op_names[2], op_names[3], op_names[4], op_names[5])

        return math_wrapper_name, wrapper_code, op_names
    end

    local math_wrapper_name, math_wrapper_code, op_names = generate_math_wrapper()

    local op_map = {
        ["+"] = op_names[1],
        ["-"] = op_names[2],
        ["*"] = op_names[3],
        ["/"] = op_names[4],
        ["%"] = op_names[5]
    }

    local function encrypt_number(num)
        local num_str = tostring(num)
        local encrypted = {}
        local key = math.random(1, 255)
        for i = 1, #num_str do
            encrypted[i] = string.format("%d", num_str:byte(i) ~ key)
        end
        return string.format("({%s},%d)", table.concat(encrypted, ","), key)
    end

    local function decode_number_func()
        local decode_func_name = generate_complex_name()
        return string.format(
            [[local function %s(t,k)local r="" for i,v in ipairs(t) do r=r..string.char(v~k) end return tonumber(r) end
]], decode_func_name), decode_func_name
    end

    local decode_num_code, decode_num_name = decode_number_func()

    code = decode_num_code .. code

    code = code:gsub("([%d%.]+)%s*([%+%-%*%/%%])%s*([%d%.]+)", function(a, op, b)
        local wrapped_op = string.format("%s['%s'](%s,%s)", math_wrapper_name, op_map[op],
            decode_num_name .. encrypt_number(a), decode_num_name .. encrypt_number(b))
        return wrapped_op
    end)

    return math_wrapper_code .. code
end

local function encrypt_function_calls(code)
    local function_wrapper_name = generate_complex_name()
    local print_func_name = generate_complex_name()
    local math_random_name = generate_complex_name()
    local string_char_name = generate_complex_name()
    local table_insert_name = generate_complex_name()
    local table_concat_name = generate_complex_name()
    local string_format_name = generate_complex_name()
    local string_byte_name = generate_complex_name()
    local string_gsub_name = generate_complex_name()
    local os_time_name = generate_complex_name()
    local math_floor_name = generate_complex_name()
    local math_abs_name = generate_complex_name()
    local string_len_name = generate_complex_name()
    local string_sub_name = generate_complex_name()

    local wrapper_code = string.format(
        [[local %s={["%s"]=print,["%s"]=math.random,["%s"]=string.char,["%s"]=table.insert,["%s"]=table.concat,["%s"]=string.format,["%s"]=string.byte,["%s"]=string.gsub,["%s"]=os.time,["%s"]=math.floor,["%s"]=math.abs,["%s"]=string.len,["%s"]=string.sub}
]], function_wrapper_name, print_func_name, math_random_name, string_char_name, table_insert_name, table_concat_name,
        string_format_name, string_byte_name, string_gsub_name, os_time_name, math_floor_name, math_abs_name,
        string_len_name, string_sub_name)

    code = code:gsub("(%w+)(%s*%)?)%s*%(", function(func_name, trailing)
        local obfuscated_func = function_wrapper_name .. "['"
        if func_name == "print" then
            obfuscated_func = obfuscated_func .. print_func_name
        elseif func_name == "math.random" then
            obfuscated_func = obfuscated_func .. math_random_name
        elseif func_name == "string.char" then
            obfuscated_func = obfuscated_func .. string_char_name
        elseif func_name == "table.insert" then
            obfuscated_func = obfuscated_func .. table_insert_name
        elseif func_name == "table.concat" then
            obfuscated_func = obfuscated_func .. table_concat_name
        elseif func_name == "string.format" then
            obfuscated_func = obfuscated_func .. string_format_name
        elseif func_name == "string.byte" then
            obfuscated_func = obfuscated_func .. string_byte_name
        elseif func_name == "string.gsub" then
            obfuscated_func = obfuscated_func .. string_gsub_name
        elseif func_name == "os.time" then
            obfuscated_func = obfuscated_func .. os_time_name
        elseif func_name == "math.floor" then
            obfuscated_func = obfuscated_func .. math_floor_name
        elseif func_name == "math.abs" then
            obfuscated_func = obfuscated_func .. math_abs_name
        elseif func_name == "string.len" then
            obfuscated_func = obfuscated_func .. string_len_name
        elseif func_name == "string.sub" then
            obfuscated_func = obfuscated_func .. string_sub_name
        else
            return func_name .. trailing .. "("
        end
        return obfuscated_func .. "']" .. trailing .. "("
    end)

    return wrapper_code .. code
end

local function encrypt_strings(code)
    local function encrypt_string(str)
        local encrypted = {}
        local key = math.random(1, 255)
        for i = 1, #str do
            encrypted[i] = string.format("%d", str:byte(i) ~ key)
        end
        return string.format("({%s},%d)", table.concat(encrypted, ","), key)
    end

    local function decode_string_func()
        local decode_func_name = generate_complex_name()
        return string.format(
            [[local function %s(t,k)local r="" for i,v in ipairs(t) do r=r..string.char(v~k) end return r end
]], decode_func_name), decode_func_name
    end

    local decode_func_code, decode_func_name = decode_string_func()

    code = code:gsub('"([^"]*)"', function(match)
        return decode_func_name .. encrypt_string(match)
    end)
    code = code:gsub("'([^']*)'", function(match)
        return decode_func_name .. encrypt_string(match)
    end)

    code = decode_func_code .. code

    return code
end

local function add_junk_code(code)
    local junk_lines = {}
    local num_junk_lines = math.random(20, 40)
    for _ = 1, num_junk_lines do
        local junk_var_name = generate_complex_name()
        local junk_value = math.random(100000, 999999)
        local junk_ops = {"+", "-", "*", "/", "%"}
        local junk_op = junk_ops[math.random(1, #junk_ops)]
        local junk_value2 = math.random(100000, 999999)
        local junk_line = string.format("local %s = %d %s %d", junk_var_name, junk_value, junk_op, junk_value2)
        table.insert(junk_lines, junk_line)

        local junk_if_var = generate_complex_name()
        local junk_if_condition = math.random(0, 1)
        table.insert(junk_lines, string.format("local %s = %d", junk_if_var, junk_if_condition))

        local nested_junk_lines = {}
        local num_nested_junk = math.random(2, 5)
        for _ = 1, num_nested_junk do
            local nested_junk_var = generate_complex_name()
            local nested_junk_val = math.random(100000, 999999)
            table.insert(nested_junk_lines, string.format("local %s = %d", nested_junk_var, nested_junk_val))
        end
        table.insert(junk_lines, string.format("if %s == %d then %s end", junk_if_var, junk_if_condition, table.concat(nested_junk_lines, "; ")))

        local assignment_chance = math.random(0, 100)
        if assignment_chance < 70 then
            table.insert(junk_lines, string.format("if %s == 1 then %s = %d end", junk_if_var, junk_var_name, math.random(100000, 999999)))
        end

        local function_call_chance = math.random(0, 100)
        if function_call_chance < 40 then
            local dummy_func_name = generate_complex_name()
            table.insert(junk_lines, string.format("local function %s() return %d end", dummy_func_name, math.random(100000, 999999)))
            table.insert(junk_lines, string.format("%s()", dummy_func_name))
        end
    end
    return table.concat(junk_lines, "\n") .. "\n" .. code
end


local function virtualize_code(code)
    local vm_name = generate_complex_name()
    local instructions = {}
    local instruction_map = {}

    local function add_instruction(name, func)
        local instruction_id = #instructions + 1
        instructions[instruction_id] = func
        instruction_map[name] = instruction_id
    end

    add_instruction("ADD", function(a, b)
        return a + b
    end)
    add_instruction("SUB", function(a, b)
        return a - b
    end)
    add_instruction("MUL", function(a, b)
        return a * b
    end)
    add_instruction("DIV", function(a, b)
        return a / b
    end)
    add_instruction("MOD", function(a, b)
        return a % b
    end)
    add_instruction("PRINT", function(a)
        print(a)
    end)

    local vm_code = string.format([[
local %s = {}
%s[1] = function(a, b) return a + b end
%s[2] = function(a, b) return a - b end
%s[3] = function(a, b) return a * b end
%s[4] = function(a, b) return a / b end
%s[5] = function(a, b) return a %% b end
%s[6] = function(a) print(a) end
]], vm_name, vm_name, vm_name, vm_name, vm_name, vm_name, vm_name)

    local instruction_names = {}
    for name, id in pairs(instruction_map) do
        instruction_names[id] = generate_complex_name()
    end

    for id, name in pairs(instruction_names) do
        vm_code = vm_code .. string.format("%s[%d] = %s[%d]\n", vm_name, id, vm_name, id)
    end

    code = code:gsub("([%d%.]+)%s*([%+%-%*%/%%])%s*([%d%.]+)", function(a, op, b)
        local instruction_name
        if op == "+" then
            instruction_name = "ADD"
        elseif op == "-" then
            instruction_name = "SUB"
        elseif op == "*" then
            instruction_name = "MUL"
        elseif op == "/" then
            instruction_name = "DIV"
        elseif op == "%" then
            instruction_name = "MOD"
        end
        local instruction_id = instruction_map[instruction_name]
        return string.format("%s[%d](%s, %s)", vm_name, instruction_id, a, b)
    end)

    code = code:gsub('print%s*%(%s*(.-)%s*%)', function(content)
        return string.format("%s[%d](%s)", vm_name, instruction_map["PRINT"], content)
    end)

    return vm_code .. code
end

function obfuscator.obfuscate_code(code)
    math.randomseed(os.time())

    local obfuscated_code = code
    obfuscated_code = encrypt_strings(obfuscated_code)
    obfuscated_code = encrypt_arithmetic(obfuscated_code)
    obfuscated_code = encrypt_function_calls(obfuscated_code)
    obfuscated_code = add_junk_code(obfuscated_code)
    obfuscated_code = virtualize_code(obfuscated_code)

    local wrapper_name = generate_complex_name()
    obfuscated_code = string.format([[local %s=(function() %s end)()
]], wrapper_name, obfuscated_code)

    obfuscated_code = obfuscated_code:gsub("%s+", " "):gsub("\n", "")

    local junk_var_final = generate_complex_name()
    local junk_value_final = math.random(100000, 999999)
    obfuscated_code = string.format("local %s = %d; %s", junk_var_final, junk_value_final, obfuscated_code)

    return obfuscated_code
end

return obfuscator
