local prototype = class("eSkyPlayerCameraEffectVignetteEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.motionType_ = definations.CAMERA_MOTION_TYPE.VIGNETTE;
end

function prototype:_loadFromBuff(buff)
    self.eventData_.motionType = buff:ReadByte();
    local names = {"mode", "allColor", "intensity", "smoothness", "roundness", "mask", "opacity", "rounded"};
    for _, name in ipairs(names) do
        if name == "mode" or name == "mask" or name == "rounded" then
            self.eventData_[name] = buff:ReadByte();
        else
            local info = {weights = {}, ranges = {}};
            self.eventData_[name] = info;
            for index = 1, 2 do
                info.weights[#info.weights + 1] =  buff:ReadFloat();
                info.ranges[#info.ranges + 1] =  buff:ReadFloat();
            end
            misc.setValuesByWeight(info);
        end
    end
    return true;
end

return prototype;
