local prototype = class("eSkyPlayerCameraPlanEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    self.base:ctor();
    self.eventType_ = definations.EVENT_TYPE.CAMERA_PLAN;
end


function prototype:_loadFromBuff(buff)
    return true;
end


return prototype;