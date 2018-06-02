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
    self.roleObj_ = nil;
    self.tacticByTrack_ = {};
	self.cameras_ = {};
    self.trackNameTable_ = {};--key:track字符串id,value:player
    self.callbackIndex_ = 0; --key :用于给track和event添加回调标记.
    self.callbackObjects_ = {}; --key:self.callbackIndex_,value: event对象或者track对象
    self.trackGroups_ = {};  --数组，数组每一个元素为一个table，放同一分组的tracks
end


function prototype:initialize(camera)
    self.time_ = newClass("eSkyPlayer/eSkyPlayerTimeLine");
    self.timerId_ = TimersEx.Add(0, 0, delegate(self, self._update));
    self.camera_ = camera;
    self.cameras_ = {camera};

    self.tacticByTrack_[definations.TRACK_TYPE.CAMERA_EFFECT] = definations.MANAGER_TACTIC_TYPE.LOAD_INITIALLY_SYNC_RELEASE_LASTLY;
    self.tacticByTrack_[definations.TRACK_TYPE.SCENE_MOTION] = definations.MANAGER_TACTIC_TYPE.LOAD_INITIALLY_RELEASE_LASTLY;
    self.tacticByTrack_[definations.TRACK_TYPE.ROLE_MOTION] = definations.MANAGER_TACTIC_TYPE.LOAD_ON_THE_FLY_RELEASE_IMMEDIATELY;
    self.tacticByTrack_[definations.TRACK_TYPE.CHARACTER] = definations.MANAGER_TACTIC_TYPE.LOAD_INITIALLY_SYNC_RELEASE_LASTLY;
    self.tacticByTrack_[definations.TRACK_TYPE.ADDON] = definations.MANAGER_TACTIC_TYPE.LOAD_INITIALLY_SYNC_RELEASE_LASTLY;
    self.tacticByTrack_[definations.TRACK_TYPE.AVATAR_PART] = definations.MANAGER_TACTIC_TYPE.LOAD_INITIALLY_SYNC_RELEASE_LASTLY;
    self.tacticByTrack_[definations.TRACK_TYPE.TWO_D_OBJECT] = definations.MANAGER_TACTIC_TYPE.LOAD_INITIALLY_RELEASE_LASTLY;
    self.cameraEffectManager_ = eSkyPlayerCameraEffectManager.New();
    return true;
end


function prototype:uninitialize()
    self:_releaseResource();
    self.time_ = nil;
    for i = 1, #self.players_ do
        self.players_[i]:uninitialize();
    end
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
        callback(false);
        return;
    end
    self:loadResource(function(isPrepared)
        callback(isPrepared);
    end);

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
    self:_creatTrackGroups();
    self:_sortPlayers(self.players_);  --players排序
    self:_createAdditionalCamera();
    self:_makeTrackNameTable();
    self:_addCallBackForCharacterTrack(delegate(self, self.onCharacterEventEntered), definations.EVENT_PLAYER_STATE.EVENT_START);  --添加character轨道的响应函数
    self:_assignRole();  --给character的相关轨道分配role
    return true;
end


function prototype:_addCallBackForCharacterTrack(callback, eventPlayerState)
    local characterPlayersName = self:_getPlayersNameByTrackType(definations.TRACK_TYPE.CHARACTER);
    for i = 1, #characterPlayersName do
        local playerName = characterPlayersName[i];
        self:addEventCallbackToTrack(playerName, callback, eventPlayerState)
    end
end


function prototype:_getPlayersNameByTrackType(trackType)
    local playersName = {};
    for i = 1, #self.players_ do
        local player = self.players_[i];
        local track = player:getTrack();
        if track:getTrackType() == trackType then
            local name = self:getTrackNameByPlayer(player);
            playersName[#playersName + 1] = name;
        end
    end
    return playersName;
end

function prototype:changeResourceManagerTactic(obj, tacticType)
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
    if obj.eventType_ and obj.eventType_ == definations.EVENT_TYPE.TWO_D_OBJECT or   --2DObject的资源(UI)不能用同步方式加载
        obj.trackObj_ and obj.trackObj_.trackType_ == definations.TRACK_TYPE.TWO_D_OBJECT or
        obj.trackType_ and obj.trackType_ == definations.TRACK_TYPE.TWO_D_OBJECT then
        if tacticType == LOAD_INITIALLY_SYNC_RELEASE_LASTLY or
            tacticType == LOAD_ON_THE_FLY_SYNC_RELEASE_IMMEDIATELY then
            assert(false, "error: please assign right tactic!");
        end
    end
    obj.resourceManagerTacticType_ = tacticType;
end


function prototype:loadResource(callback)
    if self:_loadResourceSync() == false then
        callback(false);
        return;
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
end


function prototype:play()
    self.cameraEffectManager_:initialize(self.camera_,self.additionalCamera_);
    if #self.players_ == 0 then
        return false;
    end
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

    if self.isPlaying_ == true then
        -- self.isPlaying_ = false;
        for i = 1, #self.players_ do
            if self.players_[i]:seek(time) == false then
                return false;
            end
        end
    else
        for i = 1, #self.players_ do
            if self.players_[i]:seek(time) == false then
                return false;
            end
        end
        self.isPlaying_ = true;
        self:_update();
        self.isPlaying_ = false;
    end
    self.isSeek_ = false;
    return true;
end


function prototype:_sortPlayers(players)  --把角色类型的player置顶
    for i = 1, #players do
        local player = players[i];
        local track = player:getTrack()
        if track:getTrackType() == definations.TRACK_TYPE.CHARACTER then
            for j = 2, i do
                local index = i - j + 2;
                players[index] = players[index - 1];
            end
            players[1] = player;
        end
    end
end

--动态添加track
function prototype:addTrack(trackName, track, callback, index) --index为分组下标，如果为空则不分组
    local player = self:_createPlayerByTrack(track);
    self:_sortPlayers(self.players_);
    if player ~= nil then
        self:_setTrackNameTable(trackName, player);
        local trackType = player.trackObj_:getTrackType();
        local tacticType = self:_getTacticTypeByTrackType(trackType);
        if tacticType ~= nil then
            self:changeResourceManagerTactic(player, tacticType);
            self:changeResourceManagerTactic(track, tacticType);
            for i = 1, track:getEventCount() do
                self:changeResourceManagerTactic(track:getEventAt(i), tacticType);
            end
        end
        if index ~= nil then
            local group = self.trackGroups_[index];
            if track:getTrackType() == definations.TRACK_TYPE.CHARACTER then
                local role = player:getRoleAgent();
                for j = 1, #group do
                    local track = group[j];
                    local p = self:_getPlayerByTrack(track);
                    p:setRoleAgent(role);
                end
            else
                local role = self:_getRoleAgent(group);
                player:setRoleAgent(role);
            end
        end
        local res = player:getResources();
        local isSyncPrepared = player:loadResourceInitiallySync();
        player:loadResourceInitially(function(isPrepared)
            isSyncPrepared = isPrepared;
        end);
        local resourceManager = require("eSkyPlayer/eSkyPlayerResourceManager");
        resourceManager:prepare(res, function (isPrepared)
            self:_createAdditionalCamera();
            player:onResourceLoaded();
            callback(isSyncPrepared == isPrepared);
        end);
    end
end


function prototype:setNewCamera(camera)
    self.camera_ = camera;--改变camera的函数
end

function prototype:_refreshTimeLength()
    for i = 1, #self.players_ do
        local pTrackObj = self.players_[i].trackObj_;
        local trackLength = pTrackObj:getTrackLength();
        if trackLength > self.timeLength_ then
            self.timeLength_ = trackLength;
        end
    end
end

function prototype:getCameras()
    return self.cameras_;
end

function prototype:_createPlayerByTrack(track)
    local trackType = track:getTrackType();
    if track:getTrackLength() > self.timeLength_ then
        self.timeLength_ = track:getTrackLength();
    end
    local player = nil;
    if trackType == definations.TRACK_TYPE.CAMERA_MOTION then
        player = newClass("eSkyPlayer/eSkyPlayerCameraMotionPlayer",self);
    elseif trackType == definations.TRACK_TYPE.CAMERA_PLAN then
        player = newClass("eSkyPlayer/eSkyPlayerCameraPlanPlayer",self);
    elseif trackType == definations.TRACK_TYPE.CAMERA_EFFECT then
        player = newClass("eSkyPlayer/eSkyPlayerCameraEffectPlayer",self);
    elseif trackType == definations.TRACK_TYPE.SCENE_PLAN then
        player = newClass("eSkyPlayer/eSkyPlayerScenePlanPlayer",self);
    elseif trackType == definations.TRACK_TYPE.SCENE_MOTION then
        player = newClass("eSkyPlayer/eSkyPlayerSceneTrackPlayer",self);
    elseif trackType == definations.TRACK_TYPE.ROLE_PLAN then
        player = newClass("eSkyPlayer/eSkyPlayerRolePlanPlayer", self);
    elseif trackType == definations.TRACK_TYPE.ROLE_MOTION then
        player = newClass("eSkyPlayer/eSkyPlayerRoleMotionPlayer", self);
    elseif trackType == definations.TRACK_TYPE.ROLE_MORPH then
        player = newClass("eskyPlayer/eSkyPlayerRoleMorphPlayer", self);
    elseif trackType == definations.TRACK_TYPE.CHARACTER then
        player = newClass("eskyPlayer/eSkyPlayerCharacterPlayer", self);
    elseif trackType == definations.TRACK_TYPE.ADDON then
        player = newClass("eskyPlayer/eSkyPlayerAddonPlayer", self);
    elseif trackType == definations.TRACK_TYPE.AVATAR_PART then
        player = newClass("eskyPlayer/eSkyPlayerAvatarPartPlayer", self);
    elseif trackType == definations.TRACK_TYPE.TWO_D_OBJECT then
        player = newClass("eskyPlayer/eSkyPlayer2DObjectPlayer", self);
    else
        player = nil;
    end
    if player ~= nil then
        self.players_[#self.players_ + 1] = player;
        player:initialize(track);
        return player;
    else
        return nil;
    end
end

function prototype:_makeTrackNameTable()
    for i = 1, #self.players_ do
        local player = self.players_[i];
        self:_setTrackNameTable(player.trackObj_.name_, player);
    end
end

function prototype:getPlayerByTrackName(trackName)
    if self.trackNameTable_[trackName] then
        return self.trackNameTable_[trackName];
    end
    return nil;
end

function prototype:getTrackNameByPlayer(player)
    for k, v in pairs(self.trackNameTable_) do
        if player == v then
            return k;
        end
    end
    return nil;
end

function prototype:_setTrackNameTable(playerName, player)
    local pPlayer = self.trackNameTable_[playerName];
    if pPlayer == nil then
        self.trackNameTable_[playerName] = player;
    else
        logError("name repeat >>>>" ..playerName);
    end
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
    self.cameras_[#self.cameras_ + 1] = self.additionalCamera_;
end

--TODO:以后考虑是否支持多个cameraMotionTrack的播放，cameras（包括主camera和additionalCamera_为一组）分组设置；
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
    for i = 1, obj:getTrackCount() do
        local track = obj:getTrackAt(i);
        if track:getEventCount() > 0 then    
            local event_ = track:getEventAt(1);
            
            if event_:isProject() then
                self:_createPlayer(event_:getProjectData());
            end
        end

        if self:_createPlayerByTrack(track) == nil then
            return false;
        end
    end
    return true;
end


function prototype:_update()
    if self.isPlaying_ == false or self.timeLine_ > self.timeLength_ then
        return;
    end
    local isRefreshTimeLine = false;
    self.timeLine_ = self.time_:getTime();
    self.time_:setTime(self.timeLine_ + Time.deltaTime);
    for i = 1, #self.players_ do
        local player = self.players_[i];
        if player.trackObj_.isDirtyEvent_ then
            player.trackObj_.isDirtyEvent_ = false;
            self:seek(self.timeLine_);
            isRefreshTimeLine = true;
        end
        player:_update();
    end
    if isRefreshTimeLine then 
        isRefreshTimeLine = false; 
        self:_refreshTimeLength(); 
    end
end


function prototype:_assignRole()
    for i = 1, #self.trackGroups_ do
        local group = self.trackGroups_[i];
        local role = self:_getRoleAgent(group);
        if role == nil then 
            return;
        end
        for j = 1, #group do
            local track = group[j];
            local player = self:_getPlayerByTrack(track);
            player:setRoleAgent(role);
        end
    end
end


function prototype:_getRoleAgent(group)  --group为数组，存放同一分组的tracks；
    local player = nil;
    local roleAgent = nil;
    for i = 1, #group do
        local track = group[i];
        if track.trackType_ == definations.TRACK_TYPE.CHARACTER then
            player = self:_getPlayerByTrack(track);
            break;
        end
    end
    if player ~= nil then
        roleAgent = player:getRoleAgent();
    end
    return roleAgent;
end


function prototype:_getPlayerByTrack(track)
    for i = 1, #self.players_ do
        if self.players_[i]:getTrack() == track then
            return self.players_[i];
        end
    end
    return nil;
end


function prototype:_creatTrackGroups()
    for i = 1, self.project_:getTrackCount() do
        local track = self.project_:getTrackAt(i);
        if track.trackType_ == definations.TRACK_TYPE.ROLE_PLAN then
            if track:getEventCount() > 0 then    
                local event = track:getEventAt(1);
                local project = event:getProjectData();
                local group = project:getTracks();
                if #group > 0 then
                    self:_addTrackGroup(group);
                end
            end
        end
    end
end


function prototype:_addTrackGroup(tab)
    self.trackGroups_[#self.trackGroups_ + 1] = tab;
end


function prototype:addEventCallbackToTrack(playerName, callback, callbackState)
    local player = self:getPlayerByTrackName(playerName);
    if player == nil then
        logError(playerName .." not find");
        return;
    end
    self.callbackIndex_ = self.callbackIndex_ + 1;
    player.trackObj_:addTrackCallback(callbackState, self.callbackIndex_, callback);
    local tmp = {};
    tmp.trackObj = player.trackObj_;
    tmp.isTrackCallback = true;
    tmp.callbackState = callbackState;
    self.callbackObjects_[self.callbackIndex_] = tmp;
    return self.callbackIndex_;

end

function prototype:addEventCallbackToEvent(event, callback, callbackState)
    if callback == nil then
        logError("callback is nil");
        return;
    end

    self.callbackIndex_ = self.callbackIndex_ + 1;
    event:addEventCallback(callbackState, self.callbackIndex_, callback);
    local tmp = {};
    tmp.eventObj = event;
    tmp.isTrackCallback = false;
    tmp.callbackState = callbackState;
    self.callbackObjects_[self.callbackIndex_] = tmp;
    return self.callbackIndex_;
end

function prototype:removeCallback(callbackIndex)
    if self.callbackObjects_[callbackIndex] then
        local tmp = self.callbackObjects_[callbackIndex];
        if tmp.isTrackCallback then
            local trackCallbacks = tmp.trackObj:getTrackCallback(tmp.callbackState);
            self:_removeCallback(trackCallbacks, callbackIndex);
        else
            local eventCallbacks = tmp.eventObj:getEventCallback(tmp.callbackState);
            self:_removeCallback(eventCallbacks, callbackIndex);
        end
    end

end

function prototype:_removeCallback(callbacks, callbackIndex)
    callbacks[callbackIndex] = nil;
    self.callbackObjects_[callbackIndex] = nil;
end


function prototype:findEventByTime(playerName, time)
    local events = self:_getTrackEvents(playerName);
    local findEvents = {};
    if events ~= nil and #events > 0 then
        for i = 1, #events do
            local beginTime = events[i]:getCurrentBeginTime();
            local endTime = beginTime + events[i]:getEventCurrentLength();
            if time >= beginTime and time <= endTime then
                findEvents[#findEvents + 1] = events[i];
            end
        end
    end
    return findEvents;

end

function prototype:findEventAt(playerName, eventIndex)
    local events = self:_getTrackEvents(playerName);
    if events ~= nil and #events >= eventIndex then
        return events[eventIndex];
    end
    return nil;
end

function prototype:_getTrackEvents(playerName)
    assert(type(playerName) == 'string', "playerName is not string");
    local player = self:getPlayerByTrackName(playerName);
    if player == nil then 
        return nil; 
    end
    return player.trackObj_.events_;
    
end

function prototype:_releaseResource()
    for i = 1, #self.players_ do
        self.players_[i]:releaseResource();
    end
end


function prototype:_getTacticTypeByTrackType(trackType)
    return self.tacticByTrack_[trackType];
end


function prototype:_assignDefaultTactic()
    if #self.players_ == 0 then
        return;
    end
    for i = 1, #self.players_ do
        local player = self.players_[i];
        if player.trackObj_ ~= nil then
            local trackType = player.trackObj_:getTrackType();
            local tacticType = self:_getTacticTypeByTrackType(trackType);
            if tacticType ~= nil then
                if player.resourceManagerTacticType_ == definations.MANAGER_TACTIC_TYPE.NO_NEED then
                    self:changeResourceManagerTactic(player, tacticType);
                end
                if player.trackObj_.resourceManagerTacticType_ == definations.MANAGER_TACTIC_TYPE.NO_NEED then
                    self:changeResourceManagerTactic(player.trackObj_, tacticType);
                end
                count = player.trackObj_:getEventCount();
                for j = 1, count do
                    local event = player.trackObj_:getEventAt(j);
                    if #event.eventData_.resourcesNeeded_ ~= 0 and event.resourceManagerTacticType_ == definations.MANAGER_TACTIC_TYPE.NO_NEED then
                        self:changeResourceManagerTactic(event, tacticType);
                    end
                end
            end
        end
    end
end


function prototype:_loadResourceSync()
    self:_assignDefaultTactic();
    for i = 1, #self.players_ do
        if self.players_[i]:loadResourceInitiallySync() == false then
            return false;
        end
    end
    return true;
end


function prototype:_loadResource(callback)
    self:_assignDefaultTactic();
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
                    callback(false);
                else
                    callback(true);
                end
            end);
end


-- roleObj必须是eSkyPlayerRoleAgent对象
function prototype:addRole(roleObj, index)  --外部传入roleObj，指定index为self.trackGroups_数组的index值
    local group = self.trackGroups_[index];  --把roleObj传给该分组的每一个track；
    for j = 1, #group do
        local track = group[j];
        local player = self:_getPlayerByTrack(track);
        player:setRoleAgent(roleObj);
    end
end

function prototype:getRole()
    return self.roleObj_;
end

function prototype:setAnimatorCrossFadeTransitionDuration(obj, duration) --obj必须为"eSkyPlayerRoleMotionPlayer"对象；
    obj.transitionDuration_ = duration;
end


function prototype:onCharacterEventEntered(track, event)  --character的轨道有event进入时的回调函数
    local group = self:_getGroupByTrack(track);
    for i = 1, #group do
        local track = group[i];
        local trackType = track:getTrackType()
        local player = self:_getPlayerByTrack(track);
        player:onCharacterEventEntered();
    end
end

function prototype:_getGroupByTrack(track)
    for i = 1, #self.trackGroups_ do
        local group = self.trackGroups_[i];
        for j = 1, #group do
            if group[j] == track then
                return group;
            end
        end
    end
    return nil;
end


return prototype;