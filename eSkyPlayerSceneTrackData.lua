local prototype = class("eSkyPlayerSceneTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    self.base:ctor();
    self.trackType_ = definations.TRACK_TYPE.SCENE_MOTION; --7
    self.trackFileType_ = definations.TRACK_FILE_TYPE.SCENE;--6
    self.eventsSupportted_ = {definations.EVENT_TYPE.SCENE_MOTION};--7
end


function prototype.createObject()
    local obj = prototype:create();
    return obj;
end


return prototype;