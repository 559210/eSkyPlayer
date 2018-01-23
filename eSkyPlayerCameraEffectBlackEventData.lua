local prototype = class("eSkyPlayerCameraEffectBlackEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.BLACK;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT;
end

function prototype:initialize()
    self.base:initialize();
    self.textures_ = {
    "camera/textures/Overlay",
    "camera/textures/Overlay01",
    };
end

function prototype:getResources()
    return self.resList_;
end

function prototype:_loadFromBuff(buff)
    self.eventData_.motionType = buff:ReadByte();
    local names = {"blendMode", "texture", "intensity"};
    self.eventData_.blendMode = buff:ReadByte();

    local textureID = buff:ReadByte();
    self.texturePath = self.textures_[textureID];
    self.resList_[#self.resList_ + 1] = self.texturePath;

    local info = {weights = {}, ranges = {}};
    self.eventData_.intensity = info;
    for index = 1, 2 do
        info.weights[#info.weights + 1] =  buff:ReadFloat();
        info.ranges[#info.ranges + 1] =  buff:ReadFloat();
    end
    misc.setValuesByWeight(info);

    return true;
end

return prototype;