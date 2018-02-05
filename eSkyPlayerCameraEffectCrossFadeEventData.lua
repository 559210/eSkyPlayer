local prototype = class("eSkyPlayerCameraEffectCrossFadeEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.texturePath_ = nil;
    self.motionType_ = definations.CAMERA_EFFECT_TYPE.CROSS_FADE;
    self.eventType_ = definations.EVENT_TYPE.CAMERA_EFFECT;
end

function prototype:_loadFromBuff(buff)
    self.eventData_.motionType_ = buff:ReadByte();
    local names = {"alphaFrom", "alphaTo"};
    local info = {weights_ = {}, ranges_ = {}};
    for _, name in ipairs(names) do
        self.eventData_[name] = info;
        for index = 1, 2 do
            info.weights_[#info.weights_ + 1] =  buff:ReadFloat();
            info.ranges_[#info.ranges_ + 1] =  buff:ReadFloat();
        end
    end

    misc.setValuesByWeight(info);
    return true;
end

return prototype;