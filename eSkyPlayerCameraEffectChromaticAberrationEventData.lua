local prototype = class("eSkyPlayerCameraEffectChromaticAberrationEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.CHROMATIC_ABERRATION;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT;
end

function prototype:initialize()
    self.base:initialize();
    self.texturePath_ = nil;
    self.textures_ = {
    "camera/textures/SpectralLut_BlueRed",
    "camera/textures/SpectralLut_GreenPurple",
    "camera/textures/SpectralLut_PurpleGreen",
    "camera/textures/SpectralLut_RedBlue",
    };
end

function prototype:getResources()
    return self.resList_;
end

function prototype:_loadFromBuff(buff)
    self.eventData_.motionType_ = buff:ReadByte();
    local names = {"intensity", "spectralTexture"};

    local info = {weights = {}, ranges = {}};
    self.eventData_.intensity = info;
    for index = 1, 2 do
        info.weights[#info.weights + 1] =  buff:ReadFloat();
        info.ranges[#info.ranges + 1] =  buff:ReadFloat();
    end
    misc.setValuesByWeight(info);

    local textureID = buff:ReadByte();
        self.texturePath_ = self.textures_[textureID];
        local res = {};
        res.path = self.texturePath_;
        res.count = -1;
        self.resList_[#self.resList_ + 1] = res;
    return true;
end

return prototype;