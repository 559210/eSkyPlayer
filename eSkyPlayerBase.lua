local prototype = class("eSkyPlayerBase");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");



function prototype:ctor(director)
    self.director_ = director;
    self.trackObj_  = nil;
    self.eventCount_ = 0;
    self.trackLength_ = 0;
    self.playState_ = definations.PLAY_STATE.NORMAL;
end


function prototype:initialize(trackObj)
    self.trackObj_ = trackObj;    
    self.trackLength_ = self.trackObj_:getTrackLength();
    self.eventCount_ = self.trackObj_:getEventCount();
    return true;
end

function prototype:uninitialize()
    return true;
end


function prototype:onResourceLoaded()
end


function prototype:isNeedAdditionalCamera()
    return false;
end


function prototype:setAdditionalCamera(camera)
    logError("你需要在子类中实现set函数");
end


function prototype:isLoaded()
    --return true/false;
end


function prototype:getResources()
    return nil;
end


function prototype:_update()
    self.playState_ = definations.PLAY_STATE.PLAYING;
    return;
end


function prototype:stop()
    self.playState_ = definations.PLAY_STATE.PLAYEND;
    return true;
end


function prototype:play()
    self.playState_ = definations.PLAY_STATE.PLAY;
    return true;
end

function prototype:changePlayState(state)
    self.playState_ = state
end

function prototype:seek(time)
    return true;
end


function prototype:getTrackType()
    if self.trackObj_ == nil then
        return definations.TRACK_FILE_TYPE.UNKOWN;
    end

    return self.trackObj_:getTrackType();
end


return prototype;