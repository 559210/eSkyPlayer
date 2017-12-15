local prototype = class("eSkyPlayerCameraEffectsBase");


function prototype:ctor()
    -- body
    self.mainCamera = nil;
    self.effectId = -1;
end

function prototype:initialize(camera)
    self.camera.gameObject:AddComponent("");
    return true;
end