local prototype = class("eSkyPlayerCameraEffectBloomEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.BLOOM;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT_BLOOM;
    self.texturePath_ = "";
    self.createParameters = {
        resistBlinking = "number", --抵抗闪烁
        textureID = "number", --贴图索引
        --intensity
        intensityWeight0 = "number",--起始点权值
        intensityRanges0 = "number",--范围最小值
        intensityWeight1 = "number",--结束点权值
        intensityRanges1 = "number",--范围最大值
        --threshold
        thresholdWeight0 = "number",--起始点权值
        thresholdRanges0 = "number",--范围最小值
        thresholdWeight1 = "number",--结束点权值
        thresholdRanges1 = "number",--范围最大值
        --softKnee
        softKneeWeight0 = "number",--起始点权值
        softKneeRanges0 = "number",--范围最小值
        softKneeWeight1 = "number",--结束点权值
        softKneeRanges1 = "number",--范围最大值
        --radius
        radiusWeight0 = "number",--起始点权值
        radiusRanges0 = "number",--范围最小值
        radiusWeight1 = "number",--结束点权值
        radiusRanges1 = "number",--范围最大值
        --intensityBloom
        intensityBloomWeight0 = "number",--起始点权值
        intensityBloomRanges0 = "number",--范围最小值
        intensityBloomRanges1 = "number",--结束点权值
        intensityBloomWeight1 = "number",--范围最大值
        timeLength = "number", --
    }; 

end

function prototype:initialize()
    prototype.super.initialize(self);
    return true;
end


function prototype:_loadFromBuff(buff)
    --读取顺序不可改变
    local eventFile = {};
    buff:ReadByte();--motionType
    ----------intensity(发光强度)----------------
    eventFile.intensityWeight0 = buff:ReadFloat();
    eventFile.intensityRanges0 = buff:ReadFloat();
    eventFile.intensityWeight1 = buff:ReadFloat();
    eventFile.intensityRanges1 = buff:ReadFloat();
    ----------threshold(临界值)--------------------
    eventFile.thresholdWeight0 = buff:ReadFloat();
    eventFile.thresholdRanges0 = buff:ReadFloat();
    eventFile.thresholdWeight1 = buff:ReadFloat();
    eventFile.thresholdRanges1 = buff:ReadFloat();
    ---------softKnee(曲线弯曲点)----------------------
    eventFile.softKneeWeight0 = buff:ReadFloat();
    eventFile.softKneeRanges0 = buff:ReadFloat();
    eventFile.softKneeWeight1 = buff:ReadFloat();
    eventFile.softKneeRanges1 = buff:ReadFloat();
    ---------radius(发光半径)------------------------
    eventFile.radiusWeight0 = buff:ReadFloat();
    eventFile.radiusRanges0 = buff:ReadFloat();
    eventFile.radiusWeight1 = buff:ReadFloat();
    eventFile.radiusRanges1 = buff:ReadFloat();
    ---------antiFlicker(抗闪烁)------------------------
    eventFile.resistBlinking = buff:ReadByte();
    ---------intensityBloom------------------------
    eventFile.intensityBloomWeight0 = buff:ReadFloat();
    eventFile.intensityBloomRanges0 = buff:ReadFloat();
    eventFile.intensityBloomRanges1 = buff:ReadFloat();
    eventFile.intensityBloomWeight1 = buff:ReadFloat();
    ---------textureBloom(贴图)------------------------
    eventFile.textureID = buff:ReadByte();
    eventFile.timeLength = self.eventData_.timeLength_;
    return self:_setParam(eventFile);
end

--param is talbe
function prototype.createObject(param)
    if param == nil then
        return nil;
    end
    local obj = prototype:create()
    if obj:_setParam(param) == false then
        return nil
    end
    return obj;
end

function prototype:_setParam(param)
    if misc.checkParam(self.createParameters,param) == false then
        return false;
    end

    local names = {"intensity", "threshold", "softKnee", "radius", "antiFlicker", "intensityBloom", "textureBloom"};
    local textures_ = {
        "camera/textures/LensDirt00",
        "camera/textures/LensDirt01",
        "camera/textures/LensDirt02",
        "camera/textures/LensDirt03",
    };
    self.texturePath_ = textures_[param.textureID];
    local res = {};
    res.path = self.texturePath_;
    res.count = 1;
    self.eventData_ = {
        motionType_ = self.motionType_,
        timeLength_ = param.timeLength,
        intensity = self:_getInfoData(param.intensityWeight0, param.intensityRanges0, param.intensityWeight1, param.intensityRanges1),
        threshold = self:_getInfoData(param.thresholdWeight0, param.thresholdRanges0, param.thresholdWeight1, param.thresholdRanges1),
        softKnee = self:_getInfoData(param.softKneeWeight0, param.softKneeRanges0, param.softKneeWeight1, param.softKneeRanges1),
        radius = self:_getInfoData(param.radiusWeight0, param.radiusRanges0, param.radiusWeight1, param.radiusRanges1),
        antiFlicker = param.resistBlinking,
        intensityBloom = self:_getInfoData(param.intensityBloomWeight0, param.intensityBloomRanges0, param.intensityBloomRanges1, param.intensityBloomWeight1),
        resourcesNeeded_ = {res},
    };
    self.eventDataLength_ = self.eventData_.timeLength_;
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