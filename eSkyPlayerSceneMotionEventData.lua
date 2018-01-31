local prototype = class("eSkyPlayerSceneMotionEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    self.base:ctor();
    self.eventType_ = definations.EVENT_TYPE.SCENE_MOTION;
end


function prototype:_loadFromBuff(buff)
    self.eventData_.beginCut = buff:ReadFloat();
    self.eventData_.endCut = buff:ReadFloat();
    self.eventData_.animation = buff:ReadString();
    return true;
end


return prototype;