local prototype = class("eSkyPlayerScenePlanPlayer",require "eSkyPlayer/eSkyPlayerBase");


function prototype:ctor(director)
    prototype.super.ctor(self, director);
end


function prototype:seek(time)
    return true;
end


function prototype:play()
    return true;
end

return prototype;