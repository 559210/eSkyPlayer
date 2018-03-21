local prototype = class("eSkyPlayerCameraEffectFieldOfViewEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.FIELD_OF_VIEW;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT_FIELD_OF_VIEW;
end

function prototype:_loadFromBuff(buff)
    self.eventData_.motionType_ = buff:ReadByte();
    local names = {"fov"};
    local info = {weights = {}, ranges = {}};
    self.eventData_.fov = info;
    for index = 1, 2 do
        info.weights[#info.weights + 1] =  buff:ReadFloat();
        info.ranges[#info.ranges + 1] =  buff:ReadFloat();
    end
    info.values = misc.getValuesByInfo(info);

    return true;
end

return prototype;