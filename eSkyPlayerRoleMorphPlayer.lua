local prototype = class("eSkyPlayerRoleMorphPlayer",require "eSkyPlayer/eSkyPlayerBase");

prototype.SERIALIZE_FIELD = {
    "roleAgent_",
}

function prototype:ctor(director)
    self.base:ctor(director);
    self.roleAgent_ = nil;
end


function prototype:initialize(trackObj)
    return self.base:initialize(trackObj);
end


function prototype:onEventEntered(eventObj, beginTime)
    if self.roleAgent_ == nil then return end
    local morphConfigInfo = eventObj.eventData_.morphConfigInfo_;
    local controlPoints = eventObj.eventData_.curveConfigPoints_;
    local duration = eventObj:getTimeLength();
    local offsetTime = self.director_.timeLine_ - beginTime;
    if self.director_.isPlaying_ == true then
        self.roleAgent_:resumeMorph();
    end
    self.roleAgent_:playMorph(morphConfigInfo, controlPoints, duration, offsetTime);
end


function prototype:onEventLeft(eventObj)
    if self.roleAgent_ == nil then return end
    self.roleAgent_:clearMorph();
end


function prototype:onCharacterEventEntered()
    self:seek(self.director_.timeLine_);
end


function prototype:seek(time)
    -- if self.roleAgent_ == nil then return end
    -- self.roleAgent_:resetMorph();
    -- local preFrame = {};
    -- local track = self.trackObj_;
    -- local eventCount = self.trackObj_:getEventCount();
    -- for i = 1, eventCount do
    --     local event = track:getEventAt(i);
    --     local offsetTime = event:getTimeLength();
    --     local beginTime = track:getEventBeginTimeAt(i);
    --     local endTime = beginTime + offsetTime;
    --     local temp = {};
    --     temp.event = event;
    --     if time < endTime then  --需要调整一下顺序
    --         if time >= beginTime then
    --             temp.offsetTime = time - beginTime;
    --             preFrame[#preFrame + 1] = temp;
    --         end
    --         break;
    --     end
        
    --     temp.offsetTime = offsetTime;
    --     preFrame[#preFrame + 1] = temp;
    -- end

    -- for i = 1, #preFrame do
    --     local morphConfigInfo = preFrame[i].event.eventData_.morphConfigInfo_;
    --     local controlPoints = preFrame[i].event.eventData_.curveConfigPoints_;
    --     local duration = preFrame[i].event:getTimeLength();
    --     self.roleAgent_:playMorphWithoutReset(morphConfigInfo, controlPoints, duration, preFrame[i].offsetTime);
    -- end
    -- self.base:seek(time);
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


function prototype:play()
    if self.roleAgent_ == nil then return end
    self.roleAgent_:resumeMorph();
    return self.base:play();
end

function prototype:stop()
    if self.roleAgent_ == nil then return end
    self.roleAgent_:stopMorph();
    self.base:stop();
end

function prototype:setRoleAgent(role)
    self.roleAgent_ = role;
end

return prototype;