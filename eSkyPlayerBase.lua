local prototype = class("eSkyPlayerBase");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor(director)
    self.director_ = director;
    self.trackObj_  = nil;
    self.isNeedAdditionalCamera_ = false;
    self.eventCount_ = 0;
    self.trackLength_ = 0;
    self.index_ = 1;
    self.playState_ = definations.PLAY_STATE.NORMAL;
    self.resourceManagerTacticType_ = definations.MANAGER_TACTIC_TYPE.NO_NEED;
    self.resList_ = {};  --数组：存放开始时需要特定加载的资源，不通过策略类加载，path/count; 
    self.resTable_ = {};  --键值对，用于存放player管理的资源中需要遇到特定类型event时加载的资源；key为event类型eventType_，value为资源路径path_(数组)；
    self.playingEvents_ = {};  --数组，存放正在播放的event，eventObj对象和开始时间；
    self.resourceTactics_ = {};  --键值对，键为tactictype，值为对应的策略类对象；
    self.eventLoaded_ = {};    --数组，存放已经通过异步加载判断条件过的event，作为标志防止多次异步加载，release过之后对应event删除；
end


function prototype:initialize(trackObj)
    self.trackObj_ = trackObj; 
    self.trackLength_ = self.trackObj_:getTrackLength();
    self.eventCount_ = self.trackObj_:getEventCount();
    self.index_ = 1;
    return true;
end


function prototype:uninitialize()
    return true;
end


function prototype:onResourceLoaded()
end


function prototype:isNeedAdditionalCamera()
    return false;
end


function prototype:getResources()
    local resList = self.trackObj_:getResources();
    for i = 1, #resList do
        self.resList_[#self.resList_ + 1] = resList[i];
    end
    return self.resList_;
end


function prototype:setAdditionalCamera(camera)
    logError("你需要在子类中实现set函数");
end


function prototype:stop()
    self.playState_ = definations.PLAY_STATE.PLAYEND;
    return true;
end


function prototype:play()
    self.playState_ = definations.PLAY_STATE.PLAY;
    return true;
end


function prototype:changePlayState(state)
    self.playState_ = state
end


function prototype:getPlayState()
    return self.playState_;
end


function prototype:seek(time)

    local eventNeedAdd = {}; --数组，存放需要增加的eventObj,开始时间，结束时间；
    local eventNeedDelete = {}; --键为self.playingEvents_里的index，值为eventObj；
    for i = 1, self.eventCount_  do
        local beginTime = self.trackObj_:getEventBeginTimeAt(i);
        local eventObj = self.trackObj_:getEventAt(i);
        local endTime = beginTime + eventObj.eventData_.timeLength_;

        if self.director_.timeLine_ >= beginTime and self.director_.timeLine_ <= endTime then
            local isEventEntered = true;
            for j = 1, #self.playingEvents_ do
                if eventObj == self.playingEvents_[j].obj_ then 
                    isEventEntered = false;
                end
            end
            if isEventEntered == true then
                self.index_ = i;
                local event = {};
                event.obj = eventObj;
                event.beginTime = beginTime;
                event.endTime = endTime;
                eventNeedAdd[#eventNeedAdd + 1] = event;
            end
        end

        if self.director_.timeLine_ <= beginTime or self.director_.timeLine_ >= endTime then
            for j = 1, #self.playingEvents_ do
                if eventObj == self.playingEvents_[j].obj_ then
                    eventNeedDelete[j] = eventObj;
                    break;
                end
            end

            if i < self.eventCount_ then
                local nextEventBeginTime = self.trackObj_:getEventBeginTimeAt(i + 1);
                if self.director_.timeLine_ >= endTime and self.director_.timeLine_ <= nextEventBeginTime then
                    self.index_ = i + 1;
                end
            end
            if i == self.eventCount_ and self.director_.timeLine_ >= endTime then
                self.index_ = i + 1;
            end
            if i == 1 and self.director_.timeLine_ <= beginTime then
                self.index_ = i;
            end
        end
    end

    
    for i = 1, #self.playingEvents_ do  --保证倒序删除；
        local index = #self.playingEvents_ + 1 - i;
        if eventNeedDelete[index] ~= nil then
            self:onEventLeft(eventNeedDelete[index]);
            self:_deletePlayingEvent(index);
        end
        
    end

    for i = 1, #eventNeedAdd do
        self:_addPlayingEvent(eventNeedAdd[i].obj, eventNeedAdd[i].beginTime, eventNeedAdd[i].endTime);
        self:onEventEntered(eventNeedAdd[i].obj, eventNeedAdd[i].beginTime);
    end
    return true;
end


function prototype:getTrackType()
    if self.trackObj_ == nil then
        return definations.TRACK_FILE_TYPE.UNKOWN;
    end

    return self.trackObj_:getTrackType();
end


function prototype:loadResourceInitiallySync()
    local playerTacticType = self.resourceManagerTacticType_;
    if playerTacticType ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then  --如果有player管理的资源需要加载
        local resTactic  = self:_getResourceTactic(playerTacticType);
        local resList = self:_getResList(self.resTable_);
        if resTactic == nil then  --playerTacticType策略不存在
            return false;
        end
        if resTactic:loadResourceInitiallySync(resList) == false then
            return false;
        end
    end

    local trackTacticType = self.trackObj_.resourceManagerTacticType_;
    if trackTacticType ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then  --如果trcak上有资源需要加载
        local resTactic  = self:_getResourceTactic(trackTacticType);
        local resList = self:_getResList(self.trackObj_.resTable_);
        if resTactic == nil then  --playerTacticType策略不存在
            return false;
        end
        if resTactic:loadResourceInitiallySync(resList) == false then
            return false;
        end
    end

    for i = 1, self.eventCount_  do
        local eventObj = self.trackObj_:getEventAt(i);
        local eventTacticType = eventObj.resourceManagerTacticType_;
        if eventTacticType ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
            if #eventObj.resourcesNeeded_ ~= 0 then
                local resTactic  = self:_getResourceTactic(eventTacticType);
                if resTactic == nil then
                    return false;
                end
                if resTactic:loadResourceInitiallySync(eventObj.resourcesNeeded_) == false then
                    return false;
                end
            end
        end
    end
    return true;
end


function prototype:loadResourceInitially(callback)
    async.series({
        function(done)
            local playerTacticType = self.resourceManagerTacticType_;
            if playerTacticType ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
                local resTactic  = self:_getResourceTactic(playerTacticType);
                local resList = self:_getResList(self.resTable_);
                if resTactic ~= nil then
                    resTactic:loadResourceInitially(resList,function (isPrepared)
                        if isPrepared == false then
                            done("playerTacticType error");
                        else
                            done();
                        end
                    end);
                else
                    done("tactic error");
                end
            else
                done();
            end
        end,
        function(done)
            local trackTacticType = self.trackObj_.resourceManagerTacticType_;
            if trackTacticType ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
                local resTactic  = self:_getResourceTactic(trackTacticType);
                local resList = self:_getResList(self.trackObj_.resTable_);
                if resTactic ~= nil then
                    resTactic:loadResourceInitially(resList,function (isPrepared)
                        if isPrepared == false then
                            done("trackTacticType error");
                        else
                            done();
                        end
                    end);
                else
                    done("tactic error");
                end
            else
                done();
            end
        end,
        function(done)
            local eventTable = {};
            for i = 1, self.eventCount_  do
                local event = {};
                local eventObj = self.trackObj_:getEventAt(i);
                local eventTacticType = eventObj.resourceManagerTacticType_;
                if eventTacticType ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
                    if #eventObj.resourcesNeeded_ ~= 0 then
                        local event = {};
                        event.resList = eventObj.resourcesNeeded_;
                        event.resTactic = self:_getResourceTactic(eventTacticType);
                        eventTable[#eventTable + 1] = event;
                    end
                end
            end

            async.mapSeries(eventTable, 
                function(event, done1)
                    if event.resTactic ~= nil then
                        event.resTactic:loadResourceInitially(event.resList,function (isPrepared)
                            if isPrepared == false then
                                done1("eventTacticType error");
                                return;
                            end
                            done1();
                        end);
                    else
                        done1("tactic error");
                    end
                end, function(err)
                        done(err)
                    end);
        end,
        }, function(err)
            if err ~= nil then
                callback(false);
            else
                callback(true);
            end
        end);
end


function prototype:releaseResource()
      --如果有player管理的资源需要释放
    local tactic = self.resourceTactics_[self.resourceManagerTacticType_];
    if tactic ~= nil then
        for key, value in pairs(self.resTable_) do
            for i = 1, #value do
                tactic:releaseResourceLastly(value[i]);
            end
        end
    end

      --如果trcak上有资源需要释放
    tactic = self.resourceTactics_[self.trackObj_.resourceManagerTacticType_];
    if tactic ~= nil then
        for key, value in pairs(self.trackObj_.resTable_) do
            for i = 1, #value do
                tactic:releaseResourceLastly(value[i]);
            end
        end
    end

    for i = 1, self.eventCount_  do
        local eventObj = self.trackObj_:getEventAt(i);
        tactic = self.resourceTactics_[eventObj.resourceManagerTacticType_];
        if tactic ~= nil then
            for j = 1, #eventObj.resourcesNeeded_ do 
                local path = eventObj.resourcesNeeded_[j].path;
                tactic:releaseResourceLastly(path);
            end
        end
    end
end


function prototype:onEventEntered(eventObj, beginTime)
    
end


function prototype:onEventLeft(eventObj)

end


function prototype:preparePlayingEvents(callback)
    local beginTime = self.trackObj_:getEventBeginTimeAt(self.index_);
    local event = self.trackObj_:getEventAt(self.index_);
    local endTime = -1;
    if event == nil then
        endTime = -1;
    else
        if event.eventType_ ~= definations.EVENT_TYPE.SCENE_PLAN and --scenePlan,cameraPlan,ROLE_PLAN不调用event:getTimeLength()
            event.eventType_ ~= definations.EVENT_TYPE.CAMERA_PLAN and
            event.eventType_ ~= definations.EVENT_TYPE.ROLE_PLAN then
            endTime = beginTime + event:getTimeLength();
        end
    end

    for i = 1, #self.playingEvents_ do
        local playingEvent = self.playingEvents_[i].obj_;
        local playingBeginTime = self.playingEvents_[i].beginTime_;
        local playingEndTime = playingBeginTime + playingEvent:getTimeLength();
        if self.director_.timeLine_ >= playingEndTime or self.director_.timeLine_ <= playingBeginTime then
            self:onEventLeft(playingEvent);
            self:_deletePlayingEvent(i);
            break;
        end
    end

    if self.director_.timeLine_ > beginTime and self.director_.timeLine_ < endTime then
        local isEventEntered = true;
        for i = 1, #self.playingEvents_ do
            if event == self.playingEvents_[i].obj_ then 
                isEventEntered = false;
            end
        end
        if isEventEntered == true then
            self:_addPlayingEvent(event,beginTime,endTime);  --必须先调_addPlayingEvent函数，再调onEventEntered函数；seek函数中也是。
            self:onEventEntered(event, beginTime);
        end
    end

    if self.director_.isSeek_ == false then
        for i = 1, #self.eventLoaded_ do
            if self.eventLoaded_[i] == event then
                callback(true);
                return;
            end
        end
        if beginTime - self.director_.timeLine_ <= 2 and beginTime - self.director_.timeLine_ > 0 then
            local eventType = event:getEventType();
            self.eventLoaded_[#self.eventLoaded_ + 1] = event;
            async.series({
                function(done)
                    if self.resourceManagerTacticType_ ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
                        local resTactic  = self:_getResourceTactic(self.resourceManagerTacticType_);
                        local resList = self:_getNeededResList(self.resTable_, eventType);
                        if resTactic ~= nil then
                            resTactic:loadResourceOnTheFly(resList,function (isPrepared)
                                if isPrepared == false then
                                    done("playerTacticType error");
                                else
                                    done();
                                end
                            end);
                        else
                            done("tactic error");
                        end
                    else
                        done();
                    end
                end,
                function(done)
                    if self.trackObj_.resourceManagerTacticType_ ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
                        local resTactic  = self:_getResourceTactic(trackTacticType);
                        local resList = self:_getNeededResList(self.trackObj_.resTable_, eventType);
                        if resTactic ~= nil then
                            resTactic:loadResourceOnTheFly(resList,function (isPrepared)
                                if isPrepared == false then
                                    done("trackTacticType error");
                                else
                                    done();
                                end
                            end);
                        else
                            done("tactic error");
                        end
                    else
                        done();
                    end
                end,
                function(done)
                    if event.resourceManagerTacticType_ ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
                        local resTactic  = self:_getResourceTactic(event.resourceManagerTacticType_);
                        if resTactic ~= nil then
                            resTactic:loadResourceOnTheFly(event.resourcesNeeded_,function (isPrepared)
                                if isPrepared == false then
                                    done("trackTacticType error");
                                else
                                    done();
                                end
                            end);
                        else
                            done("tactic error");
                        end
                    else
                        done();
                    end
                end}, function(err)
                    if err ~= nil then
                        callback(false);
                    else
                        callback(true);
                    end
                end);
        end
    end
end


function prototype:_addPlayingEvent(eventObj, beginTime, endTime)
    local event = {};
    event.obj_ = eventObj;
    event.beginTime_ = beginTime;
    event.endTime_ = endTime;
    self.playingEvents_[#self.playingEvents_ + 1] = event;
    self.index_ = self.index_ + 1;

    if self.resourceManagerTacticType_ ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
        local resTactic  = self:_getResourceTactic(self.resourceManagerTacticType_);
        local resList = self:_getNeededResList(self.resTable_, eventType);
        if resTactic == nil then
            return;
        end
        resTactic:loadResourceOnTheFlySync(resList);
    end

    if self.trackObj_.resourceManagerTacticType_ ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
        local resTactic  = self:_getResourceTactic(self.trackObj_.resourceManagerTacticType_);
        local resList = self:_getNeededResList(self.trackObj_.resTable_, eventType);
        if resTactic == nil then
            return;
        end
        resTactic:loadResourceOnTheFlySync(resList);
    end

    if eventObj.resourceManagerTacticType_ ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
        local resTactic  = self:_getResourceTactic(eventObj.resourceManagerTacticType_);
        if resTactic == nil then
            return;
        end
        resTactic:loadResourceOnTheFlySync(eventObj.resourcesNeeded_);
    end
end


function prototype:_deletePlayingEvent(index)
    local eventObj = self.playingEvents_[index].obj_;
    local eventType = eventObj:getEventType();
    local tactic = self.resourceTactics_[self.resourceManagerTacticType_]
    if tactic ~= nil then 
        local paths = self.resTable_[eventType];
        if paths ~= nil then
            for i = 1, #paths do
                tactic:releaseResourceOnTheFly(paths[i]);
            end
        end
    end

    tactic = self.resourceTactics_[self.trackObj_.resourceManagerTacticType_]
    if tactic ~= nil then 
        local paths = self.resTable_[eventType];
        if paths ~= nil then
            for i = 1, #paths do
                tactic:releaseResourceOnTheFly(paths[i]);
            end
        end
    end

    tactic = self.resourceTactics_[eventObj.resourceManagerTacticType_]
    if tactic ~= nil then 
        for i = 1,#eventObj.resourcesNeeded_ do 
            local path = eventObj.resourcesNeeded_[i].path;
            tactic:releaseResourceOnTheFly(path);
        end
    end

    for i = 1, #self.eventLoaded_ do
        if self.eventLoaded_[i] == eventObj then
            table.remove(self.eventLoaded_,i)
        end
    end 
    table.remove(self.playingEvents_,index);
end

function prototype:_creatTactic(tacticType)
    if tacticType == definations.MANAGER_TACTIC_TYPE.LOAD_INITIALLY_RELEASE_LASTLY then
        self.resourceTactics_[tacticType] = newClass("eSkyPlayer/eSkyPlayerResourceLoadInitiallyReleaseLastly");
    elseif tacticType == definations.MANAGER_TACTIC_TYPE.LOAD_INITIALLY_SYNC_RELEASE_LASTLY then
        self.resourceTactics_[tacticType] = newClass("eSkyPlayer/eSkyPlayerResourceLoadInitiallySyncReleaseLastly");
    elseif tacticType == definations.MANAGER_TACTIC_TYPE.LOAD_ON_THE_FLY_RELEASE_IMMEDIATELY then
        self.resourceTactics_[tacticType] = newClass("eSkyPlayer/eSkyPlayerResourceLoadOnTheFlyReleaseOnTheFly");
    elseif tacticType == definations.MANAGER_TACTIC_TYPE.LOAD_ON_THE_FLY_SYNC_RELEASE_IMMEDIATELY then
        self.resourceTactics_[tacticType] = newClass("eSkyPlayer/eSkyPlayerResourceLoadOnTheFlySyncReleaseOnTheFly");
    end
end


function prototype:_getResourceTactic(tacticType)
    if self.resourceTactics_[tactic] ~= nil then
        return self.resourceTactics_[tactic];
    end
    self:_creatTactic(tacticType);
    return self.resourceTactics_[tacticType];
end


function prototype:_getResList(tab)
    if tab == nil then
        return nil;
    end
    local resList = {};
    for k, v in pairs(tab) do
        for i = 1, #v do
            local res = {};
            res.path = v[i];
            res.count = 1;
            resList[#resList + 1] = res;
        end
    end
    return resList;
end


function prototype:_getNeededResList(tab, eventType)
    if tab == nil then
        return nil;
    end
    local resList = {};
    local paths = tab[eventType]
    if paths ~= nil then
        for i = 1, #paths do
            local res = {};
            res.path = paths[i];
            res.count = 1;
            resList[#resList + 1] = res;
        end
    end
    return resList;
end

function prototype:_update()
    self.playState_ = definations.PLAY_STATE.PLAYING;
    self:preparePlayingEvents(function(done)
        
    end);
    return;
end


return prototype;
