local prototype = class("eSkyPlayerAvatarPartPlayer",require "eSkyPlayer/eSkyPlayerBase");


function prototype:ctor(director)
    self.base:ctor(director);
    self.roleAgent_ = nil;
end


function prototype:initialize(trackObj)
    return self.base:initialize(trackObj);
end



function prototype:onEventEntered(eventObj)
    if self.roleAgent_ == nil then return end
    local manItemCode = eventObj.eventData_.manItemCode_;
    local womanItemCode = eventObj.eventData_.womanItemCode_;
    eventObj.eventData_.itemCode_ = self.roleAgent_:equipAvatarPart(manItemCode, womanItemCode);
end


function prototype:onEventLeft(eventObj)
    if self.roleAgent_ == nil then return end
    local itemCode = eventObj.eventData_.itemCode_;
    if itemCode and itemCode ~= -1 then
        self.roleAgent_:unequipAvatarPart(itemCode);
        eventObj.eventData_.itemCode_ = nil;
    end
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
    if #self.playingEvents_ == 1 and self.playingEvents_[1].beginTime_ == preTime then
        self:onEventLeft(self.playingEvents_[1].obj_);
        self:onEventEntered(self.playingEvents_[1].obj_);
    end
end


function prototype:setRoleAgent(role)
    self.roleAgent_ = role;
end


return prototype;