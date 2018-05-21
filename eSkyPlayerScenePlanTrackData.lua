local prototype = class("eSkyPlayerScenePlanTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

function prototype:ctor()
    prototype.super.ctor(self);
    self.trackType_ = definations.TRACK_TYPE.SCENE_PLAN;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.SCENE;
    self.eventsSupportted_ = {definations.EVENT_TYPE.SCENE_PLAN};
end

function prototype:_loadFromBuff(buff, name, nameTable)
	if buff == nil then return false; end
	local title = buff:ReadString(); --name 
    self.name_ = self:getTrackName(name, self.trackType_, title, nameTable);
	self:_setParam({stagePath = buff:ReadString()});
	local eventCount = buff:ReadShort();
    if eventCount == 0 then
        return true;
    end
    for i = 1, eventCount do
    	local beginTime = 0;
        local eventObj = nil;
        if self.eventsSupportted_ == nil then
            return false;
        end
        beginTime = buff:ReadFloat();
        local name = buff:ReadString();
        buff:ReadByte();--storeType_
        buff:ReadByte(); --isLoopPlay_ = misc.getBoolByByte(buff:ReadByte());
        buff:ReadByte();--labelID_
        eventObj = newClass("eSkyPlayer/eSkyPlayerScenePlanEventData");
        eventObj:initialize();
        if self:isSupported(eventObj) == false then
            return false;
        end
        if eventObj:loadEvent("mod/plans/scene/" .. name, self.name_, nameTable) == false then
            return false;
        end
        self:_insertEvent(beginTime, eventObj);
    end
    
    return true;
end


function prototype:_setParam(param)
    return true;
end

return prototype;