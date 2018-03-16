local prototype = class("eSkyPlayerCameraEffectTrackData", require("eSkyPlayer/eSkyPlayerCameraTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    prototype.super.ctor(self);       --由于多重继承，只能用prototype.super这种写法
    self.trackType_ = definations.TRACK_TYPE.CAMERA_EFFECT;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.CAMERA_MOTION;
    self.eventsSupportted_ = {
    definations.EVENT_TYPE.BLOOM,
    definations.EVENT_TYPE.BLACK,
    definations.EVENT_TYPE.DEPTH_OF_FIELD,
    definations.EVENT_TYPE.CROSS_FADE,
    definations.EVENT_TYPE.FIELD_OF_VIEW,
    definations.EVENT_TYPE.CHROMATIC_ABERRATION,
    definations.EVENT_TYPE.VIGNETTE,
    };
end

function prototype:initialize()
    prototype.super.initialize(self);
end

-- function prototype:getResources()
--     local resList = {};
--     if #self.events_ == 0 then
--         return nil;
--     end
    
--     for i = 1,#self.events_ do
--         local res = self.events_[i].eventObj_:getResources();
--         if res ~= nil then
--             for j = 1,#res do
--                 resList[#resList + 1] = res[j];
--             end
--         end
--     end
--     return resList;
-- end

function prototype:isNeedAdditionalCamera()
    for i = 1, #self.events_ do
        if self.events_[i].eventObj_.motionType_ == definations.CAMERA_EFFECT_TYPE.CROSS_FADE then
            return true;
        end
    end
    return false;
end

return prototype;