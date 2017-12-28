local prototype = class("eSkyPlayerCameraPlanTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.base:ctor();
    self.trackType_ = definations.TRACK_TYPE.CAMERA_PLAN;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.CAMERA;
end


function prototype:_loadFromBuff(buff)
    
end

return prototype;