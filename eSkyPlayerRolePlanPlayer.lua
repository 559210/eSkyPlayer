local prototype = class("eSkyPlayerRolePlanPlayer",require "eSkyPlayer/eSkyPlayerBase");

function prototype:ctor(director)
    self.base:ctor(director);
end


function prototype:initialize(trackObj)
    return self.base:initialize(trackObj);
end


function prototype:play()
    return true;
end

function prototype:seek(time)
    return true;
end

return prototype;