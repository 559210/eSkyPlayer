local prototype = class("eSkyPlayerCameraEffectBloomEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.texturePath = nil;
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.BLOOM;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT;
end

function prototype:initialize()
    self.base:initialize();
    self.textures_ = {
    "camera/textures/LensDirt00",
    "camera/textures/LensDirt01",
    "camera/textures/LensDirt02",
    "camera/textures/LensDirt03",
    };
end

function prototype:getResources()
    return self.resList_;
end

function prototype:_loadFromBuff(buff)
    self.eventData_.motionType = buff:ReadByte();
    local names = {"intensity", "threshold", "softKnee", "radius", "antiFlicker", "intensityBloom", "textureBloom"};
    for _, name in ipairs(names) do
        if name == "antiFlicker" then
            self.eventData_[name] = buff:ReadByte();
        elseif name == "textureBloom" then
            local textureID = buff:ReadByte();
            self.texturePath = self.textures_[textureID];
            self.resList_[#self.resList_ + 1] = self.texturePath;
        else
            local info = {weights = {}, ranges = {}};
            self.eventData_[name] = info;
            for index = 1, 2 do
                info.weights[index] =  buff:ReadFloat();
                info.ranges[index] =  buff:ReadFloat();
            end
            misc.setValuesByWeight(info);
        end
    end
    return true;
end

return prototype;