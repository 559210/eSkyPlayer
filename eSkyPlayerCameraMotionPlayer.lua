local prototype = class("eSkyPlayerCameraMotionPlayer",require "eSkyPlayer/eSkyPlayerBase");


function prototype:ctor(director)
    self.super.ctor(self,director);
    self.targetCamera_ = self.director.camera;
    self.cameraTrack_ = nil;
end


function prototype:initialize(trackObj)
    self.cameraTrack_ = trackObj;
    return self.super.initialize(self,trackObj);
end


function prototype:_update()
    if self.director.timeLine_ > self.trackLength_ then
        self.super.isPlaying_ = false;
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
    self.super.play(self);
    return true;
end


return prototype;