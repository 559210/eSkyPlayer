local prototype = class("eSkyPlayerRoleMotionPlayer",require "eSkyPlayer/eSkyPlayerBase");


function prototype:ctor(director)
    self.base:ctor(director);
    self.roleAgent_ = nil;
    self.currentAnimatorSpeed_ = 0;
    self.transitionDuration_ = 0;
end


function prototype:initialize(trackObj)
    self.roleAgent_ = self.director_:getRole();
    return self.base:initialize(trackObj);
end


function prototype:play()
    self.roleAgent_:setSpeed(self.currentAnimatorSpeed_);
    return self.base:play();
end


function prototype:onEventEntered(eventObj, beginTime)
    local tactic = self.resourceTactics_[eventObj.resourceManagerTacticType_];
    if tactic == nil then
        logError("tactic error");
    end
    local path = eventObj.eventData_.resourcesNeeded_[1].path;
    local asset = tactic:getResource(path);
    if eventObj.eventData_.timeLength_ < self.currentAnimatorSpeed_ then
        self.currentAnimatorSpeed_ = eventObj.eventData_.timeLength_;
    end
    local speed = eventObj.eventData_.motionLength / eventObj.eventData_.timeLength_;
    self.currentAnimatorSpeed_ = speed;
    local fixedTime = self.director_.timeLine_ - beginTime + eventObj.eventData_.beginTime;
    if self.director_.isPlaying_ == false then
        speed = 0;
    end
    self.roleAgent_:play(asset, speed, self.transitionDuration_, fixedTime);
end


function prototype:onEventLeft(eventObj)
    self.roleAgent_:setSpeed(0);
end


function prototype:seek(time)
    local preTime = -1;
    if #self.playingEvents_ == 1 then
        preTime = self.playingEvents_[1].beginTime_;
    end
    self.base:seek();
    if #self.playingEvents_ == 0 then
        self.currentAnimatorSpeed_ = 0;
    end
    if #self.playingEvents_ == 1 and self.playingEvents_[1].beginTime_ == preTime then
        self:onEventEntered(self.playingEvents_[1].obj_, self.playingEvents_[1].beginTime_);
    end
end


function prototype:stop()
    self.roleAgent_:setSpeed(0);
    self.base:stop();
end

function prototype:_update()
    self.base:_update();
end



return prototype;