local prototype = class("eSkyPlayerCameraMotionEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    self.base:ctor();
    self.eventType_ = definations.EVENT_TYPE.CAMERA_MOTION;
end



function prototype:_loadFromBuff(buff)

    local x = buff:ReadFloat();
    local y = buff:ReadFloat();
    local z = buff:ReadFloat();
    self.eventData_.beginFrame_ = Vector3.New(x, y, z);

    x = buff:ReadFloat();
    y = buff:ReadFloat();
    z = buff:ReadFloat();
    self.eventData_.beginDr_ = Quaternion.Euler(x, y, z);

    x = buff:ReadFloat();
    y = buff:ReadFloat();
    z = buff:ReadFloat();
    self.eventData_.beginLookAt_ = Vector3.New(x, y, z);

    x = buff:ReadFloat();
    y = buff:ReadFloat();
    z = buff:ReadFloat();
    self.eventData_.endFrame_ = Vector3.New(x, y, z);

    x = buff:ReadFloat();
    y = buff:ReadFloat();
    z = buff:ReadFloat();
    self.eventData_.endDr_ = Quaternion.Euler(x, y, z);

    x = buff:ReadFloat();
    y = buff:ReadFloat();
    z = buff:ReadFloat();
    self.eventData_.endLookAt_ = Vector3.New(x, y, z);


    self.eventData_.fov_ = buff:ReadFloat();
    self.eventData_.tweenType_ = buff:ReadByte();

    if self.eventData_.tweenType_ == 0 then
        self.eventData_.pos1_ = {};
        self.eventData_.pos2_ = {};
        self.eventData_.pos1_.x = buff:ReadFloat();
        self.eventData_.pos1_.y = buff:ReadFloat();
        self.eventData_.pos2_.x = buff:ReadFloat();
        self.eventData_.pos2_.y = buff:ReadFloat();
    end
    return true;
end


return prototype;
