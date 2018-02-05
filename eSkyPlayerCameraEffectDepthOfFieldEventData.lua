local prototype = class("eSkyPlayerCameraEffectDepthOfFieldEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.DEPTH_OF_FIELD;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT;
end

function prototype:_loadFromBuff(buff)
    self.eventData_.motionType_ = buff:ReadByte();
    local names = {"aperture"};
    local info = {weights_ = {}, ranges_ = {}};
    self.eventData_.aperture = info;
    for index = 1, 2 do
        info.weights_[#info.weights_ + 1] =  buff:ReadFloat();
        info.ranges_[#info.ranges_ + 1] =  buff:ReadFloat();
    end
    misc.setValuesByWeight(info);
    return true;
end

return prototype;
