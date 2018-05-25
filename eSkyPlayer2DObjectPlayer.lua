local prototype = class("eSkyPlayer2DObjectPlayer",require "eSkyPlayer/eSkyPlayerBase");


function prototype:ctor(director)
    self.base:ctor(director);
    self.roleAgent_ = nil;
    self.bubbleID = -1;
end


function prototype:initialize(trackObj)
    return self.base:initialize(trackObj);
end



function prototype:onEventEntered(eventObj, beginTime)
    if self.roleAgent_ == nil then return end
    if self.rootNode == nil then
        self.rootNode = newGameObject("2DObjectRootNode");
        setLayer(self.rootNode, ESkyCameraInfos.player.layer);
    end
    local pkgName = eventObj.eventData_.pkgName_;
    local resName = eventObj.eventData_.resName_;
    self.chatBubble = create2DGPanel(pkgName, resName, self.rootNode.transform);
    local bubbleText = findChild(self.chatBubble.ui, "wordsInput");
    if bubbleText then
        bubbleText.text = eventObj.eventData_.dialogContext_;
    end  
    local boneName = eventObj.eventData_.boneName_;
    local position = eventObj.eventData_.pos_ + Vector3.New(- 0.15, 0.25, 0);
    local angle = eventObj.eventData_.angle_;
    self.bubbleID = self.roleAgent_:bindUI(self.chatBubble.gameObject, boneName, position, angle);
end


function prototype:onEventLeft(eventObj)
    if self.bubbleID == -1 or self.roleAgent_ == nil then return end
    self.roleAgent_:unequipAvatarPart(self.bubbleID);
    destroy(self.chatBubble);
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