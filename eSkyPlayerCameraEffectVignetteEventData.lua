local prototype = class("eSkyPlayerCameraEffectVignetteEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.motionType_ = definations.CAMERA_MOTION_TYPE.VIGNETTE;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT;
end

function prototype:initialize()
    self.base:initialize();
    self.textures_ = {
    "camera/textures/LensDirt00",
    "camera/textures/LensDirt01",
    };
end

function prototype:getResources()
    return self.resList_;
end

function prototype:_loadFromBuff(buff)
    self.eventData_.motionType = buff:ReadByte();
    local names = {"mode", "allColor", "intensity", "smoothness", "roundness", "mask", "opacity", "rounded"};
    for _, name in ipairs(names) do
        if name == "mode"  then
            self.eventData_[name] = buff:ReadByte();
        elseif name == "mask" then
            local textureID = buff:ReadByte();
            self.texturePath = self.textures_[textureID];
            self.resList_[#self.resList_ + 1] = self.texturePath;
        elseif name == "rounded" then
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
