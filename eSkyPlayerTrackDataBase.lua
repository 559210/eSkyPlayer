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
    self.eventsSupportted_ = nil;
    self.mainSceneModelPath_ = nil;
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


function prototype:isNeedAdditionalCamera()
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
    if trackType == definations.TRACK_FILE_TYPE.SCENE then
        local name = buff:ReadString();
        self.mainSceneModelPath_ = buff:ReadString();
    end
    return true;
end


function prototype:_loadFromBuff()
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

function prototype:isSupported(eventObj)
    for i = 1,#self.eventsSupportted_ do
        if self.eventsSupportted_[i] == eventObj:getEventType() then
            return true;
        end
    end
    return false;
end


function prototype.createObject()
    logError("eSkyPlayerTrackDataBase.createObject -----> ");
    return nil;
end


function prototype:addEvent(eventDataObject)

end


return prototype;