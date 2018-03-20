local prototype = class("eSkyPlayerResourceLoadMethodBase");
local resourceManager = require("eSkyPlayer/eSkyPlayerResourceManager");

function prototype:ctor() 
    self.resList_ = {};
end


function prototype:getResource(pathName)

end


function prototype:loadResourceInitially(resInfo, callback)

end


function prototype:loadResourceInitiallySync(resInfo)

end


function prototype:releaseResourceLastly(pathName)

end


function prototype:loadResourceImmediately(resInfo, callback)

end


function prototype:loadResourceImmediatelySync(resInfo) 

end


function prototype:releaseResourceImmediately(pathName) 

end

return prototype;