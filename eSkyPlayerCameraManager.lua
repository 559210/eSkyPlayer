local prototype = class("eSkyPlayerCameraManager");


function prototype:ctor()
	-- body
end

function prototype:initialize()
	self.eventData_ = {};
	return true;
end

function prototype:loadCameraEventSync(filename)
    local buff = FileUtils.readAllBytes(filename);
    return self:_loadFromBuff(buff);
end

function prototype:_loadFromBuff(buff)
	if buff == nil then 
		return false; 
	end

    self.eventData_.version = buff:ReadShort();
    self.eventData_.smallVersion = buff:ReadShort();
    self.eventData_.eventType = buff:ReadByte();
    self.eventData_.timeLength = buff:ReadFloat();

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

function prototype:getEventDate(filename)
	self:loadCameraEventSync(filename);
	return self.eventData_;
end

return prototype;