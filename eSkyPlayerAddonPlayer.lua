local prototype = class("eSkyPlayerAddonPlayer",require "eSkyPlayer/eSkyPlayerBase");


function prototype:ctor(director)
    prototype.super.ctor(self, director);
    self.attachemnt_ = nil;
end


function prototype:initialize(trackObj)
    return self.base:initialize(trackObj);
end


function prototype:play()
    self.base:play();
    return true;
end


function prototype:onEventEntered(eventObj, beginTime)
    local path = eventObj.eventData_.resourcesNeeded_[1].path;
    local asset = self:getResource(eventObj, path);
    local boneNames = eventObj.eventData_.boneNames_;
    self.attachemnt_ = newClass("eSkyPlayer/eSkyPlayerRoleAgent/eSkyPlayerAttachmentAgent", asset);
    self.attachemnt_:initialize();
    local pos = eventObj.eventData_.pos_;
    local angle = eventObj.eventData_.angle_;
    self.attachemntIndex_ = self.roleAgent_:addAttachment(self.attachemnt_, boneNames, pos, angle);  
end


function prototype:onEventLeft(eventObj)
    self.roleAgent_:removeAttachment(self.attachemntIndex_);
    self.attachemnt_ = nil;
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
        self:onEventLeft(self.playingEvents_[1].obj_);
        self:onEventEntered(self.playingEvents_[1].obj_, self.playingEvents_[1].beginTime_);
    end
end


function prototype:setRoleAgent(role)
    self.roleAgent_ = role;
end

return prototype;