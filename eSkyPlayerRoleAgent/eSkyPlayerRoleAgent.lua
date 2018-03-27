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
}

function prototype:ctor()
    self.roleObj_ = nil;
    self.roleGameObject_ = nil;
    self.animator_ = nil;
    self.currentAssetName_ = nil;
    self.animatorStates_ = {};
end


function prototype:initialize(role)  --参数role一般由G.characterFactory来createTempRole;
    self.roleObj_ = role;
    self.roleGameObject_ = self.roleObj_.body;
    self.roleObj_:shutDownMotion();
    self.animator_ = self.roleGameObject_:GetComponent("Animator");
    self.animatorStates_ = {"swapLeft", "swapRight"};
    self.stateIndex = 1;
    self.animatorOverrideContoller = UtilEx.createAnimatorOverrideController(self.animator_);  --TODO:评估一下是否要释放
    self.animator_.runtimeAnimatorController = self.animatorOverrideContoller;
    return true;
end


function prototype:play(asset, speed, transitionDuration, fixedTime) -- asset为要播放动作的资源；speed为动画速度；transitionDuration为过渡的时间，单位为s；fixedTimed为目标状态的开始时间，单位为s；
    self.animator_.speed = speed;
    local animatorState = self.animatorStates_[self.stateIndex];

    if self.currentAssetName_ ~= asset.name then
        self.currentAssetName_ = asset.name;
        self:_changStateIndex();
        animatorState = self.animatorStates_[self.stateIndex];
        self.animatorOverrideContoller:set_Item(animatorState, asset);
    end
    self.animator_:CrossFadeInFixedTime(animatorState, transitionDuration, -1, fixedTime);
    if speed == 0 then
        self.animator_:Update(0.033);
    end
    return true;
end


function prototype:setSpeed(speed)
    self.animator_.speed = speed;
end


function prototype:_changStateIndex()
        if self.stateIndex == 1 then
        self.stateIndex = 2;
    else
        self.stateIndex = 1;
    end
end


return prototype;