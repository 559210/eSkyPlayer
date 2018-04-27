local prototype = class("eSkyPlayerRoleMorphEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

prototype.SERIALIZE_FIELD = {
    "eventPath_",
}

function prototype:ctor()
    self.base:ctor();
    self.eventType_ = definations.EVENT_TYPE.ROLE_MORPH;
end


function prototype:loadEvent(filename)--filename为相对路径；
    self.eventPath_ = Util.AppDataRoot .. "/" ..filename;
    return self.base:loadEvent(filename);
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



function prototype:_loadFromBuff(buff)
    local param = {
        morphConfigFilename = buff:ReadString(),
        timeLength = buff:ReadFloat(),
        curveConfigPoints = {},
        morphConfigInfo = {};
    };
    local curveConfigFilename = buff:ReadString();

    local s, e = string.find(self.eventPath_, ".*/");
    local curveConfigFullPath = string.sub(self.eventPath_, s, e) .. "config/" .. curveConfigFilename .. ".byte";
    local curveBuff = misc.readAllBytes(curveConfigFullPath);
    if curveBuff == nil then
        return false;
    end

    local count = curveBuff:ReadShort() ;
    for i = 1, count do
        local point = Vector2.New(x, y);
        point.x = curveBuff:ReadFloat();
        point.y = curveBuff:ReadFloat();
        param.curveConfigPoints[#param.curveConfigPoints + 1] = point;
    end
    local jsonPath = "morph/" .. param.morphConfigFilename;
    local asset = ddResManager.loadAssetFromFile(jsonPath);
    if asset == nil then
        return false;
    end
    local morphConfigInfo = cjson.decode(asset.text);
    param.morphConfigInfo = morphConfigInfo;
    if self:_setParam(param) == false then
        return false;
    end
    return true;
end


function prototype:_setParam(param)
    self.eventData_ = {
        -- morphConfigFilename_ = param.morphConfigFilename,
        timeLength_ = param.timeLength,
        curveConfigPoints_ = param.curveConfigPoints,
        morphConfigInfo_ = param.morphConfigInfo,
    };
    self.eventDataLength_ = self.eventData_.timeLength_;
    return true;
end


return prototype;
