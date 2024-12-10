local function obfuscate_code(code)
    local function encode(input)
        local output = {}
        local key = math.random(1, 127)
        for i = 1, #input do
            local byte = string.byte(input, i)
            local encoded_byte = (byte + key) % 256
            table.insert(output, tostring(encoded_byte))
        end
        return table.concat(output, "."), key
    end

    local function generate_var_name()
        local name = ""
        for i = 1, math.random(10, 20) do
            name = name .. string.char(math.random(97, 122))
        end
        return name
    end

    local encoded, key = encode(code)
    local var_a = generate_var_name()
    local var_x = generate_var_name()
    local var_n = generate_var_name()
    local var_t = generate_var_name()
    local var_c = generate_var_name()
    local var_load = generate_var_name()

    local executor_code = "local " .. var_a ..
                              " = function(" .. var_x .. ") local " .. var_t .. " = {} for " .. var_n ..
                              " in string.gmatch(" .. var_x ..
                              ", '[^%.]+') do table.insert(" .. var_t .. ", string.char((tonumber(" .. var_n ..
                              ") - " .. key .. ") % 256)) end local " .. var_load ..
                              " = load or function(str) return assert(loadstring(str)) end return " .. var_load ..
                              "(table.concat(" .. var_t .. "))() end"
    return executor_code .. " " .. var_a .. "('" .. encoded .. "')"
end

return {
    obfuscate_code = obfuscate_code
}
