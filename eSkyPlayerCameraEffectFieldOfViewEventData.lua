local prototype = class("eSkyPlayerCameraEffectFieldOfViewEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.FIELD_OF_VIEW;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT_FIELD_OF_VIEW;
    self.createParameters = {
        -------fov-----------
        fovWeight0 = "number",--起始点权值
        fovRanges0 = "number",--范围最小值
        fovWeight1 = "number",--结束点权值
        fovRanges1 = "number",--范围最大值
        timeLength = "number",
    };
end

function prototype:_loadFromBuff(buff)
    buff:ReadByte();--motionType_
    local eventFile = {
        fovWeight0 = buff:ReadFloat(),
        fovRanges0 = buff:ReadFloat(),
        fovWeight1 = buff:ReadFloat(),
        fovRanges1 = buff:ReadFloat(),
        timeLength = self.eventData_.timeLength_,
    };
    return self:_setParam(eventFile);
end

--param is talbe
function prototype.createObject(param)
    if param == nil then
        return nil;
    end
    local obj = prototype:create();
    if obj:_setParam(param) == false then
        return nil;
    end
    return obj;
end

function prototype:_setParam(param)
    if misc.checkParam(self.createParameters, param) == false then
        return false;
    end
    self.eventData_ = {
        motionType_ = self.motionType_,
        timeLength_ = param.timeLength,
        fov = self:_getInfoData(param.fovWeight0, param.fovRanges0, param.fovWeight1, param.fovRanges1),
        resourcesNeeded_ = {},
    };
    -- self.eventDataLength_ = self.eventData_.timeLength_;
    return true;
end

function prototype:_getInfoData(param1, param2, param3, param4)
    local info = {weights = {}, ranges = {}};
    info.weights[1] = param1;
    info.ranges[1] = param2;
    info.weights[2] = param3;
    info.ranges[2] = param4;
    info.values = misc.getValuesByInfo(info);
    return info;
end


return prototype;