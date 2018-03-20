local prototype = class("eSkyPlayerCameraPlanPlayer",require "eSkyPlayer/eSkyPlayerBase");

function prototype:ctor(director)
    prototype.super.ctor(self, director);
end


function prototype:play()
    return true;
end


function prototype:seek(time)
    return true;
end


return prototype;