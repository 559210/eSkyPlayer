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

        eventFile.beginTime_ = buff:ReadFloat();
        eventFile.name_ = buff:ReadString();
        eventFile.storeType_ = buff:ReadByte();
        eventFile.isLoopPlay_ = misc.getBoolByByte(buff:ReadByte());
        eventFile.labelID_ = buff:ReadByte();
        if self.trackType_ == definations.TRACK_TYPE.SCENE_PLAN then
            eventObj = newClass("eSkyPlayer/eSkyPlayerScenePlanEventData");
            eventObj:initialize();
            if self:isSupported(eventObj) == false then
                return false;
            end
            if eventObj:loadEvent("mod/plans/scene/" .. eventFile.name_) == false then
                return false;
            end
        elseif self.trackType_ == definations.TRACK_TYPE.SCENE_MOTION then
            eventObj = newClass("eSkyPlayer/eSkyPlayerSceneMotionEventData");
            eventObj:initialize();
            if self:isSupported(eventObj) == false then
                return false;
            end
            local scene_path = string.format("mod/plans/scene/" ..self.title_ .."/scene/" ..eventFile.name_ ..".byte");
            if eventObj:loadEvent(scene_path) == false then
                return false;
            end
        else
            return true;
        end
        self:_insertEvent(eventFile,eventObj);
    end

    -- if self.trackType_ == definations.TRACK_TYPE.SCENE_PLAN then
        
    --     local project = self.events_[#self.events_].eventObj_:getProjectData();
    --     self.trackTimeLength_ = project:getTimeLength();
    -- else
    --     self.trackTimeLength_ = self.events_[#self.events_].eventFile_.beginTime_ + self.events_[#self.events_].eventObj_.eventData_.timeLength_;
    -- end
    return true;
end



return prototype;