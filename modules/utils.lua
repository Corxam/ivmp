local utils = {}

function utils.split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result
end

-- this is a very crappy hash
function utils.stringToHash(s)
    s = s or ""
    local hash = 0
    for i = 1, s:len() do
        hash = hash + s:byte(i)
    end
    return hash
end



return utils