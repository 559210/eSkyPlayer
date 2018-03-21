local prototype = class("eSkyPlayerCameraEffectBloomEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.BLOOM;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT_BLOOM;
end

function prototype:initialize()
    prototype.super.initialize(self);
    self.texturePath_  = nil;
    self.textures_ = {
    "camera/textures/LensDirt00",
    "camera/textures/LensDirt01",
    "camera/textures/LensDirt02",
    "camera/textures/LensDirt03",
    };
end


function prototype:_loadFromBuff(buff)
    self.eventData_.motionType_ = buff:ReadByte();
    local names = {"intensity", "threshold", "softKnee", "radius", "antiFlicker", "intensityBloom", "textureBloom"};
    for _, name in ipairs(names) do
        if name == "antiFlicker" then
            self.eventData_[name] = buff:ReadByte();
        elseif name == "textureBloom" then
            local textureID = buff:ReadByte();
            self.texturePath_  = self.textures_[textureID];
            local res = {};
            res.path = self.texturePath_;
            res.count = 1;
            self.resourcesNeeded_[#self.resourcesNeeded_ + 1] = res;
        else
            local info = {weights = {}, ranges = {}};
            self.eventData_[name] = info;
            for index = 1, 2 do
                info.weights[index] =  buff:ReadFloat();
                info.ranges[index] =  buff:ReadFloat();
            end
            info.values = misc.getValuesByInfo(info);
        end
    end
    return true;
end

return prototype;