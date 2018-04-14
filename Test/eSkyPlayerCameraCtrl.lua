local prototype = class("eSkyPlayerCameraCtrl", mvc.viewCtrl)
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

-- 创建MVC事件号，参数为字符串
CREATE_MVC_CUSTOM_EVENT_GROUP(
    "SKYPLAYER_CAMERA_RETURN_BUTTON_CLICKED",
    "SKYPLAYER_CAMERA_PLAY_BUTTON_CLICKED",
    "SKYPLAYER_CAMERA_PAUSE_BUTTON_CLICKED",
    "SKYPLAYER_CAMERA_LOAD_BUTTON_CLICKED",
    "SKYPLAYER_CAMERA_PLAY_SLIDER_CHANGED");

-- prototype.RES_PREPARE = {
--     "ui/eSkyPlayerCamera",     -- 这里填写AssetsBundle的完整路基，不需要后缀名
-- }


-- 在这里添加事件的响应函数，声明成员变量统一也在这里初始化（虽然lua不需要声明变量）
-- 这里资源还未载入，self.view_还是nil
function prototype:onCreate()
    self:addEventListener(G.events.SKYPLAYER_CAMERA_RETURN_BUTTON_CLICKED, self.onCameraReturnButtonClicked);
    self:addEventListener(G.events.SKYPLAYER_CAMERA_LOAD_BUTTON_CLICKED, self.onCameraLoadButtonClicked);
    self:addEventListener(G.events.SKYPLAYER_CAMERA_PLAY_BUTTON_CLICKED, self.onCameraPlayButtonClicked);
    self:addEventListener(G.events.SKYPLAYER_CAMERA_PAUSE_BUTTON_CLICKED, self.onCameraPauseButtonClicked);
    self:addEventListener(G.events.SKYPLAYER_CAMERA_PLAY_SLIDER_CHANGED, self.onCameraPlaySliderChanged);
end


-- 这里是在Loading画面未关闭时候调用的，用来自己加载一些东西，调用callback以后会导致loading画面关闭
-- function prototype:onLoad(callback)
--     callback();
-- end


-- 加载资源完毕以后调用此函数，self.view_已经有内容了
function prototype:onStart()
    -- self.cameraTrack = nil;
    -- self.cameraPlayer = nil;
    G.M.create(ModelList.USER, 0);
    G.M.create(ModelList.MARRIAGE_INFO, 0);

    self.playerDirector = nil;
    self.camera = nil;
    self.view_:setSliderTouchable(false);
    self.timerId_ = TimersEx.Add(0, 0, delegate(self, self._updateSlider));
end


-- 资源将要释放（还未释放）
function prototype:onStop()
    if self.timerId_ ~= nil then
        TimersEx.Remove(self.timerId_);
        self.timerId_ = nil;
    end
end


-- 资源已经被释放
function prototype:onDestroy()
    
end

-- function prototype:onCameraLoadButtonClicked()
--     -- local track1 = newClass("eSkyPlayer/eSkyPlayerTrackDataBase");
--     -- logError("track1:" .. track1._index);
--     -- local track2 = newClass("eSkyPlayer/eSkyPlayerTrackDataBase");
--     -- -- local track3 = newClass("eSkyPlayer/eSkyPlayerTrackDataBase");
--     -- -- local track4 = newClass("eSkyPlayer/eSkyPlayerTrackDataBase");
--     -- logError("track1:" .. track1._index);
--     -- logError("track2:" .. track2._index);

--     -- if self.cameraPlayer ~= nil then
--     --  self.cameraPlayer:stop();
--     --  self.cameraPlayer = nil;
--     -- end
--     -- local event = newClass("eSkyPlayer/eSkyPlayerEventDataBase");
--     -- event:initialize();
--     -- event:loadEvent("mod/plans/camera/ccccc");
--     -- if event:isProject() then
--     --  logError("yes");
--     -- else
--     --  logError("XXXXXXXXXXX");
--     -- end


--     if self.playerDirector ~= nil then
--         self.playerDirector:stop();
--         self.playerDirector:uninitialize();
--         self.playerDirector = nil;
--         self.view_:setSliderTouchable(false);
--     end 

--     self.camera = self.view_:getCamera();
--     self.playerDirector = newClass("eSkyPlayer/eSkyPlayerDirector");
--     self.playerDirector:initialize(self.camera);

--     async.series({
--         function(cb)
--             self.playerDirector:load("mod/projects/0001PVE", function(isOk)
--                 if isOk ~= true then
--                     cb("director load fail");
--                     return;
--                 end
--                     cb();
--                 end);
--         end,
--         function(cb)
--             local itemCodes = {100153 , 100154 , 100155 ,100156 ,100157,100158,100159,100011,100010};
--             local skeletonUrl = "avatars/biped/man_biped";
--             local role = G.characterFactory:createTempRole(itemCodes, {}, false, skeletonUrl);
--             role.onRoleRefreshFinished = function(body, obj, sourceId)
--                 self.playerDirector:addRole(role);
--                 cb();
--             end;
--             role:refresh();
--         end,
--         function(cb)
--             -- self:_createVirtualCamreaMotionTrack();
--             -- self:_createScene();
--             -- self:_createSceneMotionTrack();
--             cb();
--         end,

--     }, function(err)
--         if err ~= nil then
--             if type(err) == "string" then
--                 logError(err);
--             else
--                 logError(tostring(err));
--             end
--         end
--     end);
-- end

function prototype:onCameraLoadButtonClicked()
    -- local path = "mod/projects/test/plans/camera/test1/cameraMotion"
    -- local e = string.match(path,"mod/projects/.+/");
    -- logError(e)
    -- local a,b = string.find(path,"mod/projects/.-/");
    -- local c,d = string.find(path,"mod/projects/.+/");
    -- logError("a===========" .. a)
    -- logError("b===========" .. b)
    -- logError("c===========" .. c)
    -- logError("d===========" .. d)
    --     self.title_ = string.sub(path,b + 1,d - 1);
    -- logError("path==" .. path)
    -- logError("self.title_===========" .. self.title_)



    -- local track1 = newClass("eSkyPlayer/eSkyPlayerTrackDataBase");
    -- logError("track1:" .. track1._index);
    -- local track2 = newClass("eSkyPlayer/eSkyPlayerTrackDataBase");
    -- -- local track3 = newClass("eSkyPlayer/eSkyPlayerTrackDataBase");
    -- -- local track4 = newClass("eSkyPlayer/eSkyPlayerTrackDataBase");
    -- logError("track1:" .. track1._index);
    -- logError("track2:" .. track2._index);

    -- if self.cameraPlayer ~= nil then
    --  self.cameraPlayer:stop();
    --  self.cameraPlayer = nil;
    -- end
    -- local event = newClass("eSkyPlayer/eSkyPlayerEventDataBase");
    -- event:initialize();
    -- event:loadEvent("mod/plans/camera/ccccc");
    -- if event:isProject() then
    --  logError("yes");
    -- else
    --  logError("XXXXXXXXXXX");

-----------------------------------
    if self.playerDirector ~= nil then
        self.playerDirector:stop();
        self.playerDirector:uninitialize();
        self.playerDirector = nil;
        self.view_:setSliderTouchable(false);
    end 

    self.camera = self.view_:getCamera();
    self.playerDirector = newClass("eSkyPlayer/eSkyPlayerDirector");

    local itemCodes = {100153 , 100154 , 100155 ,100156 ,100157,100158,100159,100011,100010};
    local skeletonUrl = "avatars/biped/man_biped";
    local role = G.characterFactory:createTempRole(itemCodes, {}, false, skeletonUrl);
    role.onRoleRefreshFinished = function(body, obj, sourceId)
        local roleAgent = newClass("eSkyPlayer/eSkyPlayerRoleAgent/eSkyPlayerRoleAgent");
        roleAgent:initialize(role);
        self.playerDirector:addRole(roleAgent);
        self.playerDirector:initialize(self.camera);
        self.playerDirector:load("mod/projects/0002PVE",function(isLoaded)--mytscene wedding 0001PVE animPlayTest noScene onlyScene cameraEffectP
            if isLoaded == true then
                logError("load success");
            else
                logError("load failed")
            end
        end);

            -- self.morph = newClass("eSkyPlayer/misc/morphPlay");
            -- local mesh = GameObject.Find("mesh");
            -- local meshRenderer = mesh:GetComponent(typeof(SkinnedMeshRenderer));
            -- self.morph:initialize(meshRenderer);
            -- if self.morph == nil then 
            --     logError("xxxxxxxxxxxxxxxxxxxxxxxxxxxx")
            --     return;
            -- end
    end;
    role:refresh();

    -- self:_createProject(); --动态创建


end

function prototype:onCameraPlayButtonClicked()
    if self.playerDirector == nil then
        return;
    end

    if self.playerDirector:play() == true then
        self.view_:setSliderMax(self.playerDirector.timeLength_);
        self.view_:setSliderTouchable(true);
    end
---------------------------------------------------
--     local path = "morph/getAngry";
--  ddResManager.loadAsset(path, function(asset)
--     if asset == nil then
--         logError("xxxxxxxxxxxxx")
--     else
--         -- local morphConfigInfo = cjson.decode(asset.text);
--         local temp = {Vector2.New(0,0), Vector2.New(0,0), Vector2.New(1,1),
--         Vector2.New(5,50), Vector2.New(4.8, 48), Vector2.New(5.2, 52),
--         Vector2.New(10,100), Vector2.New(9.8,98), Vector2.New(10,100)};
--         self.morph:play(asset.text, temp, 10, 100)
--     end
-- end)
------------------------------
    -- if self.cameraTrack == nil then
    --  return;
    -- end

    -- if self.cameraPlayer:play(self.cameraTrack, self.camera) == true then
    --  self.view_:setSliderMax(self.cameraPlayer.trackTimeLength_);
    --  self.view_:setSliderTouchable(true);
    -- end

    -- Test for camera effect
    -- if self.cameraEffectManager:start(self.bloomEffectId) == false then
    --     logError("start camera effect bloom failed");
    -- end
    -- local param = self.cameraEffectManager:getParam(self.bloomEffectId);
    -- if param ~= nil then
    --     param.intensity = 0;
    --     self.cameraEffectManager:setParam(self.bloomEffectId, param);
    -- end


    -- if self.cameraEffectManager:start(self.depthOfFieldEffectId) == false then
    --     logError("start camera effect depthOfField failed");
    -- end
    -- param = self.cameraEffectManager:getParam(self.depthOfFieldEffectId);
    -- if param ~= nil then
    --     param.aperture = 0;
    --     self.cameraEffectManager:setParam(self.depthOfFieldEffectId, param);
    -- end

    -- if self.cameraEffectManager:start(self.chromaticAberrationEffectId) == false then
    --     logError("start camera effect chromaticAberration failed");
    -- end
    -- param = self.cameraEffectManager:getParam(self.chromaticAberrationEffectId);
    -- if param ~= nil then
    --     param.intensity = 0;
    --     self.cameraEffectManager:setParam(self.chromaticAberrationEffectId, param);
    -- end

    -- if self.cameraEffectManager:start(self.vignetteEffectId) == false then
    --     logError("start camera effect vignette failed");
    -- end
    -- param = self.cameraEffectManager:getParam(self.vignetteEffectId);
    -- if param ~= nil then
    --     param.intensity = 0;
    --     self.cameraEffectManager:setParam(self.vignetteEffectId, param);
    -- end
end


function prototype:onCameraPlaySliderChanged()
    if self.playerDirector == nil then 
        return;
    end
    self.playerDirector:seek(self.view_:getSliderValue());
end

function prototype:onCameraReturnButtonClicked()
    -- self.playerDirector:uninitialize();
    self:gotoScene("eSkyPlayerMainMenu");
    return true;
end


function prototype:onCameraPauseButtonClicked()
--     self.roleAgent:setSpeed(0);

--     local path = "motions/clips/dance/huiguniang/xiandai_hgn_74_08_8";
--  ddResManager.loadAsset(path, function(asset)
--     if asset == nil then
--         logError("xxxxxxxxxxxxx")
--     else
--         self.roleAgent:play(asset, 1, 0, 2, false)
--     end
-- end)


    if self.playerDirector == nil then 
        return;
    end
    self.playerDirector:stop();
--------------------------------
    -- -- Test for camera effect
    -- if self.cameraEffectManager:pause(self.bloomEffectId) == false then
    --     logError("pause camera effect bloom failed");
    -- end
    -- if self.cameraEffectManager:pause(self.depthOfFieldEffectId) == false then
    --     logError("pause camera effect depthOfFieldEffectId failed");
    -- end
    -- if self.cameraEffectManager:pause(self.chromaticAberrationEffectId) == false then
    --     logError("pause camera effect chromaticAberration failed");
    -- end
    -- if self.cameraEffectManager:pause(self.vignetteEffectId) == false then
    --     logError("pause camera effect vignette failed");
    -- end 
end


function prototype:_updateSlider()
    if self.playerDirector == nil then 
        return;
    end
    self.view_:setSliderValue(self.playerDirector.timeLine_);
    self.view_:setTextContent(self.playerDirector.timeLine_);
    -- if self.morph == nil then 
    --     return;
    -- end
    -- self.morph:update();
end

function prototype:_createProject()
    self:_createVirtualCamreaMotionTrack(0, 22);
    self:_createScene();
    --self:_createSceneMotionTrack1(0, 3);
    --self:_createSceneMotionTrack2(0, 3);
    self:_createVirtualCamreaaEffectTrackByBlackEvent(0.5, 3);
    self:_createVirtualCamreaaEffectTrackByBloomEvent(3.1, 6);
    self:_createVirtualCameraEffectTrackByCrossFade(0.1, 1);
    self:_createVirtualCameraEffectTrackByFieldOfView(1.15, 3);
    self:_createVirtualCameraEffectTrackByChromaticAberration(0.6, 3);
    self:_createVirtualCameraEffectTrackByDepthOfField(0.1,2);
    self:_createVirtualCameraEffectTrackByVignette(0.5,1.5);
end

--动态创建相机track中的MotionTrackData
function prototype:_createVirtualCamreaMotionTrack(beginTime,timeLength)
    local cameraMotionTrack = require("eSkyPlayer/eSkyPlayerCameraMotionTrackData");
    local cameraMotionEvent = require("eSkyPlayer/eSkyPlayerCameraMotionEventData");
    local myMotionTrack = cameraMotionTrack.createObject({});
    local myMotionEvent = cameraMotionEvent.createObject({beginDrX = 26.718000411987,beginDrY = 247.32800292969,beginDrZ = 0.23700000345707,
                                                beginFrameX = 9.3030004501343, beginFrameY = 6.3340001106262, beginFrameZ = -1.069000005722,
                                                beginLookAtX = 0.48600000143051,beginLookAtY = 1.5230000019073,beginLookAtZ = -4.75,
                                                endDrX = 17.010000228882, endDrY = 213.44700622559, endDrZ = 356.96600341797,
                                                endFrameX = 4.3330001831055, endFrameY = 3.7820000648499, endFrameZ = 5.8480000495911,
                                                endLookAtX = 0.24600000679493, endLookAtY = 1.5160000324249, endLookAtZ = -0.33700001239777,
                                                fov = 60, pos1X = 0.33300000429153, pos1Y = 0.33300000429153,
                                                pos2X = 0.66600000858307, pos2Y = 0, timeLength = timeLength, tweenType = 0});
    if myMotionTrack ~= nil then
        myMotionTrack:addEvent(beginTime, myMotionEvent);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
    end
    self.playerDirector:addTrack(myMotionTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCamreaMotionTrack fail");
        end
    end);
end

function prototype:_createVirtualCamreaaEffectTrackByBlackEvent(beginTime,timeLength)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectBlackEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent1 = cameraEffectEvent.createObject({blendMode = 1, intensityRanges0 = 0, intensityRanges1 = -3,
                                            intensityWeight0 = 1, intensityWeight1 = 0, textureID = 1, timeLength = 0.5});
    local myEffectEvent2 = cameraEffectEvent.createObject({blendMode = 1,intensityRanges0 = 0,intensityRanges1 = -3,
                                                        intensityWeight0 = 1,intensityWeight1 = 0,textureID = 1, timeLength = 0.83300000429153});
    local myEffectEvent3 = cameraEffectEvent.createObject({blendMode = 1,intensityRanges0 = 0,intensityRanges1 = -3,intensityWeight0 = 1,
                                                        intensityWeight1 = 0,textureID = 1,timeLength = 0.33300000429153});
    local myEffectEvent4 = cameraEffectEvent.createObject({blendMode = 1,intensityRanges0 = 0,intensityRanges1 = 3,intensityWeight0 = 1,
                                                        intensityWeight1 = 0,textureID = 1,timeLength = 0.43299999833107});
    local myEffectEvent5 = cameraEffectEvent.createObject({blendMode = 1,intensityRanges0 = 0,intensityRanges1 = 3,intensityWeight0 = 1,
                                                        intensityWeight1 = 0,textureID = 1,timeLength = 0.83300000429153});
    local myEffectEvent6 = cameraEffectEvent.createObject({blendMode = 1,intensityRanges0 = 0,intensityRanges1 = 3,intensityWeight0 = 1,
                                                        intensityWeight1 = 0,textureID = 1,timeLength = 0.10000000149012});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(0.233, myEffectEvent1);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        myEffectTrack:addEvent(1.033, myEffectEvent2);
        myEffectTrack:addEvent(2.166, myEffectEvent3);
        myEffectTrack:addEvent(18.733, myEffectEvent4);
        myEffectTrack:addEvent(19.5, myEffectEvent5);
        myEffectTrack:addEvent(20.60, myEffectEvent6);
    end
    self.playerDirector:addTrack(myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCamreaaEffectTrackByBlackEvent fail");
        end
    end);
end
function prototype:_createVirtualCamreaaEffectTrackByBloomEvent(beginTime,timeLength)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectBloomEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent1 = cameraEffectEvent.createObject({intensityBloomRanges0 = 0,intensityBloomRanges1 = 1,intensityBloomWeight0 = 0,intensityBloomWeight1 = 300,
                                                intensityRanges0 = 0,intensityRanges1 = 300,intensityWeight0 = 0,intensityWeight1 = 1,
                                                radiusRanges0 = 0,radiusRanges1 = 7,radiusWeight0 = 0,radiusWeight1 = 1,resistBlinking = 0,
                                                softKneeRanges0 = 0,softKneeRanges1 = 1,softKneeWeight0 = 0,softKneeWeight1 = 1,textureID = 1,
                                                thresholdRanges0 = 0,thresholdRanges1 = 1,thresholdWeight0 = 0,thresholdWeight1 = 1,timeLength = 0.63300001621246});
    local myEffectEvent2 = cameraEffectEvent.createObject({intensityBloomRanges0 = 0,intensityBloomRanges1 = 1,intensityBloomWeight0 = 0,intensityBloomWeight1 = 300,
                                                intensityRanges0 = 0,intensityRanges1 = 300,intensityWeight0 = 0,intensityWeight1 = 1,
                                                radiusRanges0 = 0,radiusRanges1 = 7,radiusWeight0 = 0,radiusWeight1 = 1,resistBlinking = 0,
                                                softKneeRanges0 = 0,softKneeRanges1 = 1,softKneeWeight0 = 0,softKneeWeight1 = 1,textureID = 1,
                                                thresholdRanges0 = 0,thresholdRanges1 = 1,thresholdWeight0 = 0,thresholdWeight1 = 1,timeLength = 0.966000020504});
    local myEffectEvent3 = cameraEffectEvent.createObject({intensityBloomRanges0 = 0,intensityBloomRanges1 = 1,intensityBloomWeight0 = 0,intensityBloomWeight1 = 300,
                                                intensityRanges0 = 0,intensityRanges1 = 300,intensityWeight0 = 0,intensityWeight1 = 1,
                                                radiusRanges0 = 0,radiusRanges1 = 7,radiusWeight0 = 0,radiusWeight1 = 1,resistBlinking = 0,
                                                softKneeRanges0 = 0,softKneeRanges1 = 1,softKneeWeight0 = 0,softKneeWeight1 = 1, textureID = 1,
                                                thresholdRanges0 = 0,thresholdRanges1 = 1,thresholdWeight0 = 0,thresholdWeight1 = 1,timeLength = 0.46500000357628});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(2.966, myEffectEvent1);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        myEffectTrack:addEvent(4.066, myEffectEvent2);
        myEffectTrack:addEvent(5.333, myEffectEvent3);
    end
    self.playerDirector:addTrack(myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCamreaaEffectTrackByBloomEvent fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByCrossFade(beginTime,timeLength)

    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectCrossFadeEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent1 = cameraEffectEvent.createObject({alphaFromRanges0 = 1,alphaFromRanges1 = 0,alphaFromWeight0 = 0,
                            alphaFromWeight1 = 1,alphaToRanges0 = 0,alphaToRanges1 = 1,alphaToWeight0 = 0,
                            alphaToWeight1 = 1,timeLength = 0.63300001621246});
    local myEffectEvent2 = cameraEffectEvent.createObject({alphaFromRanges0 = 1,alphaFromRanges1 = 0,
                            alphaFromWeight0 = 0,alphaFromWeight1 = 1,alphaToRanges0 = 0,alphaToRanges1 = 1,
                            alphaToWeight0 = 0,alphaToWeight1 = 1,timeLength = 0.966000020504});
    local myEffectEvent3 = cameraEffectEvent.createObject({alphaFromRanges0 = 1,alphaFromRanges1 = 0,alphaFromWeight0 = 0,
                            alphaFromWeight1 = 1,alphaToRanges0 = 0,alphaToRanges1 = 1,
                            alphaToWeight0 = 0,alphaToWeight1 = 1,timeLength = 0.43200001120567});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(9.233, myEffectEvent1);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        myEffectTrack:addEvent(10.233, myEffectEvent2);
        myEffectTrack:addEvent(11.5, myEffectEvent3);
    end
    self.playerDirector:addTrack(myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByCrossFade fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByFieldOfView(beginTime,timeLength)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectFieldOfViewEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent1 = cameraEffectEvent.createObject({fovRanges0 = 1,fovRanges1 = 100,fovWeight0 = 0.2960000038147,
                                        fovWeight1 = 0.2960000038147,timeLength = 0.33300000429153});
    local myEffectEvent2 = cameraEffectEvent.createObject({fovRanges0 = 1,fovRanges1 = 100,fovWeight0 = 0.2960000038147,
                                        fovWeight1 = 0.2960000038147,timeLength = 0.73199999332428});
    local myEffectEvent3 = cameraEffectEvent.createObject({fovRanges0 = 1,fovRanges1 = 100,fovWeight0 = 0.2960000038147,
                                        fovWeight1 = 0.2960000038147,timeLength = 0.23199999332428});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(14.433, myEffectEvent1);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        myEffectTrack:addEvent(15.1, myEffectEvent2);
        myEffectTrack:addEvent(16.1, myEffectEvent3);
    end
    self.playerDirector:addTrack(myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByFieldOfView fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByChromaticAberration(beginTime,timeLength)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectChromaticAberrationEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent1 = cameraEffectEvent.createObject({intensityRanges0 = 0,intensityRanges1 = 1,intensityWeight0 = 0,
                                    intensityWeight1 = 1,textureID = 1,timeLength = 0.56499999761581});
    local myEffectEvent2 = cameraEffectEvent.createObject({intensityRanges0 = 0,intensityRanges1 = 1,intensityWeight0 = 0,
                                    intensityWeight1 = 1,textureID = 1,timeLength = 0.93300002813339});
    local myEffectEvent3 = cameraEffectEvent.createObject({intensityRanges0 = 0,intensityRanges1 = 1,intensityWeight0 = 0,
                                    intensityWeight1 = 1,textureID = 1,timeLength = 0.40000000596046});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(6.333, myEffectEvent1);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        myEffectTrack:addEvent(7.166, myEffectEvent2);
        myEffectTrack:addEvent(8.433, myEffectEvent3);
    end
    self.playerDirector:addTrack(myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByChromaticAberration fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByDepthOfField(beginTime,timeLength)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectDepthOfFieldEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent1 = cameraEffectEvent.createObject({apertureRanges0 = 0,apertureRanges1 = 15,apertureWeight0 = 1,
                                                            apertureWeight1 = 0,timeLength = 0.33300000429153});
    local myEffectEvent2 = cameraEffectEvent.createObject({apertureRanges0 = 0,apertureRanges1 = 15,apertureWeight0 = 1,
                                                            apertureWeight1 = 0,timeLength = 0.53200000524521});
    local myEffectEvent3 = cameraEffectEvent.createObject({apertureRanges0 = 0,apertureRanges1 = 15,apertureWeight0 = 1,
                                                            apertureWeight1 = 0,timeLength = 0.2660000026226});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(12.366, myEffectEvent1);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        myEffectTrack:addEvent(12.966, myEffectEvent2);
        myEffectTrack:addEvent(13.766, myEffectEvent3);
    end
    self.playerDirector:addTrack(myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByDepthOfField fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByVignette(beginTime,timeLength)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectVignetteEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent1 = cameraEffectEvent.createObject({allColorRanges0 = 0,allColorRanges1 = 255,allColorWeight0 = 0,allColorWeight1 = 1,
                                        intensityRanges0 = 0,intensityRanges1 = 1,intensityWeight0 = 0,intensityWeight1 = 1,modeID = 1,
                                        opacityRanges0 = 0,opacityRanges1 = 1,opacityWeight0 = 0,opacityWeight1 = 1,rounded = 0,
                                        roundnessRanges0 = 0,roundnessRanges1 = 1,roundnessWeight0 = 0,roundnessWeight1 = 1,
                                        smoothnessRanges0 = 0,smoothnessRanges1 = 1,smoothnessWeight0 = 0,smoothnessWeight1 = 1,
                                        textureID = 1,timeLength = 0.33300000429153});
    local myEffectEvent2 = cameraEffectEvent.createObject({allColorRanges0 = 0,allColorRanges1 = 255,allColorWeight0 = 0,allColorWeight1 = 1,
                                        intensityRanges0 = 0,intensityRanges1 = 1,intensityWeight0 = 0,intensityWeight1 = 1,modeID = 1,
                                        opacityRanges0 = 0,opacityRanges1 = 1,opacityWeight0 = 0,opacityWeight1 = 1,rounded = 0,
                                        roundnessRanges0 = 0,roundnessRanges1 = 1,roundnessWeight0 = 0,roundnessWeight1 = 1,
                                        smoothnessRanges0 = 0,smoothnessRanges1 = 1,smoothnessWeight0 = 0,smoothnessWeight1 = 1,
                                        textureID = 1,timeLength = 0.56499999761581});
    local myEffectEvent3 = cameraEffectEvent.createObject({allColorRanges0 = 0,allColorRanges1 = 255,allColorWeight0 = 0,allColorWeight1 = 1,
                                        intensityRanges0 = 0,intensityRanges1 = 1,intensityWeight0 = 0,intensityWeight1 = 1,modeID = 1,
                                        opacityRanges0 = 0,opacityRanges1 = 1,opacityWeight0 = 0,opacityWeight1 = 1,rounded = 0,
                                        roundnessRanges0 = 0,roundnessRanges1 = 1,roundnessWeight0 = 0,roundnessWeight1 = 1,
                                        smoothnessRanges0 = 0,smoothnessRanges1 = 1,smoothnessWeight0 = 0,smoothnessWeight1 = 1,
                                        textureID = 1,timeLength = 0.1330000013113});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(16.799, myEffectEvent1);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        myEffectTrack:addEvent(17.399, myEffectEvent2);
        myEffectTrack:addEvent(18.2, myEffectEvent3);
    end
    self.playerDirector:addTrack(myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByVignette fail");
        end
    end);
end
function prototype:_createScene()
    local sceneTrack = require("eSkyPlayer/eSkyPlayerSceneTrackData");
    local mySceneTrack = sceneTrack.createObject({stagePath = "stages/stage_03/prefabs/stage_03"});
    self.playerDirector:addTrack(mySceneTrack,function (isLoaded)
        if not isLoaded then
            logError("createScene fail");
        end
    end);
end

function prototype:_createSceneMotionTrack1(beginTime,timeLength)
    local sceneTrack = require("eSkyPlayer/eSkyPlayerSceneTrackData");
    local sceneEvent = require("eSkyPlayer/eSkyPlayerSceneMotionEventData");
    local mySceneTrack = sceneTrack.createObject({stagePath = "stages/stage_01/prefabs/qizi_c"});
    local mySceneEvent1 = sceneEvent.createObject({timeLength = 2.664, beginCut = 0, endCut = 1});
    local mySceneEvent2 = sceneEvent.createObject({timeLength = 5.366, beginCut = 0, endCut = 1});
    local mySceneEvent3 = sceneEvent.createObject({timeLength = 1.332, beginCut = 0, endCut = 1});
    if mySceneTrack ~= nil then
        mySceneTrack:addEvent(0,mySceneEvent1);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        mySceneTrack:addEvent(2.733,mySceneEvent2);
        mySceneTrack:addEvent(8.166,mySceneEvent3);
    end
    self.playerDirector:addTrack(mySceneTrack,function (isLoaded)
        if not isLoaded then
            logError("createSceneMotionTrack1 fail");
        end
    end);
end
function prototype:_createSceneMotionTrack2(beginTime,timeLength)
    local sceneTrack = require("eSkyPlayer/eSkyPlayerSceneTrackData");
    local sceneEvent = require("eSkyPlayer/eSkyPlayerSceneMotionEventData");
    local mySceneTrack = sceneTrack.createObject({stagePath = "effects/prefabs/fx_stage_03_lizi"});
    local mySceneEvent1 = sceneEvent.createObject({timeLength = 0.765, beginCut = 0, endCut = 1});
    local mySceneEvent2 = sceneEvent.createObject({timeLength = 1.332, beginCut = 0, endCut = 1});
    local mySceneEvent3 = sceneEvent.createObject({timeLength = 0.465, beginCut = 0, endCut = 1});
    if mySceneTrack ~= nil then
        mySceneTrack:addEvent(0.133,mySceneEvent1);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        mySceneTrack:addEvent(1.200,mySceneEvent2);
        mySceneTrack:addEvent(3.133,mySceneEvent3);
    end
    self.playerDirector:addTrack(mySceneTrack,function (isLoaded)
        if not isLoaded then
            logError("createSceneMotionTrack2 fail");
        end
    end);
end



return prototype;