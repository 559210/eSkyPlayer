local prototype = class("eSkyPlayerCameraMotionTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    self.base:ctor();
    self.trackType_ = definations.TRACK_TYPE.CAMERA_MOTION;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.CAMERA;
    self.eventsSupportted_ = {definations.EVENT_TYPE.CAMERA_MOTION};
end


-- param是一个table，必须包含元素：
-- trackTimeLength  track的总时长
function prototype.createObject()
    local obj = prototype:create();
    return obj;
end


return prototype;