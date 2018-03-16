local prototype = class("eSkyPlayerCameraMotionTrackData", require("eSkyPlayer/eSkyPlayerCameraTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

function prototype:ctor()
    self.base:ctor(self);
    self.trackType_ = definations.TRACK_TYPE.CAMERA_MOTION;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.CAMERA;
    self.eventsSupportted_ = {definations.EVENT_TYPE.CAMERA_MOTION};
    self.createParameters = {};
end


function prototype.createObject(param)
    local obj = prototype:create();
    if misc.checkParam(obj.createParameters,param) == false then
        return nil;
    end
    if obj:_setParam(param) == false then
        return nil;
    end
    return obj;
end

function prototype:_setParam(param)
    return true;    
end


return prototype;