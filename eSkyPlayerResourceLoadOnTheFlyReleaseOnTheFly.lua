local prototype = class("eSkyPlayerResourceLoadOnTheFlyReleaseOnTheFly", require("eSkyPlayer/eSkyPlayerResourceLoadMethodBase"));
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


function prototype:loadResourceOnTheFly(resInfo, callback)
    if resInfo == nil or #resInfo == 0 then
        callback(true);
        return;
    end

    for i = 1, #self.resList_ do
        if self.resList_[i] == resInfo then
            callback(true);
            return;
        end
    end
    self.resList_[#self.resList_ + 1] = resInfo;
    resourceManager:prepare(resInfo, function (isPrepared)
        callback(isPrepared);
    end);
    
end


function prototype:loadResourceOnTheFlySync(resInfo) --即时加载
    if resInfo == nil or #resInfo == 0 then
        return true;
    end

    for i = 1, #self.resList_ do
        if self.resList_[i] == resInfo then
            return true;
        end
    end
    self.resList_[#self.resList_ + 1] = resInfo;
    return resourceManager:prepareImmediately(resInfo);
end


function prototype:releaseResourceOnTheFly(pathName) --即时释放
    resourceManager:releaseResource(pathName);
    for i = 1, #self.resList_ do
        for j = 1, #self.resList_[i] do
            if self.resList_[i][j].path == pathName then
                table.remove(self.resList_,i);
                return;
            end
        end
    end
end


return prototype;








