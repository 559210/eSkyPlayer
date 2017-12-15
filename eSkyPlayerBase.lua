local prototype = class("eSkyPlayerBase");


function prototype:ctor(director)
    self.director = director;
    self.trackObj  = nil;
    self.eventCount_ = 0;
    self.trackLength_ = 0;
end


function prototype:initialize(trackObj)
    self.trackObj = trackObj;    --player对应的track；
    self.trackLength_ = self.trackObj:getTrackLength();
    self.eventCount_ = self.trackObj:getEventCount();
    return true;
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


return prototype;