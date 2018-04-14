local prototype = class("eSkyPlayerRoleMorphPlayer",require "eSkyPlayer/eSkyPlayerBase");

prototype.SERIALIZE_FIELD = {
    "roleAgent_",
}

function prototype:ctor(director)
    self.base:ctor(director);
    self.roleAgent_ = nil;
end


function prototype:initialize(trackObj)
    self.roleAgent_ = self.director_:getRole();
    return self.base:initialize(trackObj);
end


function prototype:onEventEntered(eventObj, beginTime)
    local morphConfigInfo = eventObj.eventData_.morphConfigInfo_;
    local controlPoints = eventObj.eventData_.curveConfigPoints_;
    local duration = eventObj:getTimeLength();
    local offsetTime = self.director_.timeLine_ - beginTime;
    self.roleAgent_:playMorphWithoutReset(morphConfigInfo, controlPoints, duration, offsetTime);
end


function prototype:seek(time)
    self.roleAgent_:resetMorph();
    local preFrame = {};
    local track = self.trackObj_;
    local eventCount = self.trackObj_:getEventCount();
    for i = 1, eventCount do
        local event = track:getEventAt(i);
        local offsetTime = event:getTimeLength();
        local beginTime = track:getEventBeginTimeAt(i);
        local endTime = beginTime + offsetTime;
        local temp = {};
        temp.event = event;
        if time < endTime then
            if time >= beginTime then
                temp.offsetTime = time - beginTime;
                preFrame[#preFrame + 1] = temp;
            end
            break;
        end
        
        temp.offsetTime = offsetTime;
        preFrame[#preFrame + 1] = temp;
    end

    for i = 1, #preFrame do
        local morphConfigInfo = preFrame[i].event.eventData_.morphConfigInfo_;
        local controlPoints = preFrame[i].event.eventData_.curveConfigPoints_;
        local duration = preFrame[i].event:getTimeLength();
        self.roleAgent_:playMorphWithoutReset(morphConfigInfo, controlPoints, duration, preFrame[i].offsetTime);
    end
    self.base:seek(time);
end


function prototype:play()
    self.roleAgent_:resumeMorph();
    return self.base:play();
end

function prototype:stop()
    self.roleAgent_:stopMorph();
    self.base:stop();
end

return prototype;