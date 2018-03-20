local prototype = class("eSkyPlayerScenePlanTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

function prototype:ctor()
    prototype.super.ctor(self);
    self.trackType_ = definations.TRACK_TYPE.SCENE_PLAN;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.SCENE;
    self.eventsSupportted_ = {definations.EVENT_TYPE.SCENE_PLAN};
end

function prototype:_loadFromBuff(buff)
	if buff == nil then return false; end
	buff:ReadString(); --name 
	self:_setParam({stagePath = buff:ReadString()});
	local eventCount = buff:ReadShort();
    if eventCount == 0 then
        return true;
    end
    for i = 1, eventCount do
    	local eventFile = {};
        local eventObj = nil;
        if self.eventsSupportted_ == nil then
            return false;
        end
        eventFile.beginTime_ = buff:ReadFloat();
        eventFile.name_ = buff:ReadString();
        eventFile.storeType_ = buff:ReadByte();
        eventFile.isLoopPlay_ = misc.getBoolByByte(buff:ReadByte());
        eventFile.labelID_ = buff:ReadByte();
        eventObj = newClass("eSkyPlayer/eSkyPlayerScenePlanEventData");
        eventObj:initialize();
        if self:isSupported(eventObj) == false then
            return false;
        end
        if eventObj:loadEvent("mod/plans/scene/" .. eventFile.name_) == false then
            return false;
        end
        self:_insertEvent(eventFile,eventObj);
    end
    return true;
end


function prototype:_setParam(param)
    return true;
end

return prototype;