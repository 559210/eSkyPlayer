local prototype = class("eSkyPlayerScenePlanTrackData", require("eSkyPlayer/eSkyPlayerSceneTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);
    self.trackType_ = definations.TRACK_TYPE.SCENE_PLAN;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.SCENE;
    self.eventsSupportted_ = {definations.EVENT_TYPE.SCENE_PLAN};
end

return prototype;
