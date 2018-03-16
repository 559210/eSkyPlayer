local prototype = class("eSkyPlayerResourceLoadInitiallySyncReleaseLastly", require("eSkyPlayer/eSkyPlayerResourceLoadMethodBase"));
local resourceManager = require("eSkyPlayer/eSkyPlayerResourceManager");


function prototype:ctor()

end


function prototype:getResource(pathName)
    return resourceManager:getResource(pathName);
end


function prototype:loadResourceInitially(resInfo, callback)
    callback(true);
end


function prototype:loadResourceInitiallySync(resInfo) --开始时加载(同步)
    return resourceManager:prepareImmediately(resInfo);
end


function prototype:releaseResourceLastly(pathName) --结束时释放
    resourceManager:releaseResource(pathName);
end


function prototype:loadResourceImmediately(resInfo, callback)
    callback(true);
end


function prototype:loadResourceImmediatelySync(resInfo) --即时加载
    return true;
end


function prototype:releaseResourceImmediately(pathName) --即时释放

end

return prototype;