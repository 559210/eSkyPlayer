local prototype = class("eSkyPlayerResourceLoadImmediatelySyncReleaseImmediately", require("eSkyPlayer/eSkyPlayerResourceLoadMethodBase"));
local resourceManager = require("eSkyPlayer/eSkyPlayerResourceManager");


function prototype:getResource(pathName)
    return resourceManager:getResource(pathName);
end


function prototype:loadResourceInitially(resInfo, callback)
    callback(true);
end


function prototype:loadResourceInitiallySync(resInfo) --开始时加载
    return true;
end


function prototype:releaseResourceLastly(pathName) --结束时释放

end


function prototype:loadResourceImmediately(resInfo, callback)
    callback(true);
end


function prototype:loadResourceImmediatelySync(resInfo) --即时加载
    if resInfo == nil or #resInfo == 0 then
        return true;
    end

    for i = 1, #self.resList_ do
        if self.resList_ == resInfo then
            return true;
        end
    end
    self.resList_[#self.resList_ + 1] = resInfo;
    return resourceManager:prepareImmediately(resInfo);
end


function prototype:releaseResourceImmediately(pathName) --即时释放
    resourceManager:releaseResource(pathName);
    for i = 1, #self.resList_ do
        if self.resList_[i].path == pathName then
            table.remove(self.resList_,i);
        end
    end
end

return prototype;