local prototype = class("morphPlay");

prototype.SERIALIZE_FIELD = {
    "morphCurve_",
    "currentTime_",
    "isPlaying_",
    "meshRenderer_",
    "comp_",
    "updateID_",
}

function prototype:ctor()
    self.morphCurve_ = {}; --键值对，键为BlendShapeIndex，值为对应的BezierCurve对象
    self.currentTime_ = 0;
    self.updateID_ = -1;
    self.isPlaying_ = false;
    self.meshRenderer_ = nil;
    self.comp_ = nil;
end

function prototype:initialize(meshRenderer)
    self.meshRenderer_ = meshRenderer;
    self.comp_ = self.meshRenderer_.gameObject:AddComponent(typeof(UpdateForLua));
    self.updateID_ = self.comp_:addUpdate(delegate(self, self._update));
end


function prototype:uninitialize()
    self.comp_:removeUpdate(self.updateID_);
    destroy(self.comp_, true);
end


function prototype:play(morphConfigInfo, controlPoints, duration, offsetTime)
    if controlPoints == nil then
        return;
    end
    for name,value in pairs(morphConfigInfo) do
        if value > 0 then
            local curve = newClass("eSkyPlayer/misc/BezierCurve");
            curve:initialize(controlPoints, duration, value);
            curve:creatCurve();
            local morphIndex = self.meshRenderer_.sharedMesh:GetBlendShapeIndex(name);
            self.morphCurve_[morphIndex] = curve;
        end
    end
    self.currentTime_ = offsetTime;
    if self.isPlaying_ == false then
        self.isPlaying_ = true;
        self:_update(0);
        self.isPlaying_ = false;
    else
        self:_update(0);
    end
end


-- function prototype:playWithReset(morphConfigInfo, controlPoints, duration, offsetTime)
--     self:reset();
--     self:playWithoutReset(morphConfigInfo, controlPoints, duration, offsetTime);
-- end


function prototype:stop()
    self.isPlaying_ = false;
end

function prototype:resume()
    self.isPlaying_ = true;
end


-- function prototype:reset()    
--     local count = self.meshRenderer_.sharedMesh.blendShapeCount;
--     for i = 0, count - 1 do
--         self.meshRenderer_:SetBlendShapeWeight(i, 0);
--     end
-- end


function prototype:_update(dt)
    if self.isPlaying_ == false or self.meshRenderer_ == nil then
        return;
    end
    self.currentTime_ = self.currentTime_ + dt;
    for k, v in pairs(self.morphCurve_) do
        local value = v:evaluate(self.currentTime_);
        self.meshRenderer_:SetBlendShapeWeight(k, value);
    end
end

function prototype:clearMorphCurve()
    local count = self.meshRenderer_.sharedMesh.blendShapeCount;     --把SkinnedMeshRenderer所有参数值赋0，
    for i = 0, count - 1 do
        self.meshRenderer_:SetBlendShapeWeight(i, 0);
    end
    for k, v in pairs(self.morphCurve_) do                          --把所有的曲线制空
        self.morphCurve_[k] = nil;
    end
end


return prototype;