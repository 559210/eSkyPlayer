local prototype = class("eSkyPlayerScenePlanTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
local scenePlayer = require("eSkyPlayer/eSkyPlayerScenePlayer");

function prototype:ctor()
    self.base:ctor();
    self.trackType_ = definations.TRACK_TYPE.SCENE_PLAN;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.SCENE;
    self.eventsSupportted_ = {definations.EVENT_TYPE.SCENE_PLAN};
end


function prototype:getResources()
    local resList_ = {};
    if #self.events_ == 0 then
        return nil;
    end
    
    for i = 1,#self.events_ do
        local tracks = self.events_[i].eventObj.projectData_.projectFile_.tracks;
        for j = 1, #tracks do
            local path = tracks[j]:getResources();
            local modelpath = tracks[j].mainSceneModelPath_;
<<<<<<< HEAD
            local trackTimeLength_ = tracks[j].trackTimeLength_;
            logError("trackTimeLength_ =" ..inspect(trackTimeLength_));
=======
>>>>>>> 1d71da900a5290accefce6c0b171ed5628b81f9d
            if nil ~= path then
                resList_[#resList_ + 1] = path;
            end
            if nil ~= modelpath then
               resList_[#resList_ + 1] = modelpath; 
            end
        end
    end
    return resList_;
end


return prototype;