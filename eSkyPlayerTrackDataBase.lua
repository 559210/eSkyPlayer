local prototype = class("eSkyPlayerTrackDataBase");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    self.trackType_ = definations.TRACK_TYPE.UNKOWN;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.UNKOWN;
    self.trackTimeLength_ = 0;
    self.events_ = {};
    self.title_ = nil;
    self.pathHeader_ = nil;
end


function prototype:initialize()

end


function prototype:loadTrack(filename)
    self.filename = filename;
    local path = Util.AppDataRoot .. "/" ..filename;
    if string.match(filename,"^mod/plans") ~= nil then
        local a,b = string.find(filename,"mod/plans/.-/");
        local c,d = string.find(filename,"mod/plans/.-/.-/");
        self.title_ = string.sub(filename,b + 1,d - 1);
    elseif string.match(filename,"^mod/projects") ~= nil then
        local a,b = string.find(filename,"mod/projects/");
        local c,d = string.find(filename,"mod/projects/.-/");
        self.title_ = string.sub(filename, b + 1, d - 1);
        self.pathHeader_ = string.match(filename,"mod/projects/.+/");
    end
    local buff = misc.readAllBytes(path);
    if self:_loadHeaderFromBuff(buff) == false then
        return false;
    end
    return self:_loadFromBuff(buff);
end


function prototype:getTrackLength()
    return self.trackTimeLength_;
end


function prototype:getEventCount()
    return #self.events_;
end


function prototype:getTrackType()
    return self.trackType_;
end

-- function prototype:getTrackData()
--     return self.trackFile_;
-- end


function prototype:getEventAt(index)
    if index < 1 or index > #self.events_ then
        return false;
    end
    return self.events_[index].eventObj;
end


function prototype:getEventBeginTimeAt(index)
    if index < 1 or index > #self.events_ then
        return false;
    end
    return self.events_[index].eventFile.beginTime;
end


function prototype:getResources()
    return nil;
end

function prototype:isOverlapped()
    for i = 1, #self.events_ - 1 do
        if self.events_[i].eventObj : isProject() == false then
            if self.events_[i].eventFile.beginTime + self.events_[i].eventObj.eventData_.timeLength > self.events_[i + 1].eventFile.beginTime then
                return true;
            end
        end
    end
    return false;
end

function prototype:_loadHeaderFromBuff(buff)
    if buff == nil then 
        return false; 
    end

    local version = buff:ReadShort();
    local smallVersion = buff:ReadShort();
    local trackType = buff:ReadByte();
    if trackType ~= self.trackFileType_ then
        return false;
    end
    self.trackTitle = buff:ReadString();
    local eventCount = buff:ReadShort();

    if eventCount == 0 then
        return true;
    end


    for e = 1, eventCount do
        local eventFile = {};
        local eventObj = nil;


        eventFile.beginTime = buff:ReadFloat();
        eventFile.name = buff:ReadString();
        eventFile.storeType = buff:ReadByte();
        eventFile.isLoopPlay = misc.getBoolByByte(buff:ReadByte());
        eventFile.labelID = buff:ReadByte();

        --需要考虑event类型，不一定是camera；
        
        if self.trackType_ == definations.TRACK_TYPE.CAMERA_PLAN then 
            eventObj = newClass("eSkyPlayer/eSkyPlayerCameraPlanEventData");
            eventObj:initialize();
            if eventFile.storeType == 1 then
                if eventObj:loadEvent( self.pathHeader_ .. "plans/camera/" .. eventFile.name) == false then 
                    return false;
                end
            else 
                if eventObj:loadEvent( "mod/plans/camera/" .. eventFile.name) == false then 
                    return false;
                end
            end
        elseif self.trackType_ == definations.TRACK_TYPE.MOTION_PLAN then
            eventObj = newClass("eSkyPlayer/eSkyPlayerMotionPlanEventData");
            eventObj:initialize();
            if eventObj:loadEvent( "mod/plans/motion/" .. eventFile.name) == false then
                return false;
            end
        elseif self.trackType_ == definations.TRACK_TYPE.MUSIC_PLAN then
            eventObj = newClass("eSkyPlayer/eSkyPlayerMusicPlanEventData");
            eventObj:initialize();
            if eventObj:loadEvent( "mod/plans/music/" .. eventFile.name) == false then
                return false;
            end
        elseif self.trackType_ == definations.TRACK_TYPE.SCENE_PLAN then
            eventObj = newClass("eSkyPlayer/eSkyPlayerScenePlanEventData");
            eventObj:initialize();
            if eventObj:loadEvent( "mod/plans/scene/" .. eventFile.name) == false then
                return false;
            end
        elseif self.trackType_ == definations.TRACK_TYPE.CAMERA_MOTION then
            eventObj = newClass("eSkyPlayer/eSkyPlayerCameraMotionEventData");
            eventObj:initialize();
            if eventFile.storeType == 0 then
                if eventObj:loadEvent( "mod/events/camera/" .. eventFile.name .. ".byte") == false then
                    return false;
                end
            else
                if self.pathHeader_ == nil then 
                    if eventObj:loadEvent( "mod/plans/camera/" .. self.title_ .. "/camera/" .. eventFile.name .. ".byte") == false then
                        return false;
                    end 
                else 
                    if eventObj:loadEvent(self.pathHeader_ .. "camera/" .. eventFile.name) ==false then
                        return false;
                    end
                end
            end
        elseif self.trackType_ == definations.TRACK_TYPE.CAMERA_EFFECT then
            local path = nil;
            if self.storeType == 0 then
                path = Util.AppDataRoot .. "/mod/events/cameraMotion" .. eventFile.name .. ".byte";
            else
                if self.pathHeader_ == nil then 
                    path = Util.AppDataRoot .. "/mod/plans/camera/" .. self.title_ .. "/cameraMotion/" .. eventFile.name .. ".byte";
                else 
                    path = Util.AppDataRoot .. "/" .. self.pathHeader_ .. "cameraMotion/" .. eventFile.name .. ".byte";
                end
            end
            local buff = misc.readAllBytes(path);
            buff:SetReaderPosition(9);
            local temp = buff:ReadByte();
            if temp == definations.CAMERA_MOTION_TYPE.BLOOM then
                eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectBloomEventData");
                eventObj:initialize();
                eventObj.eventData_ = {};
                local temp = buff:SetReaderPosition(0);
                if eventObj:_loadHeaderFromBuff(buff) == false then
                    return false;
                end
                if eventObj:_loadFromBuff(buff) == false then
                    return false;
                end
            end
        else
            return true;
        end
        self:_insertEvent(eventFile,eventObj);
    end

    if self.trackType_ == definations.TRACK_TYPE.CAMERA_PLAN or
        self.trackType_ == definations.TRACK_TYPE.MOTION_PLAN or
        self.trackType_ == definations.TRACK_TYPE.MUSIC_PLAN or
        self.trackType_ == definations.TRACK_TYPE.SCENE_PLAN then
        
        local project = self.events_[#self.events_].eventObj:getProjectData();
        self.trackTimeLength_ = project:getTimeLength();
    else
        self.trackTimeLength_ = self.events_[#self.events_].eventFile.beginTime + self.events_[#self.events_].eventObj.eventData_.timeLength;
    end
    return true;
end


function prototype:_insertEvent(eventFile,eventObj)
    local event = {};
    event.eventFile = eventFile;
    event.eventObj = eventObj;
    if #self.events_ == 0 then
        self.events_[1] = event;
        return;
    end
    local isSorted = false;
    for m = 1, #self.events_ do
        local i = #self.events_ - m + 1;
        if self.events_[i].eventFile.beginTime < eventFile.beginTime then
            for j = i, #self.events_ do
                local index = #self.events_ - j + i;
                self.events_[index + 2] = self.events_[index + 1];
            end
            self.events_[i + 1] = event;
            isSorted = true;
            break;
        end
    end
    if isSorted == false then
        for i = 1, #self.events_ do
            local index = #self.events_ - i + 1;
            self.events_[index + 1] = self.events_[index];
        end
        self.events_[1] = event;
    end
end


function prototype:_loadFromBuff()
    return true;
end

return prototype;