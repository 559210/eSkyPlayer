local prototype = class("eSkyPlayerDirector");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    self.timerId_ = 0;
    self.timeLength_ = 0;
    self.timeLine_ = 0;
    self.isPlaying_ = false;
    self.isSeek_ = false;
    self.players_ = {}; 
    self.camera_ = nil;
    self.additionalCamera_ = nil;
    self.cameraEffectManager_ = nil;
    self.project_ = nil;
    self.time_ = nil;
    self.tacticByTrack_ = {};
end


function prototype:initialize(camera)
    self.time_ = newClass("eSkyPlayer/eSkyPlayerTimeLine");
    self.timerId_ = TimersEx.Add(0, 0, delegate(self, self._update));
    self.camera_ = camera;
    self.tacticByTrack_ = {
        {
            trackType_ = definations.TRACK_TYPE.CAMERA_EFFECT,
            tacticType_ = definations.MANAGER_TACTIC_TYPE.LOAD_INITIALLY_RELEASE_LASTLY
        },
        {
            trackType_ = definations.TRACK_TYPE.SCENE_MOTION,
            tacticType_ = definations.MANAGER_TACTIC_TYPE.LOAD_INITIALLY_RELEASE_LASTLY
        },

    };
    self.cameraEffectManager_ = eSkyPlayerCameraEffectManager.New();
end


function prototype:uninitialize()
    self:_releaseResource();
    self.time_ = nil;
    self.players_ = nil; 
    self.camera_ = nil;
    self.project_ = nil;
    if self.timerId_ ~= nil then
        TimersEx.Remove(self.timerId_);
        self.timerId_ = nil;
    end
    if self.additionalCamera_ ~= nil then
        GameObject.Destroy(self.additionalCamera_.gameObject); 
        self.additionalCamera_ = nil;
    end
    self.cameraEffectManager_:dispose();
    self.cameraEffectManager_ = nil;
    local resourceManager = require("eSkyPlayer/eSkyPlayerResourceManager");
end


function prototype:load(filename,callback)
    if self:loadProject(filename) == false then
        return false;
    end
    self:loadResource(function(isPrepared)
        callback(isPrepared);
    end);
    return true;
end


function prototype:loadProject(filename)
    self.project_ = newClass("eSkyPlayer/eSkyPlayerProjectData");
    self.project_:initialize();
    if self.project_:loadProject(filename) == false then 
        return false;
    end
    if self:_createPlayer(self.project_) == false then
        return false;
    end
    self:_createAdditionalCamera();
    return true;
end


function prototype:changeResourceManagerTactic(obj,tacticType)
    if obj == nil or obj.resourceManagerTacticType_ == nil or tacticType == nil then
        return;
    end
    local isIncluded = false;
    for k, v in pairs(definations.MANAGER_TACTIC_TYPE) do
        if v == tacticType then
            isIncluded = true;
            break;
        end
    end
    assert(isIncluded, "error: please assign right tactic!");  --如果分配策略错误，则报错，中断
    obj.resourceManagerTacticType_ = tacticType;
end


function prototype:loadResource(callback)
    if self:_loadResourceSync() == false then
        return false;
    end

    async.series({
        function(done)
            self:_loadResource(function(isPrepared)
                if isPrepared == false then
                    done("resource load failed");
                else
                    done();
                end
            end);
        end,
        function(done)
            local resList_ = self:_getResources();
            local resourceManager = require("eSkyPlayer/eSkyPlayerResourceManager");
            resourceManager:prepare(resList_,function (isPrepared)
                for i = 1, #self.players_ do
                    self.players_[i]:onResourceLoaded();    
                end
                if isPrepared == false then
                    done("resList_ load failed");
                else
                    done();
                end
            end);
        end,
        },function(err)
            if err ~= nil then
                callback(false);
            else
                callback(true);
            end
        end);
    return true;
end


function prototype:play()
    self.cameraEffectManager_:initialize(self.camera_,self.additionalCamera_);
    if #self.players_ == 0 then
        return false;
    end
    self.isSeek_ = false;
    self.isPlaying_ = true;
    for i = 1, #self.players_ do
        if self.players_[i]:play() == false then
            return false;
        end
    end
    return true;
end


function prototype:stop()
    if self.isPlaying_ == false then
        return false;
    end

    self.timeLine_ = self.time_:getTime();
    self.time_:setTime(self.timeLine_ + Time.deltaTime);
    self.isPlaying_ = false;
    for i = 1, #self.players_ do
        if self.players_[i]:stop() == false then
            return false;
        end
    end
    return true;
end


function prototype:seek(time)
    if time < 0 or time > self.timeLength_ then
        return false;
    end
    self.isSeek_ = true;
    self.time_:setTime(time);
    self.timeLine_ = time;

    for i = 1, #self.players_ do
        if self.players_[i]:seek(time) == false then
            return false;
        end
    end
    if self.isPlaying_ == false then
        self.isPlaying_ = true;
        self:_update();
        self.isPlaying_ = false;
    end

    return true;
end


function prototype:setNewCamera(camera)
    self.camera_ = camera;--改变camera的函数
end


function prototype:_getResources()
    local resList_ = {};
    if #self.players_ == 0 then
        return nil;
    end
    for i = 1,#self.players_ do
        local res = self.players_[i]:getResources();
        if res ~= nil then
            for j = 1,#res do
                resList_[#resList_ + 1] = res[j];
            end
        end
    end
    return resList_;
end


function prototype:_createCamera()
    local obj_ = newGameObject("camera");
    self.additionalCamera_ = obj_:AddComponent(typeof(Camera));
    self.additionalCamera_.enabled = false;
end


function prototype:_createAdditionalCamera()
    if self.additionalCamera_ ~= nil then 
        return false;
    end

    for i = 1, #self.players_ do
        if self.players_[i]:isNeedAdditionalCamera() == true then
            if self.additionalCamera_ == nil then
                self:_createCamera();
            end
            self.players_[i]:setAdditionalCamera(self.additionalCamera_);
        end
    end
end


function prototype:_createPlayer(obj)
    if obj:getTrackCount() == 0 then
        return true;
    end

    for i = 1, obj:getTrackCount() do
        local track = obj:getTrackAt(i);
        if track:getEventCount() > 0 then    
            local event_ = track:getEventAt(1);
            
            if event_:isProject() then
                self:_createPlayer(event_:getProjectData());
            end

            if track:getTrackLength() > self.timeLength_ then
                self.timeLength_ = track:getTrackLength();
            end
        end
        local trackType = track:getTrackType();
        if trackType == definations.TRACK_TYPE.CAMERA_MOTION then
            local player = newClass ("eSkyPlayer/eSkyPlayerCameraMotionPlayer",self);
            self.players_[#self.players_ + 1] = player;
            player:initialize(track);
        elseif trackType == definations.TRACK_TYPE.CAMERA_PLAN then
            local player = newClass ("eSkyPlayer/eSkyPlayerCameraPlanPlayer",self);
            self.players_[#self.players_ + 1] = player;
            player:initialize(track);
        elseif trackType == definations.TRACK_TYPE.CAMERA_EFFECT then
            local player = newClass ("eSkyPlayer/eSkyPlayerCameraEffectPlayer",self);
            self.players_[#self.players_ + 1] = player;
            player:initialize(track);
        elseif trackType == definations.TRACK_TYPE.SCENE_PLAN then
            local player = newClass ("eSkyPlayer/eSkyPlayerScenePlanPlayer",self);
            self.players_[#self.players_ + 1] = player;
            player:initialize(track);
        elseif trackType == definations.TRACK_TYPE.SCENE_MOTION then
            local player = newClass("eSkyPlayer/eSkyPlayerSceneTrackPlayer",self);
            self.players_[#self.players_ + 1] = player;
            player:initialize(track);
        else 
            return false;
        end
    end

    return true;
end


function prototype:_update()
    if self.isPlaying_ == false then
        return;
    end

    self.timeLine_ = self.time_:getTime();
    self.time_:setTime(self.timeLine_ + Time.deltaTime);

    for i = 1, #self.players_ do
        self.players_[i]:_update();
    end
end


function prototype:_releaseResource()
    for i = 1, #self.players_ do
        self.players_[i]:releaseResource();
    end
end


function prototype:_assignDefaultTactic(obj)
    if #self.players_ == 0 then
        return;
    end

    for i = 1, #self.players_ do
        local track = self.players_[i].trackObj_;
        if track ~= nil then
        local trackType = track:getTrackType();

        for j = 1, #self.tacticByTrack_ do
            if trackType == self.tacticByTrack_[j].trackType_ then
                local count = 0;
                for k, v in pairs(self.players_[i].resTable_) do
                    count = count + 1;
                end
                if count ~= 0 and self.players_[i].resourceManagerTacticType_ == definations.MANAGER_TACTIC_TYPE.NO_NEED then
                    self:changeResourceManagerTactic(self.players_[i],self.tacticByTrack_[j].tacticType_);
                end

                count = 0;
                -- if track.resTable_ ~= nil then
                for k, v in pairs(track.resTable_) do
                    count = count + 1;
                end
                if count ~= 0 and track.resourceManagerTacticType_ == definations.MANAGER_TACTIC_TYPE.NO_NEED then
                    self:changeResourceManagerTactic(track,self.tacticByTrack_[j].tacticType_);
                end

                count = track:getEventCount();
                for k = 1, count do
                    local event = track:getEventAt(k);
                    if #event.resourcesNeeded_ ~= 0 and event.resourceManagerTacticType_ == definations.MANAGER_TACTIC_TYPE.NO_NEED then
                        self:changeResourceManagerTactic(event,self.tacticByTrack_[j].tacticType_);
                    end
                end
            end
            -- end
        end
    end
    end
end


function prototype:_loadResourceSync()
    self:_assignDefaultTactic(self.project_);
    for i = 1, #self.players_ do
        if self.players_[i]:loadResourceInitiallySync() == false then
            return false;
        end
    end
    return true;
end


function prototype:_loadResource(callback)
    self:_assignDefaultTactic(self.project_);
    async.mapSeries(self.players_,
        function(player,done)
            player:loadResourceInitially(function(isPrepared)
                if isPrepared == false then
                    done(false);
                    return;
                end
                done();
            end)
        end,function (err)
                if err ~= nil then
                    logError("22222222222222")
                    callback(false);
                else
                    callback(true);
                end
            end);
end


--------------------------------------------------------------------------
-- 下面是动态创建track，event的代码，其他代码往上写
function prototype:getPlayerByTrackType(trackType)
end


function prototype:createTrackPlayer(trackObj)   -- trackObj由track类的静态函数createObject生成
end


function prototype:createEventToTrackPlayer(trackPlayer, eventObj) -- eventObj由event类的静态函数createObject生成
end


return prototype;