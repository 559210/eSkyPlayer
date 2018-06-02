-- 此类为eSkyPlayer所有需要操作角色的代理类。目的为了解耦合，不依赖于项目中的角色对象。
-- 目前版本initialize函数接受G.characterFactory构造的角色对象。在此情况下：
    -- roleObj_ 是Characters类或者它的子类,通常由G.characterFactory创建。注意G.characterFactory依赖G.M.userModel
    -- 一般可以通过roleObj:getDefaultCharacter()拿到character对象，从character对象里的body可以拿到Animator，从而控制role的动作。
    -- local animator_ = roleObj:getDefaultCharacter().body:Getanimatoronent(typeof(Animator));

local prototype = class("eSkyPlayerRoleAgent");

prototype.SERIALIZE_FIELD = {
    "roleObj_",
    "roleGameObject_",
    "animator_",
    "currentAssetName_",
    "animatorStates_",
    "animatorOverrideContoller_",
    "stateIndex_",
    "morph_",
}

function prototype:ctor()
    self.roleObj_ = nil;
    self.roleGameObject_ = nil;
    self.animator_ = nil;
    self.currentAssetName_ = nil;
    self.morph_ = nil;
    self.animatorOverrideContoller_ = nil;
    self.animatorStates_ = {};
    self.stateIndex_ = 1;
    self.attachmentIndex_ = 0;
    self.attachmentContainer = {};
end


function prototype:initialize(role, isStopPre)  --参数role一般由G.characterFactory来createTempRole;isStopPre为是否停止之前role的标志
    if role == nil then
        self:uninitialize();  --清除所有的赋值；
        return;
    end
    if isStopPre == true then
        self:stop();  --停掉之前的；
    end
    self.roleObj_ = role;
    self.roleGameObject_ = self.roleObj_.body;
    self.roleObj_:shutDownMotion();
    self.animator_ = self.roleGameObject_:GetComponent("Animator");
    self.animatorStates_ = {"swapLeft", "swapRight"};
    -- self.stateIndex_ = 1;
    self.animatorOverrideContoller_ = UtilEx.createAnimatorOverrideController(self.animator_);  --TODO:评估一下是否要释放
    self.animator_.runtimeAnimatorController = self.animatorOverrideContoller_;
    self.morph_ = newClass("eSkyPlayer/misc/morphPlay");
    local mesh = GameObject.Find("mesh");
    local meshRenderer = mesh:GetComponent(typeof(SkinnedMeshRenderer));
    self.morph_:initialize(meshRenderer);
    self.skinnedMeshCombiner_ = self.roleGameObject_:GetComponent(typeof(SkinnedMeshCombiner));
    if not self.skinnedMeshCombiner_ then
        self.skinnedMeshCombiner_ = self.roleGameObject_:AddComponent(typeof(SkinnedMeshCombiner));
    end
    self.currentAssetName_ = nil;
    return true;
end


function prototype:uninitialize()
    self.morph_:uninitialize();
    self.roleObj_ = nil;
    self.roleGameObject_ = nil;
    self.animator_ = nil;
    self.morph_ = nil;
end


function prototype:stop()
    self:setSpeed(0);
    self:stopMorph();
end


function prototype:play(asset, speed, transitionDuration, fixedTime) -- asset为要播放动作的资源；speed为动画速度；transitionDuration为过渡的时间，单位为s；fixedTimed为目标状态的开始时间，单位为s；
    if self.roleObj_ == nil then 
        -- logError("xxxxxxxxxxxxxxxxxxxxx")
        return end
    local animatorState = self.animatorStates_[self.stateIndex_];
    if self.currentAssetName_ ~= asset.name then
        self.currentAssetName_ = asset.name;
        self:_changStateIndex();
        animatorState = self.animatorStates_[self.stateIndex_];

        self.animatorOverrideContoller_:set_Item(animatorState, asset);
    end
    self.animator_:CrossFadeInFixedTime(animatorState, transitionDuration, -1, fixedTime);
    if speed == 0 then
        self.animator_.speed = 1;
        self.animator_:Update(0.033);
    end
    self.animator_.speed = speed;
    return true;
end


function prototype:setSpeed(speed)
    if self.roleObj_ == nil then return end
    self.animator_.speed = speed;
end


function prototype:_changStateIndex()
    if self.roleObj_ == nil then return end
    if self.stateIndex_ == 1 then
        self.stateIndex_ = 2;
    else
        self.stateIndex_ = 1;
    end
end

------------------------------------------------ Morph below

function prototype:playMorph(morphConfigInfo, controlPoints, duration, offsetTime)  --jsonBuff为asset.text;controlPoints为存放控制点的数组;duration表示时间范围;offsetTime表示偏移时间
    if self.roleObj_ == nil then return end
    self.morph_:play(morphConfigInfo, controlPoints, duration, offsetTime);           --playMorphWithoutReset表示离开event时不清除表情各参数的数据
end

-- function prototype:playMorphWithReset(morphConfigInfo, controlPoints, duration, offsetTime)       --playMorphWithReset表示离开event时把表情各参数全部置0
--     if self.roleObj_ == nil then return end
--     self.morph_:playWithReset(morphConfigInfo, controlPoints, duration, offsetTime);
-- end


function prototype:stopMorph()
    if self.roleObj_ == nil then return end
    self.morph_:stop();
end

function prototype:resumeMorph()
    if self.roleObj_ == nil then return end
    self.morph_:resume();
end

function prototype:clearMorph()
    if self.roleObj_ == nil then return end
    self.morph_:clearMorphCurve();
end

-------------------------------------------- Addon below
function prototype:addAttachment(attachment, attachBoneNames, positionOffset, rotationOffset)  --同一个attachment如果被add两次，会允许被add，但可能会出现异常，暂未处理
    if self.roleObj_ == nil then return end
    self.attachmentIndex_ = self.attachmentIndex_ + 1;
    self.attachmentContainer[self.attachmentIndex_] = attachment;
    local item = attachment:getItem();
    self.skinnedMeshCombiner_:AddExtraAttachment(item, attachBoneNames, positionOffset, rotationOffset);
    return self.attachmentIndex_;
end


function prototype:removeAttachment(attachmentIndex)
    if self.roleObj_ == nil then return end
    local attachment = self.attachmentContainer[attachmentIndex];
    if attachment then
        self.attachmentContainer[attachmentIndex] = nil;
        local item = attachment:getItem();
        self.skinnedMeshCombiner_:RemoveExtraAttachment(item);
    end
end


------------------------------------------AvatarPart Blow
function prototype:equipAvatarPart(manItemCode, womanItemCode)
    if self.roleObj_ == nil then return end
    local itemCode = manItemCode;
    local sex = self.roleObj_.user.sex;
    if sex == SexEnum.FEMALE then
        itemCode = manItemCode;
    end
 
    if itemCode ~= -1 then
        self.roleObj_:equip(itemCode);
    end
    return itemCode;
end


function prototype:unequipAvatarPart(itemCode)
    if self.roleObj_ == nil then return end
    self.roleObj_:unequip(itemCode);
end


-------------------------------------------2DObject blow
function prototype:bindUI(gameObject, boneName, position, angle)
    if self.roleObj_ == nil then return end
    return self.roleObj_:bindUI(gameObject, boneName, position, angle);
end

function prototype:unBindUI(id)
    if self.roleObj_ == nil then return end
    return self.roleObj_:unbindUI(gameObject, boneName, position, angle);
end

return prototype;