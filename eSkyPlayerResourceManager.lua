local prototype = class("eSkyPlayerResourceManager");

prototype.RESOURCE_TYPE = {
    SKY_EDITOR_EVENT = 10,
    SKY_EDITOR_TRACK = 20,
    SKY_EDITOR_PLAN = 30,
    SYK_EDITOR_PROJECT = 40,
    COMMON_PREFAB = 1000,
    TEXUTRE = 2000
};

function prototype:ctor() 
    self.resourceNumber = 0;
    self.resourcePool = {}; -- resourceId -> {resource, resType}
end


function prototype:loadAsync(resPathName, resType, callback)
    function onLoadDone(res)
        if res == nil then
            return -1;
        end

        self.resourceNumber = self.resourceNumber + 1;
        self.resourcePool[self.resourceNumber] = {resource = res, resType = resType};

        callback(self.resourceNumber);
    end

    if resType == self.RESOURCE_TYPE.SKY_EDITOR_EVENT or
        resType == self.RESOURCE_TYPE.SKY_EDITOR_TRACK or
        resType == self.RESOURCE_TYPE.SKY_EDITOR_PLAN or
        resType == self.RESOURCE_TYPE.SYK_EDITOR_PROJECT then
        self:_loadSkyEditorFileAsync(resPathName, onLoadDone);
    end
end


function prototype:loadSync(resPathName, resType)   -- return resId, number type. -1 for error
    local res = nil;
    if resType == self.RESOURCE_TYPE.SKY_EDITOR_EVENT or
        resType == self.RESOURCE_TYPE.SKY_EDITOR_TRACK or
        resType == self.RESOURCE_TYPE.SKY_EDITOR_PLAN or
        resType == self.RESOURCE_TYPE.SYK_EDITOR_PROJECT then
        res = self:_loadSkyEditorFileSync(resPathName);
    elseif resType == self.RESOURCE_TYPE.COMMON_PREFAB then
        res = self:_loadCommonPrefabSync(resPathName);
    elseif resType == self.RESOURCE_TYPE.TEXUTRE then
        res = self:_loadTextureSync(resPathName);
    end

    if res == nil then
        return -1;
    end

    self.resourceNumber = self.resourceNumber + 1;
    self.resourcePool[self.resourceNumber] = {resource = res, resType = resType};

    return self.resourceNumber;
end


function prototype:_loadSkyEditorFileSync(resPathName)
    return FileUtils.readAllBytes(resPathName);
end


function prototype:_loadSkyEditorFileAsync(resPathName, callback)
    FileUtilsAsync.instance:readAllBytes(resPathName, callback);
end


function prototype:_unloadSkyEditorFile(resId)
    table.remove(self.resourcePool, resId);
    return true;
end


function prototype:_loadCommonPrefabSync(resPathName)
    return nil;
end


function prototype:_unloadCommonPrefab(resId)
    return false;
end


function prototype:_loadTextureSync(resPathName)
    return nil;
end


function prototype:_unloadTexture(resId)
    return false;
end


function prototype:unload(resId)
    local resInfo = self.resourcePool[resId];
    if resInfo == nil then
        return false;
    end

    local resType = resInfo.resType;
    if resType == nil then
        return false;
    end

    if resType == self.RESOURCE_TYPE.SKY_EDITOR_EVENT or
        resType == self.RESOURCE_TYPE.SKY_EDITOR_TRACK or
        resType == self.RESOURCE_TYPE.SKY_EDITOR_PLAN or
        resType == self.RESOURCE_TYPE.SYK_EDITOR_PROJECT then
        return self:_unloadSkyEditorFileSync(resId);
    elseif resType == self.RESOURCE_TYPE.COMMON_PREFAB then
        return self:_unloadCommonPrefabSync(resId);
    elseif resType == self.RESOURCE_TYPE.TEXUTRE then
        return self:_unloadTextureSync(resId);
    end

    return false;
end

local obj = prototype:create();

return obj;
