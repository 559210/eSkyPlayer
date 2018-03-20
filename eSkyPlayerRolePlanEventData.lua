local prototype = class("eSkyPlayerRolePlanEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    self.base:ctor();
    self.eventType_ = definations.EVENT_TYPE.ROLE_PLAN;
end


function prototype:_loadFromBuff(buff)
    return true;
end


return prototype;