local function obfuscate_code(code)
    local function advanced_encode(input)
        local output = {}
        local key = {}
        local key_offset = math.random(1, 10)
        local key_multiplier = math.random(2, 5)
        local key_xor = math.random(1, 255)

        for i = 1, #input do
            local byte = string.byte(input, i)
            local random_key = math.random(1, 255)
            local encoded_byte = (((byte + i * key_offset) * key_multiplier) ~ random_key) ~ key_xor
            table.insert(output, tostring(encoded_byte))
            table.insert(key, tostring(random_key))
        end
        return table.concat(output, ","), table.concat(key, ","), key_offset, key_multiplier, key_xor
    end

    local function generate_complex_var_name()
        local name = "_"
        for i = 1, math.random(20, 30) do
            local char_type = math.random(1, 3)
            if char_type == 1 then
                name = name .. string.char(math.random(48, 57))
            elseif char_type == 2 then
                name = name .. string.char(math.random(65, 90))
            else
                name = name .. string.char(math.random(97, 122))
            end
        end
        return name
    end

    local encoded, key, key_offset, key_multiplier, key_xor = advanced_encode(code)
    local var_a = generate_complex_var_name()
    local var_x = generate_complex_var_name()
    local var_n = generate_complex_var_name()
    local var_t = generate_complex_var_name()
    local var_k = generate_complex_var_name()
    local var_offset = generate_complex_var_name()
    local var_multiplier = generate_complex_var_name()
    local var_xor = generate_complex_var_name()

    local executor_code = "local " .. var_offset .. " = " .. key_offset .. "; local " .. var_multiplier .. " = " ..
                              key_multiplier .. "; local " .. var_xor .. " = " .. key_xor .. "; local " .. var_a ..
                              " = function(" .. var_x .. "," .. var_k .. ") local " .. var_t .. " = {} local " .. var_n ..
                              " = {} local i = 1 for v in string.gmatch(" .. var_k .. ", '[^,]+') do " .. var_n ..
                              "[i] = tonumber(v) i = i + 1 end i = 1 for v in string.gmatch(" .. var_x ..
                              ", '[^,]+') do local num_v = tonumber(v) " .. var_t .. "[i] = string.char((((num_v ~ " ..
                              var_xor .. ") ~ " .. var_n .. "[i]) / " .. var_multiplier .. ") - i * " .. var_offset ..
                              ") i = i + 1 end local function execute_code(str) return assert(load(str))() end return execute_code(table.concat(" ..
                              var_t .. ")) end; " .. var_a .. "('" .. encoded .. "','" .. key .. "')"

    return executor_code
end

return {
    obfuscate_code = obfuscate_code
}
