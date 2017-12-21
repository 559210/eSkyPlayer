local prototype = class("eSkyPlayerResourceManager");


function prototype:ctor() 
    self.resourcePool = {}; -- resPathName -> {resourceObj, count}
end


function prototype:_pushResource(resPathName, res, count)
    local resInfo = self.resourcePool[resPathName];
    if resInfo == nil then
        self.resourcePool[resPathName] = {resourceObj = res, count = 0};
        resInfo = self.resourcePool[resPathName];
    end

    resInfo.count = resInfo.count + count;
end


function prototype:_popResource(resPathName)
    self.resourcePool[resPathName] = nil;
end


function prototype:_getResourceInfoByPathName(pathName)
    return self.resourcePool[pathName];
end


-- 参数resInfo，数组，里面内容是{path = , count = }. resPath是资源所在路径， count是需要使用的次数
function prototype:prepare(resInfo, callback)
    async.mapSeries(resInfo, 
        function(res, done)
            local ri = self:_getResourceInfoByPathName(res.path);
            if ri == nil then
                ddResManager.loadAsset(res.path, function(resObj)
                        if resObj == nil then
                            done(false);
                            return;
                        end
                        self:_pushResource(res.path, resObj, res.count);
                        done(nil);
                        return;
                    end);
            else
                self:_pushResource(res.path, ri.resourceObj, res.count);
                done(nil);
                return;
            end
        end, callback);
end


function prototype:prepareImmediately(resInfo)
    for i = 1, #resInfo do
        local res = resInfo[i];
        local ri = self:_getResourceInfoByPathName(res.path);
        local resObj = nil;

        if ri == nil then
            resObj = ddResManager.loadAssetFromFile(res.path);
        else
            resObj = ri.resourceObj;
        end

        if resObj == nil then
            return false;
        end
        self:_pushResource(res.path, resObj, res.count);
    end

    return true;
end


function prototype:getResource(pathName)
    local res = self:_getResourceInfoByPathName(pathName);
    if res == nil then
        return nil;
    end

    return res.resourceObj;
end


function prototype:releaseResource(pathName)
    local res = self:_getResourceInfoByPathName(pathName);
    if res == nil then
        return;
    end

    res.count = res.count - 1;

    if res.count <= 0 then
        ddResManager.unloadAsset(pathName);
        self:_popResource(pathName);
    end
end

local obj = prototype:create();

return obj;
