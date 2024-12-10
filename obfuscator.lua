local obf_module = require("./obf_module")

local function read_file(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read("*a")
    file:close()
    return content
end

local function write_file(path, content)
    local file = io.open(path, "w")
    if not file then return false end
    file:write(content)
    file:close()
    return true
end

local input_file = "input.lua"
local output_file = "output.lua"

local RED = "\027[31m"
local GREEN = "\027[32m"
local RESET = "\027[0m"

print(GREEN .. "Obfuscating " .. input_file .. "..." .. RESET)

local code = read_file(input_file)
if not code then
    print(RED .. "Error: Could not read input file." .. RESET)
    return
end

local obfuscated_code = obf_module.obfuscate_code(code)

if write_file(output_file, obfuscated_code) then
    print(GREEN .. "Successfully obfuscated to " .. output_file .. RESET)
else
    print(RED .. "Error: Could not write to output file." .. RESET)
end
