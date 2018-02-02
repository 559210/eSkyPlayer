local prototype = class("eSkyPlayerSceneTrackDataBase", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    prototype.super.ctor(self);
end


function prototype:_loadFromBuff(buff)
    if buff == nil then 
        return false; 
    end


    local eventCount = buff:ReadShort();
    if eventCount == 0 then
        return true;
    end

    for e = 1, eventCount do
        local eventFile = {};
        local eventObj = nil;

        if self.eventsSupportted_ == nil then
            return false;
        end

        eventFile.beginTime = buff:ReadFloat();
        eventFile.name = buff:ReadString();
        eventFile.storeType = buff:ReadByte();
        eventFile.isLoopPlay = misc.getBoolByByte(buff:ReadByte());
        eventFile.labelID = buff:ReadByte();
        if self.trackType_ == definations.TRACK_TYPE.SCENE_PLAN then
            eventObj = newClass("eSkyPlayer/eSkyPlayerScenePlanEventData");
            eventObj:initialize();
            if self:isSupported(eventObj) == false then
                return false;
            end
            if eventObj:loadEvent("mod/plans/scene/" .. eventFile.name) == false then
                return false;
            end
        elseif self.trackType_ == definations.TRACK_TYPE.SCENE_MOTION then
            eventObj = newClass("eSkyPlayer/eSkyPlayerSceneMotionEventData");
            eventObj:initialize();
            if self:isSupported(eventObj) == false then
                return false;
            end
            local scene_path = string.format("mod/plans/scene/" ..self.title_ .."/scene/" ..eventFile.name ..".byte");
            if eventObj:loadEvent(scene_path) == false then
                return false;
            end
        else
            return true;
        end
        self:_insertEvent(eventFile,eventObj);
    end

    if self.trackType_ == definations.TRACK_TYPE.SCENE_PLAN then
        
        local project = self.events_[#self.events_].eventObj:getProjectData();
        self.trackTimeLength_ = project:getTimeLength();
    else
        self.trackTimeLength_ = self.events_[#self.events_].eventFile.beginTime + self.events_[#self.events_].eventObj.eventData_.timeLength;
    end
    return true;
end



return prototype;