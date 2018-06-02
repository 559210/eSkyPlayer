local prototype = class("eSkyPlayerCameraEffectDepthOfFieldEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.DEPTH_OF_FIELD;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT_DEPTH_OF_FIELD;
    self.createParameters = {
        timeLength = "number",
        -------aperture-----------
        apertureWeight0 = "number",--起始点权值
        apertureRanges0 = "number",--范围最小值
        apertureWeight1 = "number",--结束点权值
        apertureRanges1 = "number",--范围最大值
    };
end

function prototype:_loadFromBuff(buff)
    buff:ReadByte();--motionType_
    local eventFile = {
        apertureWeight0 = buff:ReadFloat(),
        apertureRanges0 = buff:ReadFloat(),
        apertureWeight1 = buff:ReadFloat(),
        apertureRanges1 = buff:ReadFloat(),
        timeLength = self.eventData_.timeLength_,
    };
    return self:_setParam(eventFile);
end


function prototype.createObject(param)
    if param == nil then return nil; end
    local obj = prototype:create();
    if obj:_setParam(param) == false then
        return nil; 
    end
    return obj;
end

function prototype:_setParam(param)
    if misc.checkParam(self.createParameters, param) == false then
        logError("CameraEffectDepthOfFieldEventData 参数错误");
        return false;
    end
    self.eventData_ = {
        motionType_ = self.motionType_,
        timeLength_ = param.timeLength,
        aperture = self:_getInfoData(param.apertureWeight0, param.apertureRanges0, param.apertureWeight1, param.apertureRanges1),
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
