local prototype = class("eSkyPlayerCameraMotionEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));



-- function prototype:ctor()
--  -- body
-- end



function prototype:_loadFromBuff(buff)

    local x = buff:ReadFloat();
    local y = buff:ReadFloat();
    local z = buff:ReadFloat();
    self.eventData_.beginFrame = Vector3.New(x, y, z);

    x = buff:ReadFloat();
    y = buff:ReadFloat();
    z = buff:ReadFloat();
    self.eventData_.beginDr = Quaternion.Euler(x, y, z);

    x = buff:ReadFloat();
    y = buff:ReadFloat();
    z = buff:ReadFloat();
    self.eventData_.beginLookAt = Vector3.New(x, y, z);

    x = buff:ReadFloat();
    y = buff:ReadFloat();
    z = buff:ReadFloat();
    self.eventData_.endFrame = Vector3.New(x, y, z);

    x = buff:ReadFloat();
    y = buff:ReadFloat();
    z = buff:ReadFloat();
    self.eventData_.endDr = Quaternion.Euler(x, y, z);

    x = buff:ReadFloat();
    y = buff:ReadFloat();
    z = buff:ReadFloat();
    self.eventData_.endLookAt = Vector3.New(x, y, z);


    self.eventData_.fov = buff:ReadFloat();
    self.eventData_.tweenType = buff:ReadByte();

    if self.eventData_.tweenType == 0 then
        self.eventData_.pos1 = {};
        self.eventData_.pos2 = {};
        self.eventData_.pos1.x = buff:ReadFloat();
        self.eventData_.pos1.y = buff:ReadFloat();
        self.eventData_.pos2.x = buff:ReadFloat();
        self.eventData_.pos2.y = buff:ReadFloat();
    end
    return true;
end


return prototype;
