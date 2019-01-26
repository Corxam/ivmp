local M = {}

moduleLoader.registerOnLoad("test",
    function()
        -- add loading code here
    end
)

moduleLoader.registerOnUnload("test",
    function()
        -- add unloading code here
    end
)

return M