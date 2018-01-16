local prototype = class("eSkyPlayerCameraEffectChromaticAberrationEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.motionType_ = definations.CAMERA_MOTION_TYPE.CHROMATIC_ABERRATION;
end

function prototype:_loadFromBuff(buff)
    self.eventData_.motionType = buff:ReadByte();
    local names = {"intensity", "spectralTexture"};

    local info = {weights = {}, ranges = {}};
    self.eventData_["intensity"] = info;
    for index = 1, 2 do
        info.weights[#info.weights + 1] =  buff:ReadFloat();
        info.ranges[#info.ranges + 1] =  buff:ReadFloat();
    end
    misc.setValuesByWeight(info);

    self.eventData_["spectralTexture"] = buff:ReadByte();
    return true;
end

return prototype;