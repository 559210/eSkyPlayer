local prototype = class("eSkyPlayerCameraEffectFieldOfViewEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.motionType_ = definations.CAMERA_MOTION_TYPE.FIELD_OF_VIEW;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT;
end

function prototype:_loadFromBuff(buff)
    self.eventData_.motionType = buff:ReadByte();
    local names = {"fov"};
    local info = {weights = {}, ranges = {}};
    self.eventData_.fov = info;
    for index = 1, 2 do
        info.weights[#info.weights + 1] =  buff:ReadFloat();
        info.ranges[#info.ranges + 1] =  buff:ReadFloat();
    end
    misc.setValuesByWeight(info);
    logError("00000000000000" .. type(self.eventData_.fov))
    return true;
end

return prototype;