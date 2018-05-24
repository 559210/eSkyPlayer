local prototype = class("eSkyPlayerResourceManager");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

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


-- 参数resInfo，数组，里面内容是{path = , count = , type = }. resPath是资源所在路径， count是需要使用的次数
-- callback汇报资源加载情况，带一个参数，true表示全部加载成功，false表示碰到一个加载失败，从而中途中断加载
function prototype:prepare(resInfo, callback)
    async.mapSeries(resInfo, 
        function(res, done)
            local ri = self:_getResourceInfoByPathName(res.path);
            if ri == nil then
                local loadType = res.type or definations.RESOURCE_TYPE.DEFAULT;
                if loadType == definations.RESOURCE_TYPE.DEFAULT then
                    ddResManager.loadAsset(res.path, function(resObj)
                            if resObj == nil then
                                done(false);
                                return;
                            end
                            self:_pushResource(res.path, resObj, res.count);
                            done(nil);
                            return;
                        end);
                elseif loadType == definations.RESOURCE_TYPE.UI then
                    ddResManager.loadAssetBundles(res.path, function(resObj)
                        if resObj == nil then
                            done(false);
                            return;
                        end
                        self:_pushResource(res.path, resObj, res.count);
                        done(nil);
                        return;
                    end);
                else
                    done(false);
                    return;
                end
            else
                self:_pushResource(res.path, ri.resourceObj, res.count);
                done(nil);
                return;
            end
        end, function (err)
            if err ~= nil then
                callback(false);
                return;
            end
            callback(true);
        end);
end


function prototype:prepareImmediately(resInfo)
    for i = 1, #resInfo do
        local res = resInfo[i];
        local ri = self:_getResourceInfoByPathName(res.path);
        local resObj = nil;

        if ri == nil then
            local loadType = res.type or definations.RESOURCE_TYPE.DEFAULT;
            if loadType == definations.RESOURCE_TYPE.DEFAULT then
                resObj = ddResManager.loadAssetFromFile(res.path);
            else
                return false;
            end
        else
            resObj = ri.resourceObj;
        end

        if resObj == nil then
            logError(res.type .. ".............")
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
        local loadType = res.type or definations.RESOURCE_TYPE.DEFAULT;
        if loadType == definations.RESOURCE_TYPE.DEFAULT then
            ddResManager.unloadAsset(pathName);
        elseif loadType == definations.RESOURCE_TYPE.UI then
            ddResManager.unloadAssetBundles(pathName);
        else
            return;
        end
        self:_popResource(pathName);
    end
end


function prototype:releaseAllResource()
    for pathName,v in pairs(self.resourcePool) do
        local res = self:_getResourceInfoByPathName(pathName);
        local loadType = res.type or definations.RESOURCE_TYPE.DEFAULT;
        if loadType == definations.RESOURCE_TYPE.DEFAULT then
            ddResManager.unloadAsset(pathName);
        elseif loadType == definations.RESOURCE_TYPE.UI then
            ddResManager.unloadAssetBundles(pathName);
        end
    end
end


local obj = prototype:create();

return obj;
