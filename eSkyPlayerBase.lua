local prototype = class("eSkyPlayerBase");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor(director)
    self.director_ = director;
    self.trackObj_  = nil;
    self.eventCount_ = 0;
    self.trackLength_ = 0;
end


function prototype:initialize(trackObj)
    self.trackObj_ = trackObj;    
    self.trackLength_ = self.trackObj_:getTrackLength();
    self.eventCount_ = self.trackObj_:getEventCount();
    return true;
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


function prototype:_update()
    return;
end


function prototype:stop()
    return true;
end


function prototype:play()
    return true;
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