local prototype = class("eSkyPlayerTrackDataBase");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    self.title_ = nil;
    self.name_ = ""; --动态生成
    self.pathHeader_ = nil;
    self.eventsSupportted_ = nil;
    self.mainSceneModelPath_ = nil;
    self.events_ = {};
    self.resList_ = {};  --数组：存放开始时需要特定加载的资源，不通过策略类加载，path/count;
    self.resTable_ = {};  --键值对：存放通过策略类实现加载的资源，eventType/path;
    self.trackType_ = definations.TRACK_TYPE.UNKOWN;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.UNKOWN;
    self.resourceManagerTacticType_ = definations.MANAGER_TACTIC_TYPE.NO_NEED;
end


function prototype:initialize()
    return true;
end


function prototype:loadTrack(filename, name, nameTable)
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
    return self:_loadFromBuff(buff, name, nameTable);
end


function prototype:getTrackLength()
    if #self.events_ == 0 then
        return 0;
    end

    local trackLength = 0;
    if self.trackType_ == definations.TRACK_TYPE.CAMERA_PLAN or
        self.trackType_ == definations.TRACK_TYPE.ROLE_PLAN or
        self.trackType_ == definations.TRACK_TYPE.MUSIC_PLAN or
        self.trackType_ == definations.TRACK_TYPE.SCENE_PLAN then
        
        local project = self.events_[#self.events_].eventObj_:getProjectData();
        trackLength = project:getTimeLength();
    else
        trackLength = self.events_[#self.events_].eventFile_.beginTime_ + self.events_[#self.events_].eventObj_.eventData_.timeLength_;
    end
    return trackLength;
end


function prototype:getEventCount()
    return #self.events_;
end


function prototype:getTrackType()
    return self.trackType_;
end

function prototype:getTrackData()
    return self.trackFile_;
end


function prototype:getEventAt(index)
    if index < 1 or index > #self.events_ then
        return nil;
    end
    return self.events_[index].eventObj_;
end


function prototype:getEventBeginTimeAt(index)
    if index < 1 or index > #self.events_ then
        return -1;
    end
    return self.events_[index].eventFile_.beginTime_;
end


function prototype:getResources()
    return self.resList_;
end


function prototype:isNeedAdditionalCamera()
    for i = 1, #self.events_ - 1 do
        if self.events_[i].eventObj_ : isProject() == false then
            if self.events_[i].eventFile_.beginTime_ + self.events_[i].eventObj_.eventData_.timeLength_ > self.events_[i + 1].eventFile_.beginTime_ then
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
    return true;
end


function prototype:_loadFromBuff()
    return true;
end


function prototype:_insertEvent(eventFile, eventObj)
    local event = {};
    event.eventFile_ = eventFile;
    event.eventObj_ = eventObj;
    if #self.events_ == 0 then
        self.events_[1] = event;
        return;
    end
    local isSorted = false;
    for m = 1, #self.events_ do
        local i = #self.events_ - m + 1;
        if self.events_[i].eventFile_.beginTime_ < eventFile.beginTime_ then
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

function prototype:getNameId(name, nameTable)
    if nameTable[name] == nil then
        nameTable[name] = 1;
        return 1;
    else
        local idx = nameTable[name];
        idx = idx + 1;
        nameTable[name] = idx;
        return idx;
    end
end

function prototype.createObject(param)
    return nil;
end


--动态添加event
function prototype:addEvent(beginTime, eventDataObject)
    local eventFile = {};
    eventFile.beginTime_ = beginTime;
    self:_insertEvent(eventFile, eventDataObject);
end


return prototype;