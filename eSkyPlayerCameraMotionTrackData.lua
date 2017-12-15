local prototype = class("eSkyPlayerCameraMotionTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    self.super.ctor(self);
    self.trackType_ = definations.TRACK_TYPE.CAMERA_MOTION;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.CAMERA;
end


return prototype;