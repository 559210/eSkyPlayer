local prototype = class("eSkyPlayerCameraEffectChromaticAberrationEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.CHROMATIC_ABERRATION;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT_CHROMATIC_ABERRATION;
    self.texturePath_ = "";
    self.createParameters = {
        textureID = "number",
        timeLength = "number",
        -------intensity-----------
        intensityWeight0 = "number",--起始点权值
        intensityRanges0 = "number",--范围最小值
        intensityWeight1 = "number",--结束点权值
        intensityRanges1 = "number",--范围最大值
    };
end

function prototype:initialize()
    prototype.super.initialize(self);
    return true;
end

function prototype:_loadFromBuff(buff)
    buff:ReadByte();--motionType_
    local eventFile = {
        intensityWeight0 = buff:ReadFloat(),
        intensityRanges0 = buff:ReadFloat(),
        intensityWeight1 = buff:ReadFloat(),
        intensityRanges1 = buff:ReadFloat(),
        textureID = buff:ReadByte(),
        timeLength = self.eventData_.timeLength_,
    };
    return self:_setParam(eventFile);
end

--param is talbe
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
        logError("CameraEffectChromaticAberrationEventData 参数错误");
        return false;
    end
    local textures_ = {
        "camera/textures/SpectralLut_BlueRed",
        "camera/textures/SpectralLut_GreenPurple",
        "camera/textures/SpectralLut_PurpleGreen",
        "camera/textures/SpectralLut_RedBlue",
    };
    self.texturePath_ = textures_[param.textureID];
    local res = {};
    res.path = self.texturePath_;
    res.count = 1;
    self.eventData_ = {
        motionType_ = self.motionType_,
        timeLength_ = param.timeLength,
        resourcesNeeded_ = {res},
        intensity = self:_getInfoData(param.intensityWeight0, param.intensityRanges0, param.intensityWeight1, param.intensityRanges1),
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