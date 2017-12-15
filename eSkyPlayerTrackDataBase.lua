local prototype = class("eSkyPlayerTrackDataBase");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    self.trackType_ = definations.TRACK_TYPE.UNKOWN;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.UNKOWN;
    self.trackTimeLength_ = 0;
    self.events = {};
    self.title = nil;
end


function prototype:initialize()

    self.trackFile_ = {events = {}};
    return true;
end


function prototype:loadTrack(filename)
    local path = Util.AppDataRoot .. "/" ..filename;

    if string.match(filename,"^mod/plans") ~= nil then
        local a,b = string.find(filename,"mod/plans/.-/");
        local c,d = string.find(filename,"mod/plans/.-/.-/");
        self.title = string.sub(filename,b + 1,d - 1);
    end

    local buff = misc.readAllBytes(path);
    if self:_loadHeaderFromBuff(buff) == false then
        return false;
    end
    return self:_loadFromBuff(buff);
end


function prototype:_loadHeaderFromBuff(buff)

    if buff == nil then 
        return false; 
    end

    self.trackFile_.version = buff:ReadShort();
    self.trackFile_.smallVersion = buff:ReadShort();
    self.trackFile_.trackType = buff:ReadByte();
    if self.trackFile_.trackType ~= self.trackFileType_ then
        return false;
    end
    self.trackFile_.trackTitle = buff:ReadString();
    self.trackFile_.eventCount = buff:ReadShort();

    if self.trackFile_.eventCount == 0 then
        return true;
    end


    for e = 1, self.trackFile_.eventCount do
        local event = {};
        self.trackFile_.events [#self.trackFile_.events + 1] = event;
        event.beginTime = buff:ReadFloat();
        event.name = buff:ReadString();
        event.storeType = buff:ReadByte();
        event.isLoopPlay = misc.getBoolByByte(buff:ReadByte());
        event.labelID = buff:ReadByte();

        --需要考虑event类型，不一定是camera；
        local eventData = nil;
        
        if self.trackType_ == definations.TRACK_TYPE.CAMERA_PLAN then 
            eventData = newClass("eSkyPlayer/eSkyPlayerCameraPlanEventData");
            eventData:initialize();
            if eventData:loadEvent( "mod/plans/camera/" .. event.name) == false then 
                return false;
            end
        elseif self.trackType_ == definations.TRACK_TYPE.MOTION_PLAN then
            eventData = newClass("eSkyPlayer/eSkyPlayerMotionPlanEventData");
            eventData:initialize();
            if eventData:loadEvent( "mod/plans/motion/" .. event.name) == false then
                return false;
            end
        elseif self.trackType_ == definations.TRACK_TYPE.MUSIC_PLAN then
            eventData = newClass("eSkyPlayer/eSkyPlayerMusicPlanEventData");
            eventData:initialize();
            if eventData:loadEvent( "mod/plans/music/" .. event.name) == false then
                return false;
            end
        elseif self.trackType_ == definations.TRACK_TYPE.SCENE_PLAN then
            eventData = newClass("eSkyPlayer/eSkyPlayerScenePlanEventData");
            eventData:initialize();
            if eventData:loadEvent( "mod/plans/scene/" .. event.name) == false then
                return false;
            end
        elseif  self.trackType_ == definations.TRACK_TYPE.CAMERA_MOTION then
            if event.storeType == 1 then
                eventData = newClass("eSkyPlayer/eSkyPlayerCameraMotionEventData");
                eventData:initialize();
                
                if eventData:loadEvent( "mod/plans/camera/" .. self.title .. "/camera/" .. event.name .. ".byte") == false then
                    return false;
                end
            else
                eventData = newClass("eSkyPlayer/eSkyPlayerCameraMotionEventData");
                eventData:initialize();
                if eventData:loadEvent( "mod/events/camera/" .. event.name .. ".byte") == false then
                    return false;
                end
            end
        else
            return true;
        end
        self.events[#self.events + 1] = eventData;
    end
    if self.trackType_ == definations.TRACK_TYPE.CAMERA_PLAN or
        self.trackType_ == definations.TRACK_TYPE.MOTION_PLAN or
        self.trackType_ == definations.TRACK_TYPE.MUSIC_PLAN or
        self.trackType_ == definations.TRACK_TYPE.SCENE_PLAN then
        
        local project = self.events[#self.events]:getProjectData();
        self.trackTimeLength_ = project:getTimeLength();
    else
        self.trackTimeLength_ = self.trackFile_.events[self.trackFile_.eventCount].beginTime + self.events[self.trackFile_.eventCount].eventData_.timeLength;
    end
    return true;
end


function prototype:getTrackLength()
    return self.trackTimeLength_;
end


function prototype:getEventCount()
    return self.trackFile_.eventCount;
end

function prototype:_loadFromBuff()
    return true;
end

function prototype:getTrackType()
    return self.trackType_;
end

function prototype:getTrackData()
    return self.trackFile_;
end


function prototype:getEventAt(index)
    if index < 1 or index > #self.events then
        return false;
    end
    return self.events[index];
end


function prototype:getEventBeginTimeAt(index)
    if index < 1 or index > self.trackFile_.eventCount then
        return false;
    end
    return self.trackFile_.events[index].beginTime;
end

return prototype;