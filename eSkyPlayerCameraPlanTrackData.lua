local prototype = class("eSkyPlayerCameraPlanTrackData", require("eSkyPlayer/eSkyPlayerCameraTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);       --���ڶ��ؼ̳У�ֻ����prototype.super����д��
    self.trackType_ = definations.TRACK_TYPE.CAMERA_PLAN;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.CAMERA;
    self.eventsSupportted_ = {definations.EVENT_TYPE.CAMERA_PLAN};
end

return prototype;