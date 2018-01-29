local prototype = class("eSkyPlayerDirector");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    self.timerId_ = 0;
    self.timeLength_ = 0;
    self.timeLine_ = 0;
    self.isPlaying_ = false;
    self.players_ = nil;
    self.camera_ = nil;
    self.additionalCamera_ = nil;
    self.cameraEffectManager_ = nil;
end


function prototype:initialize(camera)
    self.time_ = newClass("eSkyPlayer/eSkyPlayerTimeLine");
    self.timerId_ = TimersEx.Add(0, 0, delegate(self, self._update));
    self.players_ = {}; 
    self.camera_ = camera;
    self.resourceManager_ = newClass("eSkyPlayer/eSkyPlayerResourceManager");
    self.cameraEffectManager_ = eSkyPlayerCameraEffectManager.New();
end


function prototype:uninitialize()
    self.time_ = nil;
    self.players_ = nil; 
    self.camera_ = nil;
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
    self.resourceManager_:releaseAllResource();
    self.resourceManager_ = nil;
end


function prototype:loadImmediately(filename)                --filename暂时只支持project，不支持track；
    -- 判断filename对应文件是哪种类型
    -- if string.sub(filename,-5,-1) == ".byte" then-- filename is track
    --  self:_loadTrack(filename);
    -- else                                         -- filename is project
        local project = newClass("eSkyPlayer/eSkyPlayerProjectData");
        project:initialize();
        if project:loadProject(filename) == false then 
            return false;
        end

        if self:_createPlayer(project) == false then
            return false;
        end
        local resList_ = self:_getResources();
        if resList_ == nil then
            return false;
        end
        if self.resourceManager_:prepareImmediately(resList_) == false then
            return false;
        end
        self:_createAdditionalCamera();
        return true;
    --end
end


function prototype:load(filename,callback)
        local project = newClass("eSkyPlayer/eSkyPlayerProjectData");
        project:initialize();
        if project:loadProject(filename) == false then 
            callback(false);
            return;
        end
        if self:_createPlayer(project) == false then
            callback(false);
            return;
        end

        local resList_ = self:_getResources();
        self.resourceManager_:prepare(resList_,function (isPrepared)
            self:_createAdditionalCamera();
            callback(isPrepared);
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

    self.time_:setTime(time);
    if (self.isPlaying_ == false) then
        self.isPlaying_ = true;
        self:_update();
        self.isPlaying_ = false;
    end

    for i = 1, #self.players_ do
        if self.players_[i]:seek(time) == false then
            return false;
        end
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
             -- elseif trackType == TrackEventType.MusicType then
             --     local player = newClass ("eSkyPlayer/eSkyPlayerMusicPlayer",self);
             --     player:initialize(track);
             --     self.players_[#self.players_ + 1] = player;
             -- elseif trackType == TrackEventType.SceneType then
             --     local player = newClass ("eSkyPlayer/eSkyPlayerScenePlayer",self);
             --     player:initialize(track);
             --     self.players_[#self.players_ + 1] = player;
             -- elseif trackType == TrackEventType.SceneType then
            else 
                return false;
            end
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


--------------------------------------------------------------------------
-- 下面是动态创建track，event的代码，其他代码往上写
function prototype:getPlayerByTrackType(trackType)
end


function prototype:createTrackPlayer(trackObj)   -- trackObj由track类的静态函数createObject生成
end


function prototype:createEventToTrackPlayer(trackPlayer, eventObj) -- eventObj由event类的静态函数createObject生成
end

return prototype;