local prototype = class("eSkyPlayerCameraEffectBlackEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.BLACK;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT_BLACK;
    self.texturePath_ = "";
    self.createParameters = {
        motionType = "number", --特效类型1.BLOOM 2.BLACK 3.DEPTH_OF_FIELD 4.CROSS_FADE 5.FIELD_OF_VIEW 6.CHROMATIC_ABERRATION 7.USER_LUT 8.VIGNETTE
        blendMode = "number", --混合模式 1.Additive 2.ScreenBlend 3.Multiply 4.Overlay
        textureID = "number", --贴图索引
        intensityWeight0 = "number",--起始点权值
        intensityRanges0 = "number",--范围最小值
        intensityWeight1 = "number",--结束点权值
        intensityRanges1 = "number",--范围最大值
        timeLength = "number", --
    };
end


function prototype:initialize()
    prototype.super.initialize(self);
end


function prototype:_loadFromBuff(buff)
    local eventFile = {};
    eventFile.motionType = buff:ReadByte();
    eventFile.blendMode = buff:ReadByte();
    eventFile.textureID = buff:ReadByte();
    eventFile.intensityWeight0 = buff:ReadByte();
    eventFile.intensityRanges0 = buff:ReadByte();
    eventFile.intensityWeight1 = buff:ReadByte();
    eventFile.intensityRanges1 = buff:ReadByte();
    eventFile.timeLength = self.eventData_.timeLength_;
    if self:_setParam(eventFile) == false then
        return false;
    end
    return true;
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
    local textures_ = {
        "camera/textures/Overlay",
        "camera/textures/Overlay01",
    };

    self.texturePath_ = textures_[param.textureID];
    local res = {};
    res.path = self.texturePath_;
    res.count = 1;
    self.resourcesNeeded_[#self.resourcesNeeded_ + 1] = res;
    local eventData_ = {};
    eventData_.motionType_ = param.motionType;
    eventData_.blendMode = param.blendMode;
    eventData_.timeLength_ = param.timeLength;
    local info = {weights = {}, ranges = {}};
    info.weights[1] = param.intensityWeight0;
    info.ranges[1] = param.intensityRanges0;
    info.weights[2] = param.intensityWeight1;
    info.ranges[2] = param.intensityRanges1;
    info.values = misc.getValuesByInfo(info);
    eventData_.intensity = info;

    self.eventData_ = eventData_;
end

return prototype;