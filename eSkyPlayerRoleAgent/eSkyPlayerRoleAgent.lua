-- 此类为eSkyPlayer所有需要操作角色的代理类。目的为了解耦合，不依赖于项目中的角色对象。
-- 目前版本initialize函数接受G.characterFactory构造的角色对象。在此情况下：
    -- roleObj_ 是Characters类或者它的子类,通常由G.characterFactory创建。注意G.characterFactory依赖G.M.userModel
    -- 一般可以通过roleObj:getDefaultCharacter()拿到character对象，从character对象里的body可以拿到Animator，从而控制role的动作。
    -- local animator = roleObj:getDefaultCharacter().body:GetComponent(typeof(Animator));

local prototype = class("eSkyPlayerRoleAgent");

prototype.SERIALIZE_FIELD = {
    "roleObj_",
}

function prototype:ctor()
end


function prototype:initialize(role)
    self.roleObj_ = role;
    return true;
end


return prototype;