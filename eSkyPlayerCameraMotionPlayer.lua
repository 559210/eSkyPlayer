local prototype = class("eSkyPlayerCameraMotionPlayer",require "eSkyPlayer/eSkyPlayerBase");


function prototype:ctor(director)
    self.base:ctor(director);
    self.targetCamera_ = self.director.camera;
    self.cameraTrack_ = nil;
end


function prototype:initialize(trackObj)
    self.cameraTrack_ = trackObj;
    return self.base:initialize(trackObj);
end


function prototype:_update()
    if self.director.timeLine_ > self.trackLength_ then
        self.base.isPlaying_ = false;
        return;
    end
    for i = 1 , self.eventCount_ do
        local beginTime = self.cameraTrack_:getEventBeginTimeAt(i);
        local event = self.cameraTrack_:getEventAt(i);

        if (self.director.timeLine_ >= beginTime and self.director.timeLine_ <= beginTime + event.eventData_.timeLength) then
            local deltaTime = (self.director.timeLine_ - beginTime) / event.eventData_.timeLength ;
            self.targetCamera_.transform.position = Vector3.Lerp (event.eventData_.beginFrame, event.eventData_.endFrame, deltaTime );
            self.targetCamera_.transform.rotation = Quaternion.Lerp (event.eventData_.beginDr, event.eventData_.endDr, deltaTime );
        end
    end
end

function prototype:play()
    if self.cameraTrack_ == nil  then
        return false; 
    end
    if self.targetCamera_ == nil then
        return false
    end
    self.base:play();
    return true;
end


return prototype;