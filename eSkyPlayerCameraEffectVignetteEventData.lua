local prototype = class("eSkyPlayerCameraEffectVignetteEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.VIGNETTE;
    self.eventType_ = definations.EVENT_TYPE.VIGNETTE;
end

function prototype:initialize()
    prototype.super.initialize(self);
    self.texturePath_ = nil;
    self.textures_ = {
    "camera/textures/LensDirt00",
    "camera/textures/LensDirt01",
    };
end


function prototype:_loadFromBuff(buff)
    self.eventData_.motionType_ = buff:ReadByte();
    local names = {"mode", "allColor", "intensity", "smoothness", "roundness", "mask", "opacity", "rounded"};
    for _, name in ipairs(names) do
        if name == "mode"  then
            self.eventData_[name] = buff:ReadByte();
        elseif name == "mask" then
            local textureID = buff:ReadByte();
            self.texturePath_ = self.textures_[textureID];
            local res = {};
            res.path = self.texturePath_;
            res.count = 1;
            self.resourcesNeeded_[#self.resourcesNeeded_ + 1] = res;
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
