local prototype = class("eSkyPlayerCameraEffectCrossFadeEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.CROSS_FADE;
    self.eventType_ = definations.EVENT_TYPE.CROSS_FADE;
    self.createParameters = {
        --motionType = "number", --特效类型1.BLOOM 2.BLACK 3.DEPTH_OF_FIELD 4.CROSS_FADE 5.FIELD_OF_VIEW 6.CHROMATIC_ABERRATION 7.USER_LUT 8.VIGNETTE
        -------alphaFrom-----------
        alphaFromWeight0 = "number",--起始点权值
        alphaFromRanges0 = "number",--范围最小值
        alphaFromWeight1 = "number",--结束点权值
        alphaFromRanges1 = "number",--范围最大值
        -------alphaTo-----------
        alphaToWeight0 = "number",--起始点权值
        alphaToRanges0 = "number",--范围最小值
        alphaToWeight1 = "number",--结束点权值
        alphaToRanges1 = "number",--范围最大值
        timeLength = "number"
    };
end

function prototype:_loadFromBuff(buff)
    local eventFile = {};
    buff:ReadByte();--motionType
    --------alphaFrom---------------
    eventFile.alphaFromWeight0 = buff:ReadFloat();
    eventFile.alphaFromRanges0 = buff:ReadFloat();
    eventFile.alphaFromWeight1 = buff:ReadFloat();
    eventFile.alphaFromRanges1 = buff:ReadFloat();
    --------alphaTo---------------
    eventFile.alphaToWeight0 = buff:ReadFloat();
    eventFile.alphaToRanges0 = buff:ReadFloat();
    eventFile.alphaToWeight1 = buff:ReadFloat();
    eventFile.alphaToRanges1 = buff:ReadFloat();
    eventFile.timeLength = self.eventData_.timeLength_;
    return self:_setParam(eventFile);
end

function prototype.createObject(param)
    if param == nil then return nil; end
    local obj = prototype:create();
    if obj:_setParam(param) == false then
        return nil
    end
    return obj;
end

function prototype:_setParam(param)
    if misc.checkParam(self.createParameters,param) == false then return false; end
    self.eventData_ = {
        motionType_ = self.motionType_;
        timeLength_ = param.timeLength;
        alphaFrom = self:_getInfoData(param.alphaFromWeight0, param.alphaFromRanges0, param.alphaFromWeight1, param.alphaFromRanges1);
        alphaTo = self:_getInfoData(param.alphaToWeight0, param.alphaToRanges0, param.alphaToWeight1, param.alphaToRanges1);
    };
    return true;
end

function prototype:_getInfoData(param1,param2,param3,param4)
    local info = {weights = {}, ranges = {}};
    info.weights[1] = param1;
    info.ranges[1] = param2;
    info.weights[2] = param3;
    info.ranges[2] = param4;
    misc.setValuesByWeight(info);
    return info;
end

return prototype;