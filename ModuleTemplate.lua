local M = {}

moduleLoader.registerOnLoad(string.sub(..., 9),
    function()
        -- add loading code here
    end
)


moduleLoader.registerOnUnload(string.sub(..., 9),
    function()
        -- add unloading code here
    end
)

return M