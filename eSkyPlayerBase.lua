local prototype = class("eSkyPlayerBase");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor(director)
    self.director_ = director;
    self.trackObj_  = nil;
    self.isNeedAdditionalCamera_ = false;
    self.trackLength_ = 0;
    self.index_ = 1;
    self.playState_ = definations.PLAY_STATE.NORMAL;
    self.resourceManagerTacticType_ = definations.MANAGER_TACTIC_TYPE.NO_NEED;
    self.resList_ = {};  --数组：存放开始时需要特定加载的资源，不通过策略类加载，path/count; 
    self.resTable_ = {};  --键值对，用于存放player管理的资源中需要遇到特定类型event时加载的资源；key为event类型eventType_，value为资源路径path_(数组)；
    self.playingEvents_ = {};  --数组，存放正在播放的event，eventObj对象和开始时间；
    self.resourceTactics_ = {};  --键值对，键为tactictype，值为对应的策略类对象；
    self.eventLoadedStatus_ = {};    --键值对，存放event通过异步加载的加载状态（忽略event的策略类型，策略为同步加载的event也会进入此键值对）
                                     --键为event,值为加载状态："waiting","finished","filed"
end


function prototype:initialize(trackObj)
    self.trackObj_ = trackObj; 
    self.trackLength_ = self.trackObj_:getTrackLength();
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


function prototype:getResources()   --获取需要在开始时由director加载的资源列表;(一般由director调用)
    local resList = self.trackObj_:getResources();
    for i = 1, #resList do
        self.resList_[#self.resList_ + 1] = resList[i];
    end
    return self.resList_;
end


function prototype:getResource(eventObj, path)  --根据参数获取对应路径的资源;(一般由自身或子类调用)
    local tactic = self.resourceTactics_[eventObj.resourceManagerTacticType_];
    if tactic == nil then
        logError("tactic error");
    end
    local asset = tactic:getResource(path);
    return asset;
end


function prototype:getTrack()
    return self.trackObj_;
end


function prototype:setRoleAgent()
    return;
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
    local eventCount = self.trackObj_:getEventCount();
    for i = 1, eventCount  do
        local eventObj = self.trackObj_:getEventAt(i);
        local initialBeginTime = eventObj:getDataBeginTime();               --event剪裁之前的原始开始时间
        local realBeginTime = eventObj:getCurrentBeginTime();                      --event(支持剪裁)的实际播放开始时间

        local realEndTime = realBeginTime + eventObj:getEventCurrentLength();

        if time >= realBeginTime and time <= realEndTime then
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
                event.beginTime = initialBeginTime;
                -- event.endTime = endTime;
                eventNeedAdd[#eventNeedAdd + 1] = event;  --seek统一为同步加载，所以不需要考虑异步加载状态，不需要对self.eventLoadedStatus_判断；
            end
        end

        if time <= realBeginTime or time >= realEndTime then
            for j = 1, #self.playingEvents_ do
                if eventObj == self.playingEvents_[j].obj_ then
                    eventNeedDelete[j] = eventObj;
                    break;
                end
            end

            if i < eventCount then
                local nextEvent = self.trackObj_:getEventAt(i + 1);
                local nextEventBeginTime = nextEvent:getCurrentBeginTime();
                if time >= realEndTime and time <= nextEventBeginTime then
                    self.index_ = i + 1;
                end
            end
            if i == eventCount and time >= realEndTime then
                self.index_ = i + 1;
            end
            if i == 1 and time <= realBeginTime then
                self.index_ = i;
            end
        end
    end

    
    for i = 1, #self.playingEvents_ do  --保证倒序删除；
        local index = #self.playingEvents_ + 1 - i;
        if eventNeedDelete[index] ~= nil then
            self:onEventLeft(eventNeedDelete[index]);
            self:_callEventCallbackByEventState(eventNeedDelete[index], definations.EVENT_PLAYER_STATE.EVENT_END);
            self:_deletePlayingEvent(index);
        end
        
    end

    for i = 1, #eventNeedAdd do
        self:_addPlayingEvent(eventNeedAdd[i].obj, eventNeedAdd[i].beginTime);
        self:onEventEntered(eventNeedAdd[i].obj);
        self:_callEventCallbackByEventState(eventNeedAdd[i].obj, definations.EVENT_PLAYER_STATE.EVENT_START);
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
    if playerTacticType ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then  --player管理的资源
        local resTactic  = self:_getResourceTactic(playerTacticType);
        local resList = self:_getResList(self.resTable_);
        if resTactic:loadResourceInitiallySync(resList) == false then
            return false;
        end
    end

    local trackTacticType = self.trackObj_.resourceManagerTacticType_;
    if trackTacticType ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then  --trcak管理的资源
        local resTactic  = self:_getResourceTactic(trackTacticType);
        local resList = self:_getResList(self.trackObj_.resTable_);
        if resTactic:loadResourceInitiallySync(resList) == false then
            return false;
        end
    end

    local eventCount = self.trackObj_:getEventCount();
    for i = 1, eventCount  do
        local eventObj = self.trackObj_:getEventAt(i);
        local eventTacticType = eventObj.resourceManagerTacticType_;
        if eventTacticType ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
            if #eventObj.eventData_.resourcesNeeded_ ~= 0 then
                local resTactic  = self:_getResourceTactic(eventTacticType);
                if resTactic:loadResourceInitiallySync(eventObj.eventData_.resourcesNeeded_) == false then
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
                resTactic:loadResourceInitially(resList,function (isPrepared)
                    if isPrepared == false then
                        done("playerTacticType error");
                    else
                        done();
                    end
                end);
            else
                done();
            end
        end,
        function(done)
            local trackTacticType = self.trackObj_.resourceManagerTacticType_;
            if trackTacticType ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
                local resTactic  = self:_getResourceTactic(trackTacticType);
                local resList = self:_getResList(self.trackObj_.resTable_);
                resTactic:loadResourceInitially(resList,function (isPrepared)
                    if isPrepared == false then
                        done("trackTacticType error");
                    else
                        done();
                    end
                end);
            else
                done();
            end
        end,
        function(done)
            local eventTable = {};
            local eventCount = self.trackObj_:getEventCount();
            for i = 1, eventCount  do
                local event = {};
                local eventObj = self.trackObj_:getEventAt(i);
                local eventTacticType = eventObj.resourceManagerTacticType_;
                if eventTacticType ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
                    if #eventObj.eventData_.resourcesNeeded_ ~= 0 then
                        local event = {};
                        event.resList = eventObj.eventData_.resourcesNeeded_;
                        event.resTactic = self:_getResourceTactic(eventTacticType);
                        eventTable[#eventTable + 1] = event;
                    end
                end
            end

            async.mapSeries(eventTable, 
                function(event, done1)
                        event.resTactic:loadResourceInitially(event.resList,function (isPrepared)
                            if isPrepared == false then
                                done1("eventTacticType error");
                                return;
                            end
                            done1();
                        end);
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

    local eventCount = self.trackObj_:getEventCount();
    for i = 1, eventCount  do
        local eventObj = self.trackObj_:getEventAt(i);
        tactic = self.resourceTactics_[eventObj.resourceManagerTacticType_];
        if tactic ~= nil then
            for j = 1, #eventObj.eventData_.resourcesNeeded_ do 
                local path = eventObj.eventData_.resourcesNeeded_[j].path;
                tactic:releaseResourceLastly(path);
            end
        end
    end
end


function prototype:onEventEntered(eventObj)
    
end


function prototype:onEventLeft(eventObj)

end


function prototype:preparePlayingEvents()
    local event = self.trackObj_:getEventAt(self.index_);
    local initialBeginTime = -1;
    local realBeginTime = -1;
    local realEndTime = -1;
    if event ~= nil then
        if event.eventType_ ~= definations.EVENT_TYPE.SCENE_PLAN and --scenePlan,cameraPlan,ROLE_PLAN不调用event:getEventCurrentLength()
            event.eventType_ ~= definations.EVENT_TYPE.CAMERA_PLAN and
            event.eventType_ ~= definations.EVENT_TYPE.MUSIC_PLAN and
            event.eventType_ ~= definations.EVENT_TYPE.ROLE_PLAN then
                initialBeginTime = event:getDataBeginTime();               --event剪裁之前的原始开始时间
                realBeginTime = event:getCurrentBeginTime();                      --event(支持剪裁)的实际播放开始时间
                realEndTime = realBeginTime + event:getEventCurrentLength();
        end
    end
    for i = 1, #self.playingEvents_ do
        local playingEvent = self.playingEvents_[i].obj_;
        local playingBeginTime = playingEvent:getCurrentBeginTime();
        local playingEndTime = playingBeginTime + playingEvent:getEventCurrentLength();
        if self.director_.timeLine_ >= playingEndTime or self.director_.timeLine_ <= playingBeginTime then --event 离开
            self:onEventLeft(playingEvent);
            self:_callEventCallbackByEventState(playingEvent, definations.EVENT_PLAYER_STATE.EVENT_END);
            self:_deletePlayingEvent(i);
            break;
        end
        --event 执行中
        self:_callEventCallbackByEventState(playingEvent, definations.EVENT_PLAYER_STATE.EVENT_UPDATE);
    end

    if self.director_.timeLine_ > realBeginTime and self.director_.timeLine_ < realEndTime then
        local isEventEntered = true;
        for i = 1, #self.playingEvents_ do
            if event == self.playingEvents_[i].obj_ then 
                isEventEntered = false;
            end
        end
        if isEventEntered == true then
            if self.eventLoadedStatus_[event] == "failed" then
                assert(false, "error: load resource on the fly failed!");
            elseif self.eventLoadedStatus_[event] == "finished" or self.eventLoadedStatus_[event] == nil then
                self:_addPlayingEvent(event, initialBeginTime);  --必须先调_addPlayingEvent函数，再调onEventEntered函数；seek函数中也是。
                self:onEventEntered(event);
                self:_callEventCallbackByEventState(event, definations.EVENT_PLAYER_STATE.EVENT_START);
            end
        end
    end

    if self.director_.isSeek_ == true then
        return;
    end
    if self.eventLoadedStatus_[event] ~= nil then
        return;
    end
    if realBeginTime - self.director_.timeLine_ <= 2 and realBeginTime - self.director_.timeLine_ > 0 then
        local eventType = event:getEventType();
        self.eventLoadedStatus_[event] = "waiting";
        async.series({
            function(done)
                if self.resourceManagerTacticType_ ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
                    local resTactic  = self:_getResourceTactic(self.resourceManagerTacticType_);
                    local resList = self:_getNeededResList(self.resTable_, eventType);
                    resTactic:loadResourceOnTheFly(resList,function (isPrepared)
                        if isPrepared == false then
                            done("playerTacticType error");
                        else
                            done();
                        end
                    end);
                else
                    done();
                end
            end,
            function(done)
                if self.trackObj_.resourceManagerTacticType_ ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
                    local resTactic  = self:_getResourceTactic(self.trackObj_.resourceManagerTacticType_);
                    local resList = self:_getNeededResList(self.trackObj_.resTable_, eventType);
                    resTactic:loadResourceOnTheFly(resList,function (isPrepared)
                        if isPrepared == false then
                            done("trackTacticType error");
                        else
                            done();
                        end
                    end);
                else
                    done();
                end
            end,
            function(done)
                if event.resourceManagerTacticType_ ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
                    local resTactic  = self:_getResourceTactic(event.resourceManagerTacticType_);
                    resTactic:loadResourceOnTheFly(event.eventData_.resourcesNeeded_,function (isPrepared)
                        if isPrepared == false then
                            done("trackTacticType error");
                        else
                            done();
                        end
                    end);
                else
                    done();
                end
            end}, function(err)
                if err ~= nil then
                    self.eventLoadedStatus_[event] = "failed";
                else
                    self.eventLoadedStatus_[event] = "finished";
                end
            end);
    end
end


function prototype:_callEventCallbackByEventState(event, callbackState)
    local eventCallbacks = event:getEventCallback(callbackState);
    if eventCallbacks ~= nil then
        for _, v in pairs(eventCallbacks) do
            v(self.trackObj_, event);
        end
    end
    local trackCallbacks = self.trackObj_:getTrackCallback(callbackState);
    if trackCallbacks ~= nil then
        for _, v in pairs(trackCallbacks) do
            v(self.trackObj_, event);
        end
    end
    
end

function prototype:_addPlayingEvent(eventObj, beginTime)
    local event = {};
    event.obj_ = eventObj;
    event.beginTime_ = beginTime;
    self.playingEvents_[#self.playingEvents_ + 1] = event;
    self.index_ = self.index_ + 1;

    if self.resourceManagerTacticType_ ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
        local resTactic  = self:_getResourceTactic(self.resourceManagerTacticType_);
        local resList = self:_getNeededResList(self.resTable_, eventType);
        resTactic:loadResourceOnTheFlySync(resList);
    end

    if self.trackObj_.resourceManagerTacticType_ ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
        local resTactic  = self:_getResourceTactic(self.trackObj_.resourceManagerTacticType_);
        local resList = self:_getNeededResList(self.trackObj_.resTable_, eventType);
        resTactic:loadResourceOnTheFlySync(resList);
    end

    if eventObj.resourceManagerTacticType_ ~= definations.MANAGER_TACTIC_TYPE.NO_NEED then
        local resTactic  = self:_getResourceTactic(eventObj.resourceManagerTacticType_);
        resTactic:loadResourceOnTheFlySync(eventObj.eventData_.resourcesNeeded_);
    end
    self.eventLoadedStatus_[eventObj] = nil;
    -- table.remove(self.eventLoadedStatus_,eventObj);
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
        for i = 1,#eventObj.eventData_.resourcesNeeded_ do 
            local path = eventObj.eventData_.resourcesNeeded_[i].path;
            tactic:releaseResourceOnTheFly(path);
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
    else
        assert(false, "error: creat tactic failed!");
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
    if self.director_.timeLine_ > self.director_.timeLength_ then
        return;
    end
    self.playState_ = definations.PLAY_STATE.PLAYING;
    self:preparePlayingEvents();
end

function prototype:onCharacterEventEntered()
    return;
end

return prototype;
