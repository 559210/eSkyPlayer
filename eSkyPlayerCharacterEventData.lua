local prototype = class("eSkyPlayerCharacterEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);
    self.eventType_ = definations.EVENT_TYPE.CHARACTER;

    self.createParameters = {
        roleConfig = "table",
        timeLength = "number", 
    };
end


function prototype:initialize()
    prototype.super.initialize(self);
    return true;
end


function prototype:_loadHeaderFromBuff(buff)
    if buff == nil then 
        return false; 
    end
    self.eventData_.version_ = buff:ReadShort();
    self.eventData_.smallVersion_ = buff:ReadShort();
    self.eventData_.eventType_ = buff:ReadByte();

    return true;
end

local avatarUrl = {
    [AvatarResourceType.PREFAB]= "avatars/prefabs/",
    [AvatarResourceType.TEXTURE] = "avatars/textures/",
    [AvatarResourceType.EFFECT]= "avatars/prefabs/"
};

function prototype:_loadFromBuff(buff)
    local filename = buff:ReadString();
    local url = "roleConfig/" .. filename;
    local asset = ddResManager.loadAssetFromFile(url);
    local roleConfig = cjson.decode(asset.text);
    local itemCodes = roleConfig.itemCodes;
    local skeletonUrl = roleConfig.skeletonUrl;
    local urls = {};
    local bodyUrl = {};
    bodyUrl.path = skeletonUrl;
    bodyUrl.count = 1;
    table.insert(urls, bodyUrl);
    for _, itemCode in pairs(itemCodes) do 
        local config = G.configs.avatar[itemCode];
        local url = {};
        url.path = definations.AVATAR_URL[config.resourceType or AvatarResourceType.PREFAB] .. config.fileName;
        url.count = 1;
        table.insert(urls, url);
    end

    local eventFile = {};
    eventFile.roleConfig = roleConfig;
    eventFile.timeLength = buff:ReadFloat();
    eventFile.urls = urls;
    
    return self:_setParam(eventFile);
end

 -- param是一个table
function prototype.createObject(param)
    if param == nil then
        return nil;
    end
    local obj = prototype:create();
    if obj:_setParam(param) == false then
        return nil
    end
    return obj;
end

function prototype:_setParam(param)
    if misc.checkParam(self.createParameters,param) == false then return false; end
    
    self.eventData_ = {
        roleConfig_ = param.roleConfig,
        timeLength_ = param.timeLength,
        resourcesNeeded_ = param.urls,
    };

    return true;
end

return prototype;