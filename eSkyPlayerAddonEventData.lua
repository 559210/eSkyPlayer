local prototype = class("eSkyPlayerAddonEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);
    self.eventType_ = definations.EVENT_TYPE.ADDON;

    self.createParameters = {
        itemCode = "string",
        boneNames = "table", --所绑骨骼(boneNames是一个数组，内容为字符串；一般情况下数组中只有一个元素；做脚底光环时为两个；两个以上不存在)
        --位置坐标
        posX = "number",
        posY = "number",
        posZ = "number",
        --方向坐标
        angleX = "number",
        angleY = "number",
        angleZ = "number",
        timeLength = "number", 
    };
end


function prototype:initialize()
    prototype.super.initialize(self);
    return true;
end


function prototype:_loadFromBuff(buff)
    local eventFile = {};
    eventFile.itemCode = buff:ReadString();
    eventFile.boneName = buff:ReadString();
    eventFile.boneNames = string.split(eventFile.boneName, "_");
    eventFile.posX = buff:ReadFloat();
    eventFile.posY = buff:ReadFloat();
    eventFile.posZ = buff:ReadFloat();
    eventFile.angleX = buff:ReadFloat();
    eventFile.angleY = buff:ReadFloat();
    eventFile.angleZ = buff:ReadFloat();

    eventFile.timeLength = self.eventData_.timeLength_;
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
    local res = {};
    res.path = G.configs.avatar:getAvatarUrl(param.itemCode);
    res.count = 1;
    for i = 3, #param.boneNames do  --当数组长度大于2时，进行截断；
        param.boneNames[i] = nil;
    end
    self.eventData_ = {
        itemCode_ = self.itemCode,
        boneNames_ = param.boneNames,
        timeLength_ = param.timeLength,
        resourcesNeeded_ = {res},
        pos_ = Vector3.New(param.posX, param.posY, param.posZ),
        angle_ = Vector3.New(param.angleX, param.angleY, param.angleZ),
    };

    return true;
end

return prototype;