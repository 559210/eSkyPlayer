local prototype = class("eSkyPlayerResourceManager");


-- 希望支持3种资源管理方式：
-- 1. project开始时全部预加载
-- 2. project期间用到加载，用完立即释放
-- 3. project期间用到加载，如果后面还需要用，那么暂时不卸载，直到最后一次用完卸载
-- 额外的：满足上述功能的基础上，尽量优化跨project的情况

-- 所以，数据结构：
-- 需要有所有已加载的资源的容器，键值对（路径 -> 资源对象）
-- 所有资源需要有声明周期管理，管理标准：预计加载次数计数，初始化时候设定，释放一次递减一次，递减到0真正释放
-- 


function prototype:ctor() 
    self.resourcePool = {}; -- resPathName -> {resourceObj, count}
end


function prototype:_pushResource(resPathName, res, count)
    local resInfo = self.resourcePool[resPathName];
    if resInfo = nil then
        self.resourcePool[resPathName] = {resourceObj = res, count = 0};
        resInfo = self.resourcePool[resPathName];
    end

    resInfo.count = resInfo.count + count;
end


function prototype:_popResource(resPathName)
    table.remove(self.resourcePool, resPathName);
end


function prototype:_getResourceInfoByPathName(pathName)
    return self.resourcePool[pathName];
end

-- function prototype:loadAsync(resPathName, callback)
--     function onLoadDone(res)
--         if res == nil then
--             callback(-1);
--             return;
--         end

--         local resId = self:_pushResource(res, resType);
--         callback(resId);
--     end

--     if resType == self.RESOURCE_TYPE.COMMON_PREFAB then
--         self:_loadCommonPrefabAsync(resPathName, onLoadDone);

--     elseif resType == self.RESOURCE_TYPE.TEXTURE then
--         self:_loadTextureAsync(resPathName, onLoadDone);
--     end
-- end


-- function prototype:loadSync(resPathName, resType)   -- return resId, number type. -1 for error
--     local res = nil;
--     if resType == self.RESOURCE_TYPE.COMMON_PREFAB then
--         res = self:_loadCommonPrefabSync(resPathName);
--     elseif resType == self.RESOURCE_TYPE.TEXTURE then
--         res = self:_loadTextureSync(resPathName);
--     end

--     if res == nil then
--         return -1;
--     end

--     return self:_pushResource(res, resType);
-- end


-- function prototype:_loadSkyEditorFileSync(resPathName)
--     return FileUtils.readAllBytes(resPathName);
-- end


-- function prototype:_loadSkyEditorFileAsync(resPathName, callback)
--     FileUtilsAsync.instance:readAllBytes(resPathName, callback);
-- end


-- function prototype:_unloadSkyEditorFile(resId)
--     table.remove(self.resourcePool, resId);
--     return true;
-- end


-- function prototype:_loadCommonPrefabSync(resPathName)
--     return ddResManager.loadAssetFromFile(resPathName);
-- end


-- function prototype:_loadCommonPrefabAsync(resPathName, callback)
--     ddResManager.loadAsset(resPathName, callback);
-- end


-- function prototype:_unloadCommonPrefab(resPathName)
--     ddResManager.unloadAsset(resPathName);
-- end


-- function prototype:_loadTextureSync(resPathName)
--     return ddResManager.loadAssetFromFile(resPathName);
-- end


-- function prototype:_loadTextureAsync(resPathName, callback)
--     ddResManager.loadAsset(resPathName, callback);
-- end


-- function prototype:_unloadTexture(resPathName)
--     ddResManager.unloadAsset(resPathName);
-- end


-- function prototype:unload(resId)
--     local resInfo = self.resourcePool[resId];
--     if resInfo == nil then
--         return false;
--     end

--     local resType = resInfo.resType;
--     if resType == nil then
--         return false;
--     end

--     if resType == self.RESOURCE_TYPE.COMMON_PREFAB then
--         self:_unloadCommonPrefab(resInfo.resPathName);
--         return true;
--     elseif resType == self.RESOURCE_TYPE.TEXTURE then
--         self:_unloadTexture(resInfo.resPathName);
--         return true;
--     end

--     self:_popResource(resId);

--     return false;
-- end

-- 为project准备资源，此函数会分析projectObj内容，扫描所有需要加载的资源，并加载
-- 问题： 这个函数会变成和projectObj结构强相关，如果PorjectObj结构调整，此函数也会需要调整。

-- 参数resInfo，数组，里面内容是{path = , count = }. resPath是资源所在路径， count是需要使用的次数
function prototype:prepare(resInfo, callback)
    function ld(pathName, count, cb)
    end

    function makeld(index)
        local res = resInfo[index];
        return function (cb)
            ld(res.path, res.count, cb);
        end
    end

    local tasks = {};
    for i = 1, #resInfo do
        tasks[#tasks + 1] = makeld(i);
    end
end


function prototype:prepareImmediately(resInfo)
    for i = 1, #resInfo do
        local res = resInfo[i];
        local ri = _getResourceInfoByPathName(res.path);
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

local obj = prototype:create();

return obj;
