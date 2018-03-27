local prototype = class("eSkyPlayerResourceLoadInitiallyReleaseLastly", require("eSkyPlayer/eSkyPlayerResourceLoadMethodBase"));
local resourceManager = require("eSkyPlayer/eSkyPlayerResourceManager");


function prototype:ctor()

end


function prototype:getResource(pathName)
    return resourceManager:getResource(pathName);
end


function prototype:loadResourceInitially(resInfo, callback)  --开始时加载（异步）
    resourceManager:prepare(resInfo, function (isPrepared)
        callback(isPrepared);
        end);
end


function prototype:loadResourceInitiallySync(resInfo) 
    return true;
end


function prototype:releaseResourceLastly(pathName) --结束时释放
    resourceManager:releaseResource(pathName);
end


function prototype:loadResourceOnTheFly(resInfo, callback)
    callback(true);
end


function prototype:loadResourceOnTheFlySync(resInfo) --即时加载
    return true;
end


function prototype:releaseResourceOnTheFly(pathName) --即时释放

end

return prototype;