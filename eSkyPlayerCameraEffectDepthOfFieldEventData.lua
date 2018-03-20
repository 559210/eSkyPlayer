local prototype = class("eSkyPlayerCameraEffectDepthOfFieldEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.DEPTH_OF_FIELD;
    self.eventType_ = definations.EVENT_TYPE.DEPTH_OF_FIELD;
end

function prototype:_loadFromBuff(buff)
    self.eventData_.motionType_ = buff:ReadByte();
    local names = {"aperture"};
    local info = {weights = {}, ranges = {}};
    self.eventData_.aperture = info;
    for index = 1, 2 do
        info.weights[#info.weights + 1] =  buff:ReadFloat();
        info.ranges[#info.ranges + 1] =  buff:ReadFloat();
    end
    misc.setValuesByWeight(info);
    return true;
end

return prototype;
