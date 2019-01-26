local M = {}

moduleLoader.registerOnLoad("moduleName",
    function()
        -- add loading code here
    end
)

moduleLoader.registerOnUnload("moduleName",
    function()
        -- add unloading code here
    end
)

return M