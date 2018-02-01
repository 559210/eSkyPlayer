local prototype = class("eSkyPlayerCameraEffectTrackData", require("eSkyPlayer/eSkyPlayerCameraTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    prototype.super.ctor(self);       --由于多重继承，只能用prototype.super这种写法
    self.trackType_ = definations.TRACK_TYPE.CAMERA_EFFECT;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.CAMERA_MOTION;
    self.eventsSupportted_ = {definations.EVENT_TYPE.CAMERA_EFFECT};
end

function prototype:getResources()
    local resList_ = {};
    if #self.events_ == 0 then
        return nil;
    end
    
    for i = 1,#self.events_ do
        local res = self.events_[i].eventObj:getResources();
        if res ~= nil then
            for j = 1,#res do
                resList_[#resList_ + 1] = res[j];
            end
        end
    end
    return resList_;
end

function prototype:isNeedAdditionalCamera()
    for i = 1, #self.events_ do
        if self.events_[i].eventObj.motionType_ == definations.CAMERA_EFFECT_TYPE.CROSS_FADE then
            return true;
        end
    end
    return false;
end

return prototype;