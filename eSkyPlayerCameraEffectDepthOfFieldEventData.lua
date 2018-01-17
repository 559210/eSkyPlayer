local prototype = class("eSkyPlayerCameraEffectDepthOfFieldEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.motionType_ = definations.CAMERA_MOTION_TYPE.DEPTH_OF_FIELD;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT;
end

function prototype:_loadFromBuff(buff)
    self.eventData_.motionType = buff:ReadByte();
    local names = {"aperture"};
    for _, name in ipairs(names) do
        local info = {weights = {}, ranges = {}};
        self.eventData_[name] = info;
        for index = 1, 2 do
            info.weights[#info.weights + 1] =  buff:ReadFloat();
            info.ranges[#info.ranges + 1] =  buff:ReadFloat();
        end
        misc.setValuesByWeight(info);
    end
    return true;
end

return prototype;
