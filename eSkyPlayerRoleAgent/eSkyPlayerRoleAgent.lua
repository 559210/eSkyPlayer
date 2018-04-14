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
end


function prototype:initialize(role)  --参数role一般由G.characterFactory来createTempRole;
    self.roleObj_ = role;
    self.roleGameObject_ = self.roleObj_.body;
    self.roleObj_:shutDownMotion();
    self.animator_ = self.roleGameObject_:GetComponent("Animator");
    self.animatorStates_ = {"swapLeft", "swapRight"};
    self.stateIndex_ = 1;
    self.animatorOverrideContoller_ = UtilEx.createAnimatorOverrideController(self.animator_);  --TODO:评估一下是否要释放
    self.animator_.runtimeAnimatorController = self.animatorOverrideContoller_;
    self.morph_ = newClass("eSkyPlayer/misc/morphPlay");
    local mesh = GameObject.Find("mesh");
    local meshRenderer = mesh:GetComponent(typeof(SkinnedMeshRenderer));
    self.morph_:initialize(meshRenderer);
    return true;
end


function prototype:uninitialize()
    self.morph_:uninitialize();
    self.animator_ = nil;
    self.morph_ = nil;
end

function prototype:play(asset, speed, transitionDuration, fixedTime) -- asset为要播放动作的资源；speed为动画速度；transitionDuration为过渡的时间，单位为s；fixedTimed为目标状态的开始时间，单位为s；
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
    self.animator_.speed = speed;
end


function prototype:_changStateIndex()
    if self.stateIndex_ == 1 then
        self.stateIndex_ = 2;
    else
        self.stateIndex_ = 1;
    end
end

------------------------------------------------ Morph below

function prototype:playMorphWithoutReset(morphConfigInfo, controlPoints, duration, offsetTime)  --jsonBuff为asset.text;controlPoints为存放控制点的数组;duration表示时间范围;offsetTime表示偏移时间
    self.morph_:playWithoutReset(morphConfigInfo, controlPoints, duration, offsetTime);           --playMorphWithoutReset表示离开event时不清除表情各参数的数据
end

function prototype:playMorphWithReset(morphConfigInfo, controlPoints, duration, offsetTime)       --playMorphWithReset表示离开event时把表情各参数全部置0
    self.morph_:playWithReset(morphConfigInfo, controlPoints, duration, offsetTime);
end


function prototype:stopMorph()
    self.morph_:stop();
end

function prototype:resumeMorph()
    self.morph_:resume();
end

function prototype:resetMorph()
    self.morph_:reset();
end


return prototype;