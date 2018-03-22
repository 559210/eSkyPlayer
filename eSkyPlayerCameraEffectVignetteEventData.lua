local prototype = class("eSkyPlayerCameraEffectVignetteEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.VIGNETTE;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT_VIGNETTE;
    self.texturePath_ = "";
    self.createParameters = {
        timeLength = "number",
        -------mode-----------
        modeID = "number",--混合模式id
        -------allColor-----------
        allColorWeight0 = "number",--起始点权值
        allColorRanges0 = "number",--范围最小值
        allColorWeight1 = "number",--结束点权值
        allColorRanges1 = "number",--范围最大值
        -------intensity-----------
        intensityWeight0 = "number",--起始点权值
        intensityRanges0 = "number",--范围最小值
        intensityWeight1 = "number",--结束点权值
        intensityRanges1 = "number",--范围最大值
        -------smoothness-----------
        smoothnessWeight0 = "number",--起始点权值
        smoothnessRanges0 = "number",--范围最小值
        smoothnessWeight1 = "number",--结束点权值
        smoothnessRanges1 = "number",--范围最大值
        -------roundness-----------
        roundnessWeight0 = "number",--起始点权值
        roundnessRanges0 = "number",--范围最小值
        roundnessWeight1 = "number",--结束点权值
        roundnessRanges1 = "number",--范围最大值
        -------mask-----------
        textureID = "number",--图片索引
        -------opacity-----------
        opacityWeight0 = "number",--起始点权值
        opacityRanges0 = "number",--范围最小值
        opacityWeight1 = "number",--结束点权值
        opacityRanges1 = "number",--范围最大值
        -------rounded-----------
        rounded = "number",
    };
end

function prototype:initialize()
    prototype.super.initialize(self);
    self.texturePath_ = "";
    return true;
end


function prototype:_loadFromBuff(buff)
    buff:ReadByte();--motionType_
    local eventFile = {
        timeLength = self.eventData_.timeLength_,
        -------mode-----------
        modeID = buff:ReadByte(),
        -------allColor-----------
        allColorWeight0 = buff:ReadFloat(),
        allColorRanges0 = buff:ReadFloat(),
        allColorWeight1 = buff:ReadFloat(),
        allColorRanges1 = buff:ReadFloat(),
        -------intensity-----------
        intensityWeight0 = buff:ReadFloat(),
        intensityRanges0 = buff:ReadFloat(),
        intensityWeight1 = buff:ReadFloat(),
        intensityRanges1 = buff:ReadFloat(),
        -------smoothness-----------
        smoothnessWeight0 = buff:ReadFloat(),
        smoothnessRanges0 = buff:ReadFloat(),
        smoothnessWeight1 = buff:ReadFloat(),
        smoothnessRanges1 = buff:ReadFloat(),
         -------roundness-----------
        roundnessWeight0 = buff:ReadFloat(),
        roundnessRanges0 = buff:ReadFloat(),
        roundnessWeight1 = buff:ReadFloat(),
        roundnessRanges1 = buff:ReadFloat(),
        -------mask-----------
        textureID = buff:ReadByte(),
        -------opacity-----------
        opacityWeight0 = buff:ReadFloat(),
        opacityRanges0 = buff:ReadFloat(),
        opacityWeight1 = buff:ReadFloat(),
        opacityRanges1 = buff:ReadFloat(),
        -------rounded-----------
        rounded = buff:ReadByte(),
    };

    return self:_setParam(eventFile);

end

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
        logError("CameraEffectVignetteEventData 参数错误");
        return false;
    end
    local textures_ = {
        "camera/textures/LensDirt00",
        "camera/textures/LensDirt01",
    };
    self.eventData_ = {
        timeLength_ = param.timeLength,
        motionType_ = self.motionType_,
        mode = param.modeID,
        allColor = self:_getInfoData(param.allColorWeight0, param.allColorRanges0, param.allColorWeight1, param.allColorRanges1),
        intensity = self:_getInfoData(param.intensityWeight0, param.intensityRanges0, param.intensityWeight1, param.intensityRanges1),
        smoothness = self:_getInfoData(param.smoothnessWeight0, param.smoothnessRanges0, param.smoothnessWeight1, param.smoothnessRanges1),
        roundness = self:_getInfoData(param.roundnessWeight0, param.roundnessRanges0, param.roundnessWeight1, param.roundnessRanges1),
        opacity = self:_getInfoData(param.opacityWeight0, param.opacityRanges0, param.opacityWeight1, param.opacityRanges1),
        rounded = param.rounded,
    };
    self.texturePath_ = textures_[param.textureID];
    local res = {};
    res.path = self.texturePath_;
    res.count = 1;
    self.resourcesNeeded_[#self.resourcesNeeded_ + 1] = res;
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
