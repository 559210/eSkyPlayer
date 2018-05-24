local prototype = class("eSkyPlayerRoleMotionPlayer",require "eSkyPlayer/eSkyPlayerBase");


function prototype:ctor(director)
    self.base:ctor(director);
    self.roleAgent_ = nil;
    self.currentAnimatorSpeed_ = 0;
    self.transitionDuration_ = 0;
end


function prototype:initialize(trackObj)
    return self.base:initialize(trackObj);
end


function prototype:play()
    if self.roleAgent_ == nil then return end
    self.roleAgent_:setSpeed(self.currentAnimatorSpeed_);
    return self.base:play();
end


function prototype:onEventEntered(eventObj, beginTime)
    if self.roleAgent_ == nil then return end
    local path = eventObj.eventData_.resourcesNeeded_[1].path;
    local asset = self:getResource(eventObj, path);
    local transitionDuration = self.transitionDuration_;
    if eventObj.eventData_.timeLength_ < transitionDuration then
        transitionDuration_ = eventObj.eventData_.timeLength_;
    end
    local speed = eventObj.eventData_.motionLength / eventObj.eventData_.timeLength_;
    self.currentAnimatorSpeed_ = speed;
    local fixedTime = self.director_.timeLine_ - beginTime + eventObj.eventData_.beginTime;
    if self.director_.isPlaying_ == false then
        speed = 0;
    end
    self.roleAgent_:play(asset, speed, transitionDuration, fixedTime);
end


function prototype:onEventLeft(eventObj)
    if self.roleAgent_ == nil then return end
    self.roleAgent_:setSpeed(0);
end


function prototype:onCharacterEventEntered()
    self:seek(self.director_.timeLine_);
end


function prototype:seek(time)
    local preTime = -1;
    if #self.playingEvents_ == 1 then
        preTime = self.playingEvents_[1].beginTime_;
    end
    self.base:seek(time);
    if #self.playingEvents_ == 0 then
        self.currentAnimatorSpeed_ = 0;
    end
    if #self.playingEvents_ == 1 and self.playingEvents_[1].beginTime_ == preTime then
        self:onEventEntered(self.playingEvents_[1].obj_, self.playingEvents_[1].beginTime_);
    end
end


function prototype:stop()
    if self.roleAgent_ == nil then return end
    self.roleAgent_:setSpeed(0);
    self.base:stop();
end

function prototype:setRoleAgent(role)
    self.roleAgent_ = role;
end


return prototype;