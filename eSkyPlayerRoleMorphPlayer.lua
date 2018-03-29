local prototype = class("eSkyPlayerRoleMorphPlayer",require "eSkyPlayer/eSkyPlayerBase");


function prototype:ctor(director)
    self.base:ctor(director);
end


function prototype:initialize(trackObj)
    return self.base:initialize(trackObj);
end


function prototype:play()
    return self.base:play();
end


function prototype:_update()
 
end



return prototype;