local prototype = class("eSkyPlayerCameraEffectBlackEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.BLACK;
    self.eventType_ = definations.EVENT_TYPE.BLACK;
end


function prototype:initialize()
    self.base:initialize();
    self.texturePath_ = nil;
    self.textures_ = {
    "camera/textures/Overlay",
    "camera/textures/Overlay01",
    };
end


function prototype:_loadFromBuff(buff)
    self.eventData_.motionType_ = buff:ReadByte();
    local names = {"blendMode", "texture", "intensity"};
    self.eventData_.blendMode = buff:ReadByte();
    local textureID = buff:ReadByte();
    self.texturePath_ = self.textures_[textureID];
    local res = {};
    res.path = self.texturePath_; 
    res.count = 1;
    self.resourcesNeeded_[#self.resourcesNeeded_ + 1] = res;

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