local prototype = class("eSkyPlayerCharacterPlayer",require "eSkyPlayer/eSkyPlayerBase");


function prototype:ctor(director)
    self.base:ctor(director);
    self.role_ = nil;
    self.roleAgent_ = nil;
end


function prototype:initialize(trackObj)
    self.roleAgent_ = newClass("eSkyPlayer/eSkyPlayerRoleAgent/eSkyPlayerRoleAgent");
    return self.base:initialize(trackObj);
end


function prototype:uninitialize()
    self:destroy();
end


function prototype:onEventEntered(eventObj)
    self:destroy();
    local itemCodes = eventObj.eventData_.roleConfig_.itemCodes;
    local skeletonUrl = eventObj.eventData_.roleConfig_.skeletonUrl;
    self.role_ = G.characterFactory:createTempRole(itemCodes, {}, false, skeletonUrl, true);
    self.role_:refresh();
    self.roleAgent_:initialize(self.role_);
end


function prototype:seek(time)
    local lastEvent = nil;
    local lastEventBeginTime = 0;
    local track = self:getTrack();
    for i = 1, track:getEventCount() do
        local event = track:getEventAt(i);
        local beginTime = event:getCurrentBeginTime();
        if time >= beginTime then
            lastEvent = event;
            lastEventBeginTime = beginTime;
        end
        if time < beginTime then
            if i == self.index_ then
                lastEvent = nil;
            end
            break;
        end
    end
    if lastEvent ~= nil then
        self:onEventEntered(lastEvent);
    end
    self.base:seek(time);
end

function prototype:getRoleAgent()
    return self.roleAgent_;
end


function prototype:destroy()
    if self.role_ ~= nil then
        self.roleAgent_:initialize(nil);
        G.characterFactory:destroyRole(self.role_);
    end
end

return prototype;