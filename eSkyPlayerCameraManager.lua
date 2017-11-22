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

    self.eventData_.beginFrameX = buff:ReadFloat();
    self.eventData_.beginFrameY = buff:ReadFloat();
    self.eventData_.beginFrameZ = buff:ReadFloat();
    self.eventData_.beginDrX = buff:ReadFloat();
    self.eventData_.beginDrY = buff:ReadFloat();
    self.eventData_.beginDrZ = buff:ReadFloat();
    self.eventData_.beginLookAtX = buff:ReadFloat();
    self.eventData_.beginLookAtY = buff:ReadFloat();
    self.eventData_.beginLookAtZ = buff:ReadFloat();
    self.eventData_.endFrameX = buff:ReadFloat();
    self.eventData_.endFrameY = buff:ReadFloat();
    self.eventData_.endFrameZ = buff:ReadFloat();
    self.eventData_.endDrX = buff:ReadFloat();
    self.eventData_.endDrY = buff:ReadFloat();
    self.eventData_.endDrZ = buff:ReadFloat();
    self.eventData_.endLookAtX = buff:ReadFloat();
    self.eventData_.endLookAtY = buff:ReadFloat();
    self.eventData_.endLookAtZ = buff:ReadFloat();
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