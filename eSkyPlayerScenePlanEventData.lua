local prototype = class("eSkyPlayerScenePlanEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    self.base:ctor();
    self.eventType_ = definations.EVENT_TYPE.SCENE_PLAN;
end


function prototype:_loadFromBuff(buff)
    return true;
end

function prototype.createObject(param)
    local obj = prototype:create();
    return obj;
end

return prototype;