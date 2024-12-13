local removecomments = {}

function removecomments.remove(code)
    print("Removing comments")
    local result = ""
    local in_multiline_comment = false
    local i = 1
    while i <= #code do
        local char = code:sub(i, i)
        if in_multiline_comment then
            if char == "]" and code:sub(i, i + 1) == "]]" then
                in_multiline_comment = false
                i = i + 2
            else
                i = i + 1
            end
        elseif char == "-" and code:sub(i, i + 1) == "--" then
            if code:sub(i, i + 2) == "--[" then
                in_multiline_comment = true
                i = i + 3
            else
                i = i + 1
                while i <= #code and code:sub(i, i) ~= "\n" do
                    i = i + 1
                end
                if i <= #code then
                    i = i + 1
                end
            end
        else
            result = result .. char
            i = i + 1
        end
    end
    print("Done")
    return result
end

return removecomments
