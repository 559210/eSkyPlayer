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
    self.isDirtyEvent_ = false;
    self.trackCallbacks_ = {
        [definations.EVENT_PLAYER_STATE.EVENT_START] = {},
        [definations.EVENT_PLAYER_STATE.EVENT_UPDATE] = {},
        [definations.EVENT_PLAYER_STATE.EVENT_END] = {},
    };
end



function prototype:initialize()
    return true;
end

function prototype:addTrackCallback(eventState, callbackIndex, callback)
    self.trackCallbacks_[eventState][callbackIndex] = callback;
end

function prototype:getTrackCallback(callbackState)
    return self.trackCallbacks_[callbackState];
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
        
        local project = self.events_[#self.events_]:getProjectData();
        trackLength = project:getTimeLength();
    else
        local lastBeginTime = self.events_[#self.events_]:getBeginTime();
        local lastTimeLength = self.events_[#self.events_]:getTimeLength();
        trackLength = lastBeginTime + lastTimeLength;
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
    return self.events_[index];
end


function prototype:getEventBeginTimeAt(index)
    if index < 1 or index > #self.events_ then
        return -1;
    end
    return self.events_[index]:getBeginTime();
end


function prototype:getResources()
    return self.resList_;
end


function prototype:isNeedAdditionalCamera()
    for i = 1, #self.events_ - 1 do
        if self.events_[i]: isProject() == false then
            local preEndTime = self.events_[i]:getBeginTime() + self.events_[i]:getTimeLength();
            local postBeginTime = self.events_[i + 1]:getBeginTime();
            if preEndTime > postBeginTime then
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
    logError("tarackdata bast _loadFromBuff");
    return true;
end


function prototype:_insertEvent(beginTime, eventObj)
    eventObj:setBeginTime(beginTime);
    if #self.events_ == 0 then
        self.events_[1] = eventObj;
        return;
    end
    local isSorted = false;
    for m = 1, #self.events_ do
        local i = #self.events_ - m + 1;
        if self.events_[i]:getBeginTime() < beginTime then
            for j = i, #self.events_ do
                local index = #self.events_ - j + i;
                self.events_[index + 2] = self.events_[index + 1];
            end
            self.events_[i + 1] = eventObj;
            isSorted = true;
            break;
        end
    end
    if isSorted == false then
        for i = 1, #self.events_ do
            local index = #self.events_ - i + 1;
            self.events_[index + 1] = self.events_[index];
        end
        self.events_[1] = eventObj;
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

function prototype:getTrackName(parentName, trackType, title, nameTable)
    local eName = "";
    local tName = trackType .."_" ..title;
    local idx = self:getNameId(tName, nameTable);
    if parentName ~= "" then
        eName = parentName .."/" ..tName .."_" ..idx;
    else
        eName = parentName ..tName .."_" ..idx;
    end
    return eName;
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

--必要参数:begintime,eventData,addType
--可选参数:replaceNum.目前适用于只有在插入event需要替换剩余event的时候,需要指定replaceNum数量
function prototype:addEvent(beginTime, eventData, addType, replaceNum)
    local isAdd = false;
    switch(addType,
        case(definations.EVENT_ADDTYPE.NORMAL, function()
            self:_insertEvent(beginTime, eventData);
            self.isDirtyEvent_ = true;
            isAdd = true;
        end),
        case(definations.EVENT_ADDTYPE.EVENT_BREAK_ADD, function()
            isAdd = self:_addEventByEventBreakAdd(beginTime, eventData);
            self.isDirtyEvent_ = isAdd;
        end),
        case(definations.EVENT_ADDTYPE.EVENT_LAST_ADD, function()
            isAdd = self:_addEventByEventLastAdd(beginTime, eventData);
            self.isDirtyEvent_ = isAdd;
        end),
        case(definations.EVENT_ADDTYPE.EVENT_REPLACE_MORE_ADD, function()
            if replaceNum ~= nil  and replaceNum > 0 then
                isAdd = self:_replaceEventAdd(beginTime, eventData, replaceNum);
                self.isDirtyEvent_ = isAdd;
            end
        end),
        case(definations.EVENT_ADDTYPE.EVENT_REPLACE_ONE_ADD, function()
            isAdd = self:_replaceEventAdd(beginTime, eventData, 1);
            self.isDirtyEvent_ = isAdd;
        end)

        );
    return isAdd;
end

function prototype:_addEventByEventBreakAdd(beginTime, eventData)
    if #self.events_ > 0 then
        local eventsIndex = self:_getEventsByTime(beginTime);
        if eventsIndex == nil then
            self:_insertEvent(beginTime, eventData);
            return true;
        end
        if #eventsIndex.findEventsIndex > 0 then
            for i = 1, #eventsIndex.findEventsIndex do
                local fevent = self.events_[eventsIndex.findEventsIndex[i]];
                if eventsIndex.findEventsIndex[i + 1] == nil then
                    fevent:clipEvent(beginTime - fevent:getBeginTime());
                    self:_insertEvent(beginTime, eventData);
                    return true;
                end
            end
        else
            if eventsIndex.prevEventIndex > 0 then
                if self:_getNextEventByIndex(eventsIndex.prevEventIndex) == nil then
                    self:_insertEvent(beginTime, eventData);
                    return true;
                end
            end
        end
    else
        self:_insertEvent(beginTime, eventData);
        return true;
    end

    return false;

end

function prototype:_addEventByEventLastAdd(beginTime, eventData)

    local findEvents = self:_getEventsByTime(beginTime);
    if findEvents == nil then
        return false;
    end
    local lastEventIndex = findEvents.findEventsIndex[#findEvents.findEventsIndex];
    if self:_getNextEventByIndex(lastEventIndex + 1) == nil then
        local eEvent = self.events_[lastEventIndex];
        local eEventEndTime = eEvent:getBeginTime() + eEvent:getTimeLength();
        beginTime = eEventEndTime;
        self:_insertEvent(beginTime, eventData);
        return true;
    end
    return false;

end


function prototype:_replaceEventAdd(beginTime, eventData, replaceNum)
    local findEvents = self:_getEventsByTime(beginTime);
    if findEvents ~= nil and #findEvents.findEventsIndex > 0 then
        local firstEventIndex = findEvents.findEventsIndex[1];
        local lastEventIndex = -1;
        if replaceNum >= 2 then
            for i = 2, replaceNum do
                lastEventIndex = firstEventIndex + i - 1;
                if lastEventIndex > #self.events_ then
                    return false;
                end
            end
        else
            lastEventIndex = firstEventIndex;
        end
        local lastEvent = self.events_[lastEventIndex];
        local lastEventEndTime = lastEvent:getBeginTime() + lastEvent:getTimeLength();
        beginTime = self.events_[firstEventIndex]:getBeginTime();
        eventData.eventData_.timeLength_ = lastEventEndTime - beginTime;

        for i = 1, replaceNum do
            table.remove(self.events_, firstEventIndex);
        end
        self:_insertEvent(beginTime, eventData);
        return true;
    end

    return false;

end


function prototype:_getEventsByTime(time)
    local findEventsIndex = {};--符合条件的evnet放在容器中
    local prevEventIndex = -1;
    for i = 1, #self.events_ do
        local currentEvent = self.events_[i];
        local beginTime = currentEvent:getBeginTime();
        local endTime = beginTime + currentEvent:getTimeLength();
        if time > beginTime and time <= endTime then
            findEventsIndex[#findEventsIndex + 1] = i;
        else
            if time <= beginTime then
                prevEventIndex = i - 1;
                break;
            end
        end
    end

    if #findEventsIndex > 0 then --找到event返回找到
        return {findEventsIndex = findEventsIndex, prevEventIndex = -1};
    elseif prevEventIndex > 0 then --未找到返回上一个
        return {findEventsIndex = {}, prevEventIndex = prevEventIndex};
    else --没找到 上一个也没有返回默认 nil
        return nil;
    end
end


function prototype:_getNextEventByIndex(index)
    return self.events_[index + 1];
end

return prototype;