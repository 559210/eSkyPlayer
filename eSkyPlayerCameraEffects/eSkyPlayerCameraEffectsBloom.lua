local prototype = class("eSkyPlayerCameraEffectBloom");


function prototype:ctor()
    -- body
    self.mainCamera = nil;
end

function prototype:initialize(camera)
    self.camera.gameObject:AddComponent("");
    return true;
end