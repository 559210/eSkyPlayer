local prototype = class("eSkyPlayerCameraTrackManager");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

function prototype:ctor()
	-- body
end

function prototype:initialize()
	self.trackFile_ = {events = {}};
	return true;
end

function prototype:loadCameraTrackEventSync(filename)
    local buff = FileUtils.readAllBytes(filename);
    return self:_loadFromBuff(buff);
end

function prototype:_loadFromBuff(buff)
	if buff == nil then 
		return false; 
	end

	self.trackFile_.version = buff:ReadShort();
    self.trackFile_.smallVersion = buff:ReadShort();
    self.trackFile_.trackType = buff:ReadByte();
    self.trackFile_.trackTitle = buff:ReadString();
    self.trackFile_.eventCount = buff:ReadShort();
    for e = 1, self.trackFile_.eventCount do
        local event = {};
        self.trackFile_.events [#self.trackFile_.events + 1] = event;
        event.beginTime = buff:ReadFloat();
        event.name = buff:ReadString();
        event.storeType = buff:ReadByte();
        event.isLoopPlay = misc.getBoolByByte(buff:ReadByte());
        event.labelID = buff:ReadByte();
        if event.labelID ~= 0 then
            event.labelName = buff:ReadString();
            event.sceneName = buff:ReadString();
        end

        local cEvent = newClass("eSkyPlayer/eSkyPlayerCameraManager");
        cEvent:initialize();

        if event.storeType == 1 then
            event.date = cEvent:getEventDate("D:/DD_Client/mod/plans/camera/c0001/camera/" .. event.name .. ".byte");
        else
            event.date = cEvent:getEventDate("D:/DD_Client/mod/events/camera/" .. event.name .. ".byte");
        end
    end
    return true;
end


return prototype;