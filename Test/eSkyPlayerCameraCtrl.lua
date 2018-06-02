local prototype = class("eSkyPlayerCameraCtrl", mvc.viewCtrl)
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local defination = require("eSkyPlayer/eSkyPlayerDefinations");
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

    -- local itemCodes = {100153 , 100154 , 100155 ,100156 ,100157,100158,100159,100011,100010};
    -- local skeletonUrl = "avatars/biped/man_biped";
    -- local role = G.characterFactory:createTempRole(itemCodes, {}, false, skeletonUrl);
    -- role.onRoleRefreshFinished = function(body, obj, sourceId)
    --     local roleAgent = newClass("eSkyPlayer/eSkyPlayerRoleAgent/eSkyPlayerRoleAgent");
    --     roleAgent:initialize(role);
    --     self.playerDirector:addRole(roleAgent);
        self.playerDirector:initialize(self.camera);
        self.playerDirector:load("mod/projects/0001PVE",function(isLoaded)--mytscene test_role wedding 0001PVE animPlayTest noScene onlyScene cameraEffectP
            if isLoaded == true then
                logError("load success");
            else
                logError("load failed")
            end
        end);

        self:_createTrackAndEvent();
        self:_createScaleAndClip(); 
        self:_createTrackAndEvents();
        self:_eventCallback();
        self:_eventWaitAdd(30);
        self:_replaceEventAdd();
        self:_createSpawn(2, 22, 5, 13);
    -- end;

    -- role:refresh();

end

function prototype:_replaceEventAdd()
    local roleMotionTrack = require("eSkyPlayer/eSkyPlayerRoleMotionTrackData");
    local roleMotionEvent = require("eSkyPlayer/eSkyPlayerRoleMotionEventData");
    local rMotionTrack = roleMotionTrack.createObject({});
    local eMotionEvent = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_006_8", beginTime = -0,
                            endTime = 13, eventLength = 6.5, motionLength = 6.5});
    local eMotionEvent1 = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_007_8", beginTime = -0,
                            endTime = 13, eventLength = 6.5, motionLength = 6.5});
    local eMotionEvent2 = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_008_8", beginTime = -0,
                            endTime = 13, eventLength = 6.5, motionLength = 6.5});
    local eMotionEvent3 = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_009_8", beginTime = -0,
                            endTime = 13, eventLength = 6.5, motionLength = 6.5});
    local eMotionEvent4 = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_010_8", beginTime = -0,
                            endTime = 13, eventLength = 6.5, motionLength = 6.5});
    local eMotionEvent5 = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_011_8", beginTime = -0,
                            endTime = 13, eventLength = 6.5, motionLength = 6.5});
    local eMotionEvent6 = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_012_8", beginTime = -0,
                            endTime = 13, eventLength = 6.5, motionLength = 6.5});
    if rMotionTrack ~= nil then
        rMotionTrack:addEvent(0.5, eMotionEvent, defination.EVENT_ADDTYPE.NORMAL, nil);
        rMotionTrack:addEvent(7.5, eMotionEvent1, defination.EVENT_ADDTYPE.NORMAL, nil);
        rMotionTrack:addEvent(14.5, eMotionEvent2, defination.EVENT_ADDTYPE.NORMAL, nil);
        rMotionTrack:addEvent(21.5, eMotionEvent3, defination.EVENT_ADDTYPE.NORMAL, nil);
        rMotionTrack:addEvent(28.5, eMotionEvent4, defination.EVENT_ADDTYPE.NORMAL, nil);
        rMotionTrack:addEvent(35.5, eMotionEvent5, defination.EVENT_ADDTYPE.NORMAL, nil);
        rMotionTrack:addEvent(43.5, eMotionEvent6, defination.EVENT_ADDTYPE.NORMAL, nil);
    end
    self.playerDirector:addTrack("roleMotionTrackReplace", rMotionTrack, function (isLoaded)
        if not isLoaded then
            logError("add rolemotionTrack fail");
        end
    end);
end

function prototype:_eventCallback()
    local events = self.playerDirector:findEventByTime("cameraMotion_A", 27);
    if events ~= nil then
        local cameraMotionEvent = require("eSkyPlayer/eSkyPlayerCameraMotionEventData");
        local cameraPlayer = self.playerDirector:getPlayerByTrackName("cameraMotion_A");
        assert(cameraPlayer,"cameraMotion_A not find !");
        for i = 1, #events do
            self.playerDirector:addEventCallbackToEvent(events[i],function()
                logError("指定的cameraMotionEvent离开后回调函数开始执行:在60秒处新增了一个cameraMotionEvent时长 22秒");
                local trackType = cameraPlayer.trackObj_:getTrackType();
                local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
                local myMotionEvent = cameraMotionEvent.createObject({beginDrX = 26.718000411987,beginDrY = 247.32800292969,beginDrZ = 0.23700000345707,
                                                beginFrameX = 9.3030004501343, beginFrameY = 6.3340001106262, beginFrameZ = -1.069000005722,
                                                beginLookAtX = 0.48600000143051,beginLookAtY = 1.5230000019073,beginLookAtZ = -4.75,
                                                endDrX = 17.010000228882, endDrY = 213.44700622559, endDrZ = 356.96600341797,
                                                endFrameX = 4.3330001831055, endFrameY = 3.7820000648499, endFrameZ = 5.8480000495911,
                                                endLookAtX = 0.24600000679493, endLookAtY = 1.5160000324249, endLookAtZ = -0.33700001239777,
                                                fov = 60, pos1X = 0.33300000429153, pos1Y = 0.33300000429153,
                                                pos2X = 0.66600000858307, pos2Y = 0, timeLength = 22, tweenType = 0});
                self.playerDirector:changeResourceManagerTactic(myMotionEvent, tacticType);
                cameraPlayer.trackObj_:addEvent(60, myMotionEvent, defination.EVENT_ADDTYPE.NORMAL);

            end, defination.EVENT_PLAYER_STATE.EVENT_END);
        end
    end


    local cameraEffectEvents = self.playerDirector:findEventByTime("camneraEffectBlack_A", 30);
    if cameraEffectEvents ~= nil then
        local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectBlackEventData");
        local cameraEffectPlayer = self.playerDirector:getPlayerByTrackName("camneraEffectBlack_A");
        assert(cameraEffectPlayer,"camneraEffectBlack_A not find !");
        for i = 1, #cameraEffectEvents do
            self.playerDirector:addEventCallbackToEvent(cameraEffectEvents[i],function()
                logError("指定cameraEffectEvent进入后回调函数开始执行: 在61秒处新增了一个cameraEffectEvent,时长:3秒");
                local trackType = cameraEffectPlayer.trackObj_:getTrackType();
                local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
                local eMotionEvent1 = cameraEffectEvent.createObject({blendMode = 1, intensityRanges0 = 0, intensityRanges1 = -3,
                                            intensityWeight0 = 1, intensityWeight1 = 0, textureID = 1, timeLength = 3});
                self.playerDirector:changeResourceManagerTactic(eMotionEvent1, tacticType);
                cameraEffectPlayer.trackObj_:addEvent(61, eMotionEvent1, defination.EVENT_ADDTYPE.NORMAL);

            end, defination.EVENT_PLAYER_STATE.EVENT_START);
        end
    end

    local roleMotionEvents = self.playerDirector:findEventByTime("roleMotionTrack_A", 29.5);
    if roleMotionEvents ~= nil then
        for i = 1, #roleMotionEvents do
            self.playerDirector:addEventCallbackToEvent(roleMotionEvents[i],function()
                -- logError("event EVENT_UPDATE callback");
            end, defination.EVENT_PLAYER_STATE.EVENT_UPDATE);
            self.playerDirector:addEventCallbackToEvent(roleMotionEvents[i],function()
                logError("event EVENT_START callback");
            end, defination.EVENT_PLAYER_STATE.EVENT_START);
            self.playerDirector:addEventCallbackToEvent(roleMotionEvents[i],function()
                logError("event EVENT_END callback");
            end, defination.EVENT_PLAYER_STATE.EVENT_END);
        end
    end
    -----------------测试track callback-----------------------

    local indexA = self.playerDirector:addEventCallbackToTrack("roleMotionTrack_A", function()
            -- logError("track EVENT_UPDATE callback");
    end, defination.EVENT_PLAYER_STATE.EVENT_UPDATE);
    -- self.playerDirector:removeCallback(indexA);
    self.playerDirector:addEventCallbackToTrack("roleMotionTrack_A", function()
            logError("track EVENT_START callback");
    end, defination.EVENT_PLAYER_STATE.EVENT_START);
    self.playerDirector:addEventCallbackToTrack("roleMotionTrack_A", function()
            logError("track EVENT_END callback");
    end, defination.EVENT_PLAYER_STATE.EVENT_END);

end


function prototype:onCameraPlayButtonClicked()
    self.time_ = newClass("eSkyPlayer/eSkyPlayerTimeLine");
    self.isBreakAdd = true;
    if self.playerDirector == nil then
        return;
    end
    if self.playerDirector:play() == true then
        self.view_:setSliderMax(self.playerDirector.timeLength_);
        self.view_:setSliderTouchable(true);
        TimersEx.Add(0, 0, delegate(self, self._scaleAndclip));
    end
---------------------------------------------------

end

function prototype:_autoAddEventByReplace()
    local roleMotionEvent = require("eSkyPlayer/eSkyPlayerRoleMotionEventData");
    local myMotionEvent = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_006_8", beginTime = -0,
                            endTime = 13, eventLength = 6.5, motionLength = 6.5});

    local roleMotionPlayer = self.playerDirector:getPlayerByTrackName("roleMotionTrackReplace");
    assert(roleMotionPlayer,"error: roleMotionTrackReplace not find player !");
    if roleMotionPlayer ~= nil then
        local trackType = roleMotionPlayer.trackObj_:getTrackType();
        local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
        self.playerDirector:changeResourceManagerTactic(myMotionEvent, tacticType);
        local isAdd = roleMotionPlayer.trackObj_:addEvent(7.6, myMotionEvent, defination.EVENT_ADDTYPE.EVENT_REPLACE_MORE_ADD, 1);
        assert(isAdd, "error: addEvent failed!");

        logError("1个替换多个成功");
    end
end

function prototype:_scaleAndclip()
    local time = self.time_:getTime();
    self.time_:setTime(time + Time.deltaTime);
    time = math.ceil(time) - 1;
    if time == 6 and self.isBreakAdd then
        self.isBreakAdd = false;
        self:_autoAddEventByReplace();
    end
    if time == 30 and self.isBreakAdd then
        self.isBreakAdd = false;
        self:_eventBreakAdd(time);
    end
    
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

    if self.playerDirector == nil then 
        return;
    end
    self.playerDirector:stop();

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

--动态创建track和event测试代码
function prototype:_createTrackAndEvent()
    logError("_createTrackAndEvent 开始...");
    self:_createVirtualCamreaMotionTrack_A(2, 40);
    -- self:_createScene();
    -- self:_createSceneAnimEvent_A(27,10);
    -- self:_createSceneEffectEvent_A(27.1, 100);
    -- self:_createVirtualCamreaaEffectTrackByBlackEvent_A(29, 3);
    -- self:_createVirtualCamreaaEffectTrackByBloomEvent_A(29, 3);
    -- self:_createVirtualCameraEffectTrackByCrossFade_A(29, 1);
    -- self:_createVirtualCameraEffectTrackByFieldOfView_A(29, 3);
    -- self:_createVirtualCameraEffectTrackByChromaticAberration_A(29, 3);
    -- self:_createVirtualCameraEffectTrackByDepthOfField_A(29,2);
    -- self:_createVirtualCameraEffectTrackByVignette_A(29.5,1.5);
    -- self:_createRoleMotionTrack_A(29, 6.5); 
    logError("_createTrackAndEvent 结束...");
end

--动态创建track和多个event测试event快1倍放,慢1倍放以及正常播放
function prototype:_createTrackAndEvents()
    logError("创建测试event快放/慢放/正常播放开始...");
    self:_createVirtualCamreaMotionTrack_B(0.5, 22);
    -- self:_createScene();
    self:_createSceneAnimEvent_B();
    self:_createSceneEffectEvent_B();
    self:_createVirtualCamreaaEffectTrackByBlackEvent_B();
    self:_createVirtualCamreaaEffectTrackByBloomEvent_B();
    self:_createVirtualCameraEffectTrackByCrossFade_B();
    self:_createVirtualCameraEffectTrackByFieldOfView_B();
    self:_createVirtualCameraEffectTrackByChromaticAberration_B();
    self:_createVirtualCameraEffectTrackByDepthOfField_B();
    self:_createVirtualCameraEffectTrackByVignette_B();
    self:_createRoleMotionTrack_B();
    logError("创建测试event快放/慢放/正常播放结束...");
end


--event裁剪和缩放测试
function prototype:_createScaleAndClip()
    logError("event裁剪和缩放测试 开始...");
    local isScale = false;
    -- local clipRemainSign = -1;
    local clipRemainSign = 1;
    --beginTime:event开始时间
    --timeLength:event时长
    --isScale:是否缩放true缩放,false裁剪
    --scaleOrclipTime:缩放时长和裁剪时长,根据isScale决定他的含义
    --clipRemainSign:如果是缩放，可忽略；如果是剪裁，作为保留哪边的标志，若<0表示保留左边，>=0保留右边
    self:_createVirtualCamreaMotionTrack(0.5, 22,isScale,11,clipRemainSign);
    self:_createSceneAnimEvent(0.1, 10,isScale,6, clipRemainSign);
    self:_createSceneEffectEvent(0.5,10,isScale,8, clipRemainSign);
    self:_createVirtualCamreaaEffectTrackByBlackEvent(0.5,3,isScale,2,clipRemainSign);
    self:_createVirtualCamreaaEffectTrackByBloomEvent(3.1,3,isScale,1.5,clipRemainSign);
    self:_createVirtualCameraEffectTrackByCrossFade(0.5,3,isScale,1.5,clipRemainSign);
    self:_createVirtualCameraEffectTrackByFieldOfView(1.15, 3,isScale,2,clipRemainSign);
    self:_createVirtualCameraEffectTrackByChromaticAberration(0.6,3,isScale,1.5,clipRemainSign);
    self:_createVirtualCameraEffectTrackByDepthOfField(0.5,3,isScale, 2,clipRemainSign);
    self:_createVirtualCameraEffectTrackByVignette(0.5,3,isScale, 2,clipRemainSign);
    self:_createRoleMotionTrack(1.5,6.5,isScale, 2,clipRemainSign);
    logError("event裁剪和缩放测试 结束...");
end

function prototype:_createVirtualCamreaMotionTrack_A(beginTime, timeLength)
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
        myMotionTrack:addEvent(beginTime, myMotionEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
    end
    self.playerDirector:addTrack("cameraMotion_A", myMotionTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCamreaMotionTrack fail");
        end
    end);
end
function prototype:_createVirtualCamreaMotionTrack_B(beginTime, timeLength)
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
        myMotionTrack:addEvent(beginTime, myMotionEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
    end
    self.playerDirector:addTrack("cameraMotion_B", myMotionTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCamreaMotionTrack fail");
        end
    end);
end
--动态创建相机track中的MotionTrackData
function prototype:_createVirtualCamreaMotionTrack(beginTime,timeLength,isScale,scaleOrclipTime, clipRemainSign)
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
        myMotionTrack:addEvent(beginTime, myMotionEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        self:_scaleOrclipEvent(myMotionEvent, scaleOrclipTime,isScale, clipRemainSign);
    end
    self.playerDirector:addTrack("cameraMotion", myMotionTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCamreaMotionTrack fail");
        end
    end);
end

function prototype:_createVirtualCamreaaEffectTrackByBlackEvent(beginTime,timeLength,isScale,scaleOrclipTime, clipRemainSign)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectBlackEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent = cameraEffectEvent.createObject({blendMode = 1, intensityRanges0 = 0, intensityRanges1 = -3,
                                            intensityWeight0 = 1, intensityWeight1 = 0, textureID = 1, timeLength = timeLength});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(beginTime, myEffectEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        self:_scaleOrclipEvent(myEffectEvent, scaleOrclipTime,isScale, clipRemainSign);
    end
    self.playerDirector:addTrack("camneraEffectBlack", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCamreaaEffectTrackByBlackEvent fail");
        end
    end);
end
function prototype:_createVirtualCamreaaEffectTrackByBlackEvent_A(beginTime,timeLength)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectBlackEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent = cameraEffectEvent.createObject({blendMode = 1, intensityRanges0 = 0, intensityRanges1 = -3,
                                            intensityWeight0 = 1, intensityWeight1 = 0, textureID = 1, timeLength = timeLength});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(beginTime, myEffectEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
    end
    self.playerDirector:addTrack("camneraEffectBlack_A", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCamreaaEffectTrackByBlackEvent fail");
        end
    end);
end
function prototype:_createVirtualCamreaaEffectTrackByBlackEvent_B()
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectBlackEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent1 = cameraEffectEvent.createObject({blendMode = 1, intensityRanges0 = 0, intensityRanges1 = -3,
                                            intensityWeight0 = 1, intensityWeight1 = 0, textureID = 1, timeLength = 0.22});
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
        myEffectTrack:addEvent(0.233, myEffectEvent1, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        myEffectTrack:addEvent(1.033, myEffectEvent2, defination.EVENT_ADDTYPE.NORMAL);
        myEffectTrack:addEvent(2.166, myEffectEvent3, defination.EVENT_ADDTYPE.NORMAL);
        myEffectTrack:addEvent(18.733, myEffectEvent4, defination.EVENT_ADDTYPE.NORMAL);
        myEffectTrack:addEvent(19.5, myEffectEvent5, defination.EVENT_ADDTYPE.NORMAL);
        myEffectTrack:addEvent(20.60, myEffectEvent6, defination.EVENT_ADDTYPE.NORMAL);
    end
    self.playerDirector:addTrack("camneraEffectBlack_B", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCamreaaEffectTrackByBlackEvent fail");
        end
    end);
end
function prototype:_createVirtualCamreaaEffectTrackByBloomEvent(beginTime,timeLength,isScale,scaleOrclipTime, clipRemainSign)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectBloomEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent = cameraEffectEvent.createObject({intensityBloomRanges0 = 0,intensityBloomRanges1 = 1,intensityBloomWeight0 = 0,intensityBloomWeight1 = 300,
                                                intensityRanges0 = 0,intensityRanges1 = 300,intensityWeight0 = 0,intensityWeight1 = 1,
                                                radiusRanges0 = 0,radiusRanges1 = 7,radiusWeight0 = 0,radiusWeight1 = 1,resistBlinking = 0,
                                                softKneeRanges0 = 0,softKneeRanges1 = 1,softKneeWeight0 = 0,softKneeWeight1 = 1,textureID = 1,
                                                thresholdRanges0 = 0,thresholdRanges1 = 1,thresholdWeight0 = 0,thresholdWeight1 = 1,timeLength = timeLength});
   
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(beginTime, myEffectEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        self:_scaleOrclipEvent(myEffectEvent, scaleOrclipTime,isScale, clipRemainSign);
    end
    self.playerDirector:addTrack("cameraEffectBloom", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCamreaaEffectTrackByBloomEvent fail");
        end
    end);
end
function prototype:_createVirtualCamreaaEffectTrackByBloomEvent_A(beginTime,timeLength)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectBloomEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent = cameraEffectEvent.createObject({intensityBloomRanges0 = 0,intensityBloomRanges1 = 1,intensityBloomWeight0 = 0,intensityBloomWeight1 = 300,
                                                intensityRanges0 = 0,intensityRanges1 = 300,intensityWeight0 = 0,intensityWeight1 = 1,
                                                radiusRanges0 = 0,radiusRanges1 = 7,radiusWeight0 = 0,radiusWeight1 = 1,resistBlinking = 0,
                                                softKneeRanges0 = 0,softKneeRanges1 = 1,softKneeWeight0 = 0,softKneeWeight1 = 1,textureID = 1,
                                                thresholdRanges0 = 0,thresholdRanges1 = 1,thresholdWeight0 = 0,thresholdWeight1 = 1,timeLength = timeLength});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(beginTime, myEffectEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
    end
    self.playerDirector:addTrack("cameraEffectBloom_A", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCamreaaEffectTrackByBloomEvent fail");
        end
    end);
end
function prototype:_createVirtualCamreaaEffectTrackByBloomEvent_B()
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectBloomEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent1 = cameraEffectEvent.createObject({intensityBloomRanges0 = 0,intensityBloomRanges1 = 1,intensityBloomWeight0 = 0,intensityBloomWeight1 = 300,
                                                intensityRanges0 = 0,intensityRanges1 = 300,intensityWeight0 = 0,intensityWeight1 = 1,
                                                radiusRanges0 = 0,radiusRanges1 = 7,radiusWeight0 = 0,radiusWeight1 = 1,resistBlinking = 0,
                                                softKneeRanges0 = 0,softKneeRanges1 = 1,softKneeWeight0 = 0,softKneeWeight1 = 1,textureID = 1,
                                                thresholdRanges0 = 0,thresholdRanges1 = 1,thresholdWeight0 = 0,thresholdWeight1 = 1,timeLength = 2});
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
        myEffectTrack:addEvent(2.966, myEffectEvent1, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        myEffectTrack:addEvent(4.066, myEffectEvent2, defination.EVENT_ADDTYPE.NORMAL);
        myEffectTrack:addEvent(5.333, myEffectEvent3, defination.EVENT_ADDTYPE.NORMAL);
    end
    self.playerDirector:addTrack("cameraEffectBloom_B", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCamreaaEffectTrackByBloomEvent fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByCrossFade(beginTime,timeLength,isScale,scaleOrclipTime, clipRemainSign)

    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectCrossFadeEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent = cameraEffectEvent.createObject({alphaFromRanges0 = 1,alphaFromRanges1 = 0,alphaFromWeight0 = 0,
                            alphaFromWeight1 = 1,alphaToRanges0 = 0,alphaToRanges1 = 1,alphaToWeight0 = 0,
                            alphaToWeight1 = 1,timeLength = timeLength});
   
    if myEffectTrack ~= nil then
        self:_scaleOrclipEvent(myEffectEvent, scaleOrclipTime,isScale, clipRemainSign);
        myEffectTrack:addEvent(beginTime, myEffectEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
    end
    self.playerDirector:addTrack("cameraEffectCrossFade", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByCrossFade fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByCrossFade_A(beginTime,timeLength)

    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectCrossFadeEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent = cameraEffectEvent.createObject({alphaFromRanges0 = 1,alphaFromRanges1 = 0,alphaFromWeight0 = 0,
                            alphaFromWeight1 = 1,alphaToRanges0 = 0,alphaToRanges1 = 1,alphaToWeight0 = 0,
                            alphaToWeight1 = 1,timeLength = timeLength});
    
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(beginTime, myEffectEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
    end
    self.playerDirector:addTrack("cameraEffectCrossFade_A", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByCrossFade fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByCrossFade_B()
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectCrossFadeEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent1 = cameraEffectEvent.createObject({alphaFromRanges0 = 1,alphaFromRanges1 = 0,alphaFromWeight0 = 0,
                            alphaFromWeight1 = 1,alphaToRanges0 = 0,alphaToRanges1 = 1,alphaToWeight0 = 0,
                            alphaToWeight1 = 1,timeLength = 2});
    local myEffectEvent2 = cameraEffectEvent.createObject({alphaFromRanges0 = 1,alphaFromRanges1 = 0,
                            alphaFromWeight0 = 0,alphaFromWeight1 = 1,alphaToRanges0 = 0,alphaToRanges1 = 1,
                            alphaToWeight0 = 0,alphaToWeight1 = 1,timeLength = 0.966000020504});
    local myEffectEvent3 = cameraEffectEvent.createObject({alphaFromRanges0 = 1,alphaFromRanges1 = 0,alphaFromWeight0 = 0,
                            alphaFromWeight1 = 1,alphaToRanges0 = 0,alphaToRanges1 = 1,
                            alphaToWeight0 = 0,alphaToWeight1 = 1,timeLength = 0.43200001120567});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(9.233, myEffectEvent1, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        myEffectTrack:addEvent(10.233, myEffectEvent2, defination.EVENT_ADDTYPE.NORMAL);
        myEffectTrack:addEvent(11.5, myEffectEvent3, defination.EVENT_ADDTYPE.NORMAL);
    end
    self.playerDirector:addTrack("cameraEffectCrossFade_B", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByCrossFade fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByFieldOfView(beginTime,timeLength,isScale,scaleOrclipTime, clipRemainSign)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectFieldOfViewEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent = cameraEffectEvent.createObject({fovRanges0 = 1,fovRanges1 = 100,fovWeight0 = 0.2960000038147,
                                        fovWeight1 = 0.2960000038147,timeLength = timeLength});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(beginTime, myEffectEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        self:_scaleOrclipEvent(myEffectEvent, scaleOrclipTime,isScale, clipRemainSign);
    end
    self.playerDirector:addTrack("cameraEffectFieldOfView", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByFieldOfView fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByFieldOfView_A(beginTime,timeLength)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectFieldOfViewEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent = cameraEffectEvent.createObject({fovRanges0 = 1,fovRanges1 = 100,fovWeight0 = 0.2960000038147,
                                        fovWeight1 = 0.2960000038147,timeLength = timeLength});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(beginTime, myEffectEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
    end
    self.playerDirector:addTrack("cameraEffectFieldOfView_A", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByFieldOfView fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByFieldOfView_B()
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectFieldOfViewEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent1 = cameraEffectEvent.createObject({fovRanges0 = 1,fovRanges1 = 100,fovWeight0 = 0.2960000038147,
                                        fovWeight1 = 0.2960000038147,timeLength = 2.33300000429153});
    local myEffectEvent2 = cameraEffectEvent.createObject({fovRanges0 = 1,fovRanges1 = 100,fovWeight0 = 0.2960000038147,
                                        fovWeight1 = 0.2960000038147,timeLength = 0.73199999332428});
    local myEffectEvent3 = cameraEffectEvent.createObject({fovRanges0 = 1,fovRanges1 = 100,fovWeight0 = 0.2960000038147,
                                        fovWeight1 = 0.2960000038147,timeLength = 0.23199999332428});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(14.433, myEffectEvent1, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        myEffectTrack:addEvent(15.1, myEffectEvent2, defination.EVENT_ADDTYPE.NORMAL);
        myEffectTrack:addEvent(16.1, myEffectEvent3, defination.EVENT_ADDTYPE.NORMAL);
    end
    self.playerDirector:addTrack("cameraEffectFieldOfView_B", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByFieldOfView fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByChromaticAberration(beginTime,timeLength,isScale,scaleOrclipTime, clipRemainSign)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectChromaticAberrationEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent = cameraEffectEvent.createObject({intensityRanges0 = 0,intensityRanges1 = 1,intensityWeight0 = 0.7,
                                    intensityWeight1 = 1,textureID = 1,timeLength = timeLength});
   
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(beginTime, myEffectEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        self:_scaleOrclipEvent(myEffectEvent, scaleOrclipTime,isScale, clipRemainSign);
    end
    self.playerDirector:addTrack("cameraChromaticAberration", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByChromaticAberration fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByChromaticAberration_A(beginTime,timeLength)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectChromaticAberrationEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent = cameraEffectEvent.createObject({intensityRanges0 = 0,intensityRanges1 = 1,intensityWeight0 = 0,
                                    intensityWeight1 = 1,textureID = 1,timeLength = timeLength});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(beginTime, myEffectEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
    end
    self.playerDirector:addTrack("cameraChromaticAberration_A", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByChromaticAberration fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByChromaticAberration_B()
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
        myEffectTrack:addEvent(6.333, myEffectEvent1, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        myEffectTrack:addEvent(7.166, myEffectEvent2, defination.EVENT_ADDTYPE.NORMAL);
        myEffectTrack:addEvent(8.433, myEffectEvent3, defination.EVENT_ADDTYPE.NORMAL);
    end
    self.playerDirector:addTrack("cameraChromaticAberration_B", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByChromaticAberration fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByDepthOfField(beginTime,timeLength,isScale,scaleOrclipTime, clipRemainSign)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectDepthOfFieldEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent = cameraEffectEvent.createObject({apertureRanges0 = 0,apertureRanges1 = 15,apertureWeight0 = 1,
                                                            apertureWeight1 = 0,timeLength = timeLength});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(beginTime, myEffectEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        self:_scaleOrclipEvent(myEffectEvent, scaleOrclipTime,isScale, clipRemainSign);
    end
    self.playerDirector:addTrack("cameraDepthOfField", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByDepthOfField fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByDepthOfField_A(beginTime,timeLength)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectDepthOfFieldEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent = cameraEffectEvent.createObject({apertureRanges0 = 0,apertureRanges1 = 15,apertureWeight0 = 1,
                                                            apertureWeight1 = 0,timeLength = timeLength});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(beginTime, myEffectEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
    end
    self.playerDirector:addTrack("cameraDepthOfField_A", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByDepthOfField fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByDepthOfField_B()
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectDepthOfFieldEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent1 = cameraEffectEvent.createObject({apertureRanges0 = 0,apertureRanges1 = 15,apertureWeight0 = 1,
                                                            apertureWeight1 = 0,timeLength = 1});
    local myEffectEvent2 = cameraEffectEvent.createObject({apertureRanges0 = 0,apertureRanges1 = 15,apertureWeight0 = 1,
                                                            apertureWeight1 = 0,timeLength = 0.53200000524521});
    local myEffectEvent3 = cameraEffectEvent.createObject({apertureRanges0 = 0,apertureRanges1 = 15,apertureWeight0 = 1,
                                                            apertureWeight1 = 0,timeLength = 0.2660000026226});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(12.366, myEffectEvent1, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        myEffectTrack:addEvent(12.966, myEffectEvent2, defination.EVENT_ADDTYPE.NORMAL);
        myEffectTrack:addEvent(13.766, myEffectEvent3, defination.EVENT_ADDTYPE.NORMAL);
    end
    self.playerDirector:addTrack("cameraDepthOfField_B", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByDepthOfField fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByVignette(beginTime,timeLength,isScale,scaleOrclipTime, clipRemainSign)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectVignetteEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent = cameraEffectEvent.createObject({allColorRanges0 = 0,allColorRanges1 = 255,allColorWeight0 = 0,allColorWeight1 = 1,
                                        intensityRanges0 = 0,intensityRanges1 = 1,intensityWeight0 = 0,intensityWeight1 = 1,modeID = 1,
                                        opacityRanges0 = 0,opacityRanges1 = 1,opacityWeight0 = 0,opacityWeight1 = 1,rounded = 0,
                                        roundnessRanges0 = 0,roundnessRanges1 = 1,roundnessWeight0 = 0,roundnessWeight1 = 1,
                                        smoothnessRanges0 = 0,smoothnessRanges1 = 1,smoothnessWeight0 = 0,smoothnessWeight1 = 1,
                                        textureID = 1,timeLength = timeLength});
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(beginTime, myEffectEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        self:_scaleOrclipEvent(myEffectEvent, scaleOrclipTime,isScale, clipRemainSign);    
    end
    self.playerDirector:addTrack("cameraEffectVignette", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByVignette fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByVignette_A(beginTime,timeLength)
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectVignetteEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent1 = cameraEffectEvent.createObject({allColorRanges0 = 0,allColorRanges1 = 255,allColorWeight0 = 0,allColorWeight1 = 1,
                                        intensityRanges0 = 0,intensityRanges1 = 1,intensityWeight0 = 0,intensityWeight1 = 1,modeID = 1,
                                        opacityRanges0 = 0,opacityRanges1 = 1,opacityWeight0 = 0,opacityWeight1 = 1,rounded = 0,
                                        roundnessRanges0 = 0,roundnessRanges1 = 1,roundnessWeight0 = 0,roundnessWeight1 = 1,
                                        smoothnessRanges0 = 0,smoothnessRanges1 = 1,smoothnessWeight0 = 0,smoothnessWeight1 = 1,
                                        textureID = 1,timeLength = timeLength});
   
    if myEffectTrack ~= nil then
        myEffectTrack:addEvent(beginTime, myEffectEvent1, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
    end
    self.playerDirector:addTrack("cameraEffectVignette_A", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByVignette fail");
        end
    end);
end
function prototype:_createVirtualCameraEffectTrackByVignette_B()
    local cameraEffectTrack = require("eSkyPlayer/eSkyPlayerCameraEffectTrackData");
    local cameraEffectEvent = require("eSkyPlayer/eSkyPlayerCameraEffectVignetteEventData");
    local myEffectTrack = cameraEffectTrack.createObject({});
    local myEffectEvent1 = cameraEffectEvent.createObject({allColorRanges0 = 0,allColorRanges1 = 255,allColorWeight0 = 0,allColorWeight1 = 1,
                                        intensityRanges0 = 0,intensityRanges1 = 1,intensityWeight0 = 0,intensityWeight1 = 1,modeID = 1,
                                        opacityRanges0 = 0,opacityRanges1 = 1,opacityWeight0 = 0,opacityWeight1 = 1,rounded = 0,
                                        roundnessRanges0 = 0,roundnessRanges1 = 1,roundnessWeight0 = 0,roundnessWeight1 = 1,
                                        smoothnessRanges0 = 0,smoothnessRanges1 = 1,smoothnessWeight0 = 0,smoothnessWeight1 = 1,
                                        textureID = 1,timeLength = 0.33});
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
        myEffectTrack:addEvent(16.27, myEffectEvent1, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        myEffectTrack:addEvent(17.399, myEffectEvent2, defination.EVENT_ADDTYPE.NORMAL);
        myEffectTrack:addEvent(18.2, myEffectEvent3, defination.EVENT_ADDTYPE.NORMAL);
    end
    self.playerDirector:addTrack("cameraEffectVignette_B", myEffectTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCameraEffectTrackByVignette fail");
        end
    end);
end
function prototype:_createScene()
    local sceneTrack = require("eSkyPlayer/eSkyPlayerSceneTrackData");
    local mySceneTrack = sceneTrack.createObject({stagePath = "stages/stage_05/prefabs/stage_05"});
    self.playerDirector:addTrack("s1", mySceneTrack,function (isLoaded)
        if not isLoaded then
            logError("createScene fail");
        end
    end);
end

function prototype:_createSceneAnimEvent(beginTime,timeLength,isScale,scaleOrclipTime, clipRemainSign)
    local sceneTrack = require("eSkyPlayer/eSkyPlayerSceneTrackData");
    local sceneEvent = require("eSkyPlayer/eSkyPlayerSceneMotionEventData");
    local mySceneTrack = sceneTrack.createObject({stagePath = "stages/common/prefabs/qizi_c"});
    local mySceneEvent = sceneEvent.createObject({timeLength = timeLength, beginCut = 0, endCut = 1});
    if mySceneTrack ~= nil then
        mySceneTrack:addEvent(beginTime, mySceneEvent, defination.EVENT_ADDTYPE.NORMAL);
        self:_scaleOrclipEvent(mySceneEvent, scaleOrclipTime,isScale, clipRemainSign);
    end
    self.playerDirector:addTrack("sceneAnim", mySceneTrack,function (isLoaded)
        if not isLoaded then
            logError("createSceneMotionTrack1 fail");
        end
    end);
end
function prototype:_createSceneAnimEvent_A(beginTime,timeLength)
    local sceneTrack = require("eSkyPlayer/eSkyPlayerSceneTrackData");
    local sceneEvent = require("eSkyPlayer/eSkyPlayerSceneMotionEventData");
    local mySceneTrack = sceneTrack.createObject({stagePath = "stages/common/prefabs/qizi_c"});
    local mySceneEvent = sceneEvent.createObject({timeLength = timeLength, beginCut = 0, endCut = 1});
    if mySceneTrack ~= nil then
        mySceneTrack:addEvent(beginTime, mySceneEvent, defination.EVENT_ADDTYPE.NORMAL);
    end
    self.playerDirector:addTrack("sceneAnim_A", mySceneTrack,function (isLoaded)
        if not isLoaded then
            logError("createSceneMotionTrack1 fail");
        end
    end);
end
function prototype:_createSceneAnimEvent_B()
    local sceneTrack = require("eSkyPlayer/eSkyPlayerSceneTrackData");
    local sceneEvent = require("eSkyPlayer/eSkyPlayerSceneMotionEventData");
    local mySceneTrack = sceneTrack.createObject({stagePath = "stages/common/prefabs/qizi_c"});
    local mySceneEvent1 = sceneEvent.createObject({timeLength = 2.664, beginCut = 0, endCut = 1});
    local mySceneEvent2 = sceneEvent.createObject({timeLength = 5.366, beginCut = 0, endCut = 1});
    local mySceneEvent3 = sceneEvent.createObject({timeLength = 1.332, beginCut = 0, endCut = 1});
    if mySceneTrack ~= nil then
        mySceneTrack:addEvent(0, mySceneEvent1, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        mySceneTrack:addEvent(2.733, mySceneEvent2, defination.EVENT_ADDTYPE.NORMAL);
        mySceneTrack:addEvent(8.166,mySceneEvent3, defination.EVENT_ADDTYPE.NORMAL);
    end
    self.playerDirector:addTrack("sceneAnim_B", mySceneTrack,function (isLoaded)
        if not isLoaded then
            logError("createSceneMotionTrack1 fail");
        end
    end);
end
function prototype:_createSceneEffectEvent(beginTime,timeLength,isScale,scaleOrclipTime, clipRemainSign)
    local sceneTrack = require("eSkyPlayer/eSkyPlayerSceneTrackData");
    local sceneEvent = require("eSkyPlayer/eSkyPlayerSceneMotionEventData");
    local mySceneTrack = sceneTrack.createObject({stagePath = "effects/prefabs/fx_stage_03_lizi"});
    local mySceneEvent = sceneEvent.createObject({timeLength = timeLength, beginCut = 0, endCut = 1});
    if mySceneTrack ~= nil then
        mySceneTrack:addEvent(beginTime,mySceneEvent, defination.EVENT_ADDTYPE.NORMAL);
        self:_scaleOrclipEvent(mySceneEvent, scaleOrclipTime,isScale, clipRemainSign);
    end
    self.playerDirector:addTrack("sceneEffect", mySceneTrack,function (isLoaded)
        if not isLoaded then
            logError("createSceneMotionTrack2 fail");
        end
    end);
end
function prototype:_createSceneEffectEvent_A(beginTime,timeLength)
    local sceneTrack = require("eSkyPlayer/eSkyPlayerSceneTrackData");
    local sceneEvent = require("eSkyPlayer/eSkyPlayerSceneMotionEventData");
    local mySceneTrack = sceneTrack.createObject({stagePath = "effects/prefabs/fx_stage_03_lizi"});
    local mySceneEvent = sceneEvent.createObject({timeLength = timeLength, beginCut = 0, endCut = 1});
    if mySceneTrack ~= nil then
        mySceneTrack:addEvent(beginTime,mySceneEvent, defination.EVENT_ADDTYPE.NORMAL);
    end
    self.playerDirector:addTrack("sceneEffect_A", mySceneTrack,function (isLoaded)
        if not isLoaded then
            logError("createSceneMotionTrack2 fail");
        end
    end);
end
function prototype:_createSceneEffectEvent_B()
    local sceneTrack = require("eSkyPlayer/eSkyPlayerSceneTrackData");
    local sceneEvent = require("eSkyPlayer/eSkyPlayerSceneMotionEventData");
    local mySceneTrack = sceneTrack.createObject({stagePath = "effects/prefabs/fx_stage_03_lizi"});
    local mySceneEvent1 = sceneEvent.createObject({timeLength = 0.765, beginCut = 0, endCut = 1});
    local mySceneEvent2 = sceneEvent.createObject({timeLength = 1.332, beginCut = 0, endCut = 1});
    local mySceneEvent3 = sceneEvent.createObject({timeLength = 0.465, beginCut = 0, endCut = 1});
    if mySceneTrack ~= nil then
        mySceneTrack:addEvent(0.133,mySceneEvent1, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
        mySceneTrack:addEvent(1.200,mySceneEvent2, defination.EVENT_ADDTYPE.NORMAL);
        mySceneTrack:addEvent(3.133,mySceneEvent2, defination.EVENT_ADDTYPE.NORMAL);
    end
    self.playerDirector:addTrack("sceneEffect_B", mySceneTrack,function (isLoaded)
        if not isLoaded then
            logError("createSceneMotionTrack2 fail");
        end
    end);
end
function prototype:_createRoleMotionTrack(beginTime,timeLength,isScale,scaleOrclipTime, clipRemainSign)
    local roleMotionTrack = require("eSkyPlayer/eSkyPlayerRoleMotionTrackData");
    local roleMotionEvent = require("eSkyPlayer/eSkyPlayerRoleMotionEventData");
    local rMotionTrack = roleMotionTrack.createObject({});
    local eMotionEvent = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_006_8", beginTime = -0,
                            endTime = 6.5, eventLength = timeLength, motionLength = 6.5});
    if rMotionTrack ~= nil then
        rMotionTrack:addEvent(beginTime, eMotionEvent, defination.EVENT_ADDTYPE.NORMAL, nil);
        self:_scaleOrclipEvent(eMotionEvent, scaleOrclipTime,isScale, clipRemainSign);
        self:_scaleOrclipEvent(eMotionEvent, scaleOrclipTime,true);
        self:_scaleOrclipEvent(eMotionEvent, scaleOrclipTime,isScale, clipRemainSign);
    end
    self.playerDirector:addTrack("roleMotionTrack", rMotionTrack, function (isLoaded)
        if not isLoaded then
            logError("add rolemotionTrack fail");
        end
    end, 1);
end
function prototype:_createRoleMotionTrack_A(beginTime, timeLength)
    local roleMotionTrack = require("eSkyPlayer/eSkyPlayerRoleMotionTrackData");
    local roleMotionEvent = require("eSkyPlayer/eSkyPlayerRoleMotionEventData");
    local rMotionTrack = roleMotionTrack.createObject({});
    local eMotionEvent = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_006_8", beginTime = -0,
                            endTime = 13, eventLength = timeLength, motionLength = 6.5});
    if rMotionTrack ~= nil then
        rMotionTrack:addEvent(beginTime, eMotionEvent, defination.EVENT_ADDTYPE.NORMAL, nil);
    end
    self.playerDirector:addTrack("roleMotionTrack_A", rMotionTrack, function (isLoaded)
        if not isLoaded then
            logError("add rolemotionTrack fail");
        end
    end, 1);
end
function prototype:_createRoleMotionTrack_B()
    local roleMotionTrack = require("eSkyPlayer/eSkyPlayerRoleMotionTrackData");
    local roleMotionEvent = require("eSkyPlayer/eSkyPlayerRoleMotionEventData");
    local rMotionTrack = roleMotionTrack.createObject({});
    local eMotionEvent1 = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_006_8", beginTime = -0,
                            endTime = 13, eventLength = 6.5, motionLength = 6.5});
    local eMotionEvent2 = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_006_8", beginTime = -0,
                            endTime = 13, eventLength = 13, motionLength = 6.5});
    local eMotionEvent3 = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_006_8", beginTime = -0,
                            endTime = 13, eventLength = 3, motionLength = 6.5});
    if rMotionTrack ~= nil then
        rMotionTrack:addEvent(0.5, eMotionEvent1, defination.EVENT_ADDTYPE.NORMAL, nil);
        rMotionTrack:addEvent(0.5, eMotionEvent2, defination.EVENT_ADDTYPE.NORMAL, nil);
        rMotionTrack:addEvent(0.5, eMotionEvent3, defination.EVENT_ADDTYPE.NORMAL, nil);
    end
    self.playerDirector:addTrack("roleMotionTrack_B", rMotionTrack, function (isLoaded)
        if not isLoaded then
            logError("add rolemotionTrack fail");
        end
    end, 1);
end

function prototype:_eventBreakAdd(time)
    logError("执行中断evnet,并插入新的event");
        ---------------动态中断动作测试代码-----------------
    -- local roleMotionEvent = require("eSkyPlayer/eSkyPlayerRoleMotionEventData");
    -- local eMontionEvent = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_006_8", beginTime = - 0,
    -- endTime = 6.5, eventLength = 6.5, motionLength = 6.5});
    
    -- local player = self.playerDirector:getPlayerByTrackName("roleMotionTrack_A");--2_动作_1/9_动作_1 roleMotionTrack_D
    -- assert(player,"roleMotionTrack_A:  not find player !");
    -- if player ~= nil then
    --     local trackType = player.trackObj_:getTrackType();
    --     local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
    --     self.playerDirector:changeResourceManagerTactic(eMontionEvent, tacticType);
    --     local isAdd = player.trackObj_:addEvent(time, eMontionEvent, defination.EVENT_ADDTYPE.EVENT_BREAK_ADD);
    --     assert(isAdd, "error: addEvent failed!");
    --     -- self.playerDirector.timeLine_
    -- end
    --------------动态中断相机移动测试代码----------------
    local cameraMotionEvent = require("eSkyPlayer/eSkyPlayerCameraMotionEventData");
    local myMotionEvent = cameraMotionEvent.createObject({beginDrX = 26.718000411987,beginDrY = 247.32800292969,beginDrZ = 0.23700000345707,
                                                beginFrameX = 9.3030004501343, beginFrameY = 6.3340001106262, beginFrameZ = -1.069000005722,
                                                beginLookAtX = 0.48600000143051,beginLookAtY = 1.5230000019073,beginLookAtZ = -4.75,
                                                endDrX = 17.010000228882, endDrY = 213.44700622559, endDrZ = 356.96600341797,
                                                endFrameX = 4.3330001831055, endFrameY = 3.7820000648499, endFrameZ = 5.8480000495911,
                                                endLookAtX = 0.24600000679493, endLookAtY = 1.5160000324249, endLookAtZ = -0.33700001239777,
                                                fov = 60, pos1X = 0.33300000429153, pos1Y = 0.33300000429153,
                                                pos2X = 0.66600000858307, pos2Y = 0, timeLength = 22, tweenType = 0});

    local cameraPlayer = self.playerDirector:getPlayerByTrackName("cameraMotion_A");
    assert(cameraPlayer,"error: cameraMotion_A not find player !");
    if cameraPlayer ~= nil then
        local trackType = cameraPlayer.trackObj_:getTrackType();
        local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
        self.playerDirector:changeResourceManagerTactic(myMotionEvent, tacticType);
        local isAdd = cameraPlayer.trackObj_:addEvent(time, myMotionEvent, defination.EVENT_ADDTYPE.EVENT_BREAK_ADD);
        assert(isAdd, "error: addEvent failed!");
    end
    --self.playerDirector.timeLine_
    --------------动态中断场景动画测试代码----------------
    local sceneEvent = require("eSkyPlayer/eSkyPlayerSceneMotionEventData");
    local mySceneEvent = sceneEvent.createObject({timeLength = 1.332, beginCut = 0, endCut = 1});
    local scenePlayer = self.playerDirector:getPlayerByTrackName("sceneAnim_A");
    assert(scenePlayer,"sceneAnim_A: not find player !")
    local trackType = scenePlayer.trackObj_:getTrackType();
    local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
    self.playerDirector:changeResourceManagerTactic(mySceneEvent, tacticType);
    local isAdd = scenePlayer.trackObj_:addEvent(time, mySceneEvent, defination.EVENT_ADDTYPE.EVENT_BREAK_ADD);
    assert(isAdd, "error: addEvent failed!");
    --self.playerDirector.timeLine_
    --------------动态中断相机特效Black测试代码----------------
    local cameraEffectBlack = require("eSkyPlayer/eSkyPlayerCameraEffectBlackEventData");
    local blackEvent = cameraEffectBlack.createObject({blendMode = 1, intensityRanges0 = 0, intensityRanges1 = -3,
                                            intensityWeight0 = 1, intensityWeight1 = 0, textureID = 1, timeLength = 0.5});
    local cameraPlayer = self.playerDirector:getPlayerByTrackName("camneraEffectBlack_A");
    assert(cameraPlayer,"cameraPlayer not find !");
    local trackType = cameraPlayer.trackObj_:getTrackType();
    local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
    self.playerDirector:changeResourceManagerTactic(blackEvent, tacticType);
    local isAdd = cameraPlayer.trackObj_:addEvent(time, blackEvent, defination.EVENT_ADDTYPE.EVENT_BREAK_ADD);
    assert(isAdd, "error: addCameraBlackEvent failed !");
    --self.playerDirector.timeLine_
    --------------动态中断相机特效Bloom测试代码----------------
    local cameraEffectBloom = require("eSkyPlayer/eSkyPlayerCameraEffectBloomEventData");
    local bloomEvent = cameraEffectBloom.createObject({intensityBloomRanges0 = 0,intensityBloomRanges1 = 1,intensityBloomWeight0 = 0,intensityBloomWeight1 = 300,
                                                intensityRanges0 = 0,intensityRanges1 = 300,intensityWeight0 = 0,intensityWeight1 = 1,
                                                radiusRanges0 = 0,radiusRanges1 = 7,radiusWeight0 = 0,radiusWeight1 = 1,resistBlinking = 0,
                                                softKneeRanges0 = 0,softKneeRanges1 = 1,softKneeWeight0 = 0,softKneeWeight1 = 1, textureID = 1,
                                                thresholdRanges0 = 0,thresholdRanges1 = 1,thresholdWeight0 = 0,thresholdWeight1 = 1,timeLength = 0.46500000357628});
    local cameraPlayer = self.playerDirector:getPlayerByTrackName("cameraEffectBloom_A");
    assert(cameraPlayer,"cameraEffectBloom_A not find !");
    local trackType = cameraPlayer.trackObj_:getTrackType();
    local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
    self.playerDirector:changeResourceManagerTactic(bloomEvent, tacticType);
    local isAdd = cameraPlayer.trackObj_:addEvent(time, bloomEvent, defination.EVENT_ADDTYPE.EVENT_BREAK_ADD);
    assert(isAdd, "error: addCamerabloomEvent failed !");
    --self.playerDirector.timeLine_
    --------------动态中断相机特效CrossFade测试代码----------------
    local cameraEffectCrossFade = require("eSkyPlayer/eSkyPlayerCameraEffectCrossFadeEventData");
    local crossFadeEvent = cameraEffectCrossFade.createObject({alphaFromRanges0 = 1,alphaFromRanges1 = 0,alphaFromWeight0 = 0,
                            alphaFromWeight1 = 1,alphaToRanges0 = 0,alphaToRanges1 = 1,alphaToWeight0 = 0,
                            alphaToWeight1 = 1,timeLength = 2});
    local cameraPlayer = self.playerDirector:getPlayerByTrackName("cameraEffectCrossFade_A");
    assert(cameraPlayer,"cameraEffectCrossFade_A not find !");
    local trackType = cameraPlayer.trackObj_:getTrackType();
    local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
    self.playerDirector:changeResourceManagerTactic(crossFadeEvent, tacticType);
    local isAdd = cameraPlayer.trackObj_:addEvent(time, crossFadeEvent, defination.EVENT_ADDTYPE.EVENT_BREAK_ADD);
    assert(isAdd, "error: addCameraCrossFadeEvent failed !");
    --self.playerDirector.timeLine_
    --------------动态中断相机特效FieldOfView测试代码----------------
    local cameraFieldOfView = require("eSkyPlayer/eSkyPlayerCameraEffectFieldOfViewEventData");
    local fieldOfViewEvent = cameraFieldOfView.createObject({fovRanges0 = 1,fovRanges1 = 100,fovWeight0 = 0.2960000038147,
                                        fovWeight1 = 0.2960000038147,timeLength = 1.33300000429153});
    assert(fieldOfViewEvent,"error: fieldOfViewEvent failed !");
    local cameraPlayer = self.playerDirector:getPlayerByTrackName("cameraEffectFieldOfView_A");
    assert(cameraPlayer,"cameraEffectFieldOfView_A not find !");
    local trackType = cameraPlayer.trackObj_:getTrackType();
    local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
    self.playerDirector:changeResourceManagerTactic(fieldOfViewEvent, tacticType);
    local isAdd = cameraPlayer.trackObj_:addEvent(time, fieldOfViewEvent, defination.EVENT_ADDTYPE.EVENT_BREAK_ADD);
    assert(isAdd, "error: addCameraieldOfViewEvent failed !");
    --self.playerDirector.timeLine_
    --------------动态中断相机特效ChromaticAberration测试代码----------------
    local cameraChromaticAberration = require("eSkyPlayer/eSkyPlayerCameraEffectChromaticAberrationEventData");
    local chromaticAberration = cameraChromaticAberration.createObject({intensityRanges0 = 0,intensityRanges1 = 1,intensityWeight0 = 0,
                                    intensityWeight1 = 1,textureID = 1,timeLength = 0.56499999761581});
    assert(chromaticAberration,"error: chromaticAberration failed !");
    local cameraPlayer = self.playerDirector:getPlayerByTrackName("cameraChromaticAberration_A");
    assert(cameraPlayer,"cameraChromaticAberration_A not find !");
     local trackType = cameraPlayer.trackObj_:getTrackType();
    local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
    self.playerDirector:changeResourceManagerTactic(chromaticAberration, tacticType);
    local isAdd = cameraPlayer.trackObj_:addEvent(time, chromaticAberration, defination.EVENT_ADDTYPE.EVENT_BREAK_ADD);
    assert(isAdd, "error: addCameraieldOfViewEvent failed !");
    -- self.playerDirector.timeLine_
    --------------动态中断相机特效DepthOfField测试代码----------------
    local cameraDepthOfField = require("eSkyPlayer/eSkyPlayerCameraEffectDepthOfFieldEventData");
    local depthOfField = cameraDepthOfField.createObject({apertureRanges0 = 0,apertureRanges1 = 15,apertureWeight0 = 1,
                                                            apertureWeight1 = 0,timeLength = 5});
    assert(depthOfField,"error: depthOfField failed !");
    local cameraPlayer = self.playerDirector:getPlayerByTrackName("cameraDepthOfField_A");
    assert(cameraPlayer,"cameraDepthOfField_A not find !");
    local trackType = cameraPlayer.trackObj_:getTrackType();
    local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
    self.playerDirector:changeResourceManagerTactic(depthOfField, tacticType);
    local isAdd = cameraPlayer.trackObj_:addEvent(time, depthOfField, defination.EVENT_ADDTYPE.EVENT_BREAK_ADD);
    assert(isAdd, "error: addCameraieldOfViewEvent failed !");
    -- self.playerDirector.timeLine_
    --------------动态中断相机特效Vignette测试代码----------------
    local cameraVignette = require("eSkyPlayer/eSkyPlayerCameraEffectVignetteEventData");
    local vignette = cameraVignette.createObject({allColorRanges0 = 0,allColorRanges1 = 255,allColorWeight0 = 0,allColorWeight1 = 1,
                                        intensityRanges0 = 0,intensityRanges1 = 1,intensityWeight0 = 0,intensityWeight1 = 1,modeID = 1,
                                        opacityRanges0 = 0,opacityRanges1 = 1,opacityWeight0 = 0,opacityWeight1 = 1,rounded = 0,
                                        roundnessRanges0 = 0,roundnessRanges1 = 1,roundnessWeight0 = 0,roundnessWeight1 = 1,
                                        smoothnessRanges0 = 0,smoothnessRanges1 = 1,smoothnessWeight0 = 0,smoothnessWeight1 = 1,
                                        textureID = 1,timeLength = 0.33300000429153});
    assert(vignette,"error: vignette failed !");
     local cameraPlayer = self.playerDirector:getPlayerByTrackName("cameraEffectVignette_A");
    assert(cameraPlayer,"cameraEffectVignette_A not find !");
    local trackType = cameraPlayer.trackObj_:getTrackType();
    local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
    self.playerDirector:changeResourceManagerTactic(vignette, tacticType);
    local isAdd = cameraPlayer.trackObj_:addEvent(time, vignette, defination.EVENT_ADDTYPE.EVENT_BREAK_ADD);
    assert(isAdd, "error: vignette failed !");
    -- self.playerDirector.timeLine_
end

function prototype:_eventWaitAdd(time)
    local roleMotionEvent = require("eSkyPlayer/eSkyPlayerRoleMotionEventData");
    local eMontionEvent = roleMotionEvent.createObject({motionFilename = "dance/huiguniang/huiguniang_74_008_8", beginTime = - 0,
    endTime = 6.5, eventLength = 6.5, motionLength = 6.5});
    
    local player = self.playerDirector:getPlayerByTrackName("roleMotionTrack_A");--2_动作_1/9_动作_1 roleMotionTrack_D
    assert(player,"roleMotionTrack_A:  not find player !");
    if player ~= nil then
        local trackType = player.trackObj_:getTrackType();
        local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
        self.playerDirector:changeResourceManagerTactic(eMontionEvent, tacticType);
        local isAdd = player.trackObj_:addEvent(time, eMontionEvent, defination.EVENT_ADDTYPE.EVENT_LAST_ADD);
        assert(isAdd, "error: addEvent failed!");
        logError("动作event等待添加测试");
    end
    --------------动态等待添加相机特效Vignette测试代码----------------
    local cameraVignette = require("eSkyPlayer/eSkyPlayerCameraEffectVignetteEventData");
    local vignette = cameraVignette.createObject({allColorRanges0 = 0,allColorRanges1 = 255,allColorWeight0 = 0,allColorWeight1 = 1,
                                        intensityRanges0 = 0,intensityRanges1 = 1,intensityWeight0 = 0,intensityWeight1 = 1,modeID = 1,
                                        opacityRanges0 = 0,opacityRanges1 = 1,opacityWeight0 = 0,opacityWeight1 = 1,rounded = 0,
                                        roundnessRanges0 = 0,roundnessRanges1 = 1,roundnessWeight0 = 0,roundnessWeight1 = 1,
                                        smoothnessRanges0 = 0,smoothnessRanges1 = 1,smoothnessWeight0 = 0,smoothnessWeight1 = 1,
                                        textureID = 1,timeLength = 0.33300000429153});
    assert(vignette,"error: vignette failed !");
     local cameraPlayer = self.playerDirector:getPlayerByTrackName("cameraEffectVignette_A");
    assert(cameraPlayer,"cameraEffectVignette_A not find !");
    local trackType = cameraPlayer.trackObj_:getTrackType();
    local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
    self.playerDirector:changeResourceManagerTactic(vignette, tacticType);
    local isAdd = cameraPlayer.trackObj_:addEvent(time, vignette, defination.EVENT_ADDTYPE.EVENT_LAST_ADD);
    assert(isAdd, "error: vignette failed !");
    logError("相机aEffectVignetteEvent等待添加测试");
        --------------动态等待添加相机特效DepthOfField测试代码----------------
    local cameraDepthOfField = require("eSkyPlayer/eSkyPlayerCameraEffectDepthOfFieldEventData");
    local depthOfField = cameraDepthOfField.createObject({apertureRanges0 = 0,apertureRanges1 = 15,apertureWeight0 = 1,
                                                            apertureWeight1 = 0,timeLength = 5});
    assert(depthOfField,"error: depthOfField failed !");
    local cameraPlayer = self.playerDirector:getPlayerByTrackName("cameraDepthOfField_A");
    assert(cameraPlayer,"cameraDepthOfField_A not find !");
    local trackType = cameraPlayer.trackObj_:getTrackType();
    local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);
    self.playerDirector:changeResourceManagerTactic(depthOfField, tacticType);
    local isAdd = cameraPlayer.trackObj_:addEvent(time, depthOfField, defination.EVENT_ADDTYPE.EVENT_BREAK_ADD);
    assert(isAdd, "error: addCameraieldOfViewEvent failed !");
    logError("相机DepthOfField等待添加测试");

end

function prototype:_createSpawn(beginTime, timeLength, beginCut, endCut)
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
        local event = myMotionEvent:spawn(beginCut, endCut)
        myMotionTrack:addEvent(beginTime, event, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
    end
    self.playerDirector:addTrack("cameraMotion", myMotionTrack,function (isLoaded)
        if not isLoaded then
            logError("createVirtualCamreaMotionTrack fail");
        end
    end);
end

function prototype:_scaleOrclipEvent(event, time, isScale, clipRemainSign)
    if isScale then
        event:scaleEvent(2);
    else
        event:clipEvent(time, clipRemainSign);
    end
    
end

function prototype:_orderPlayerEvent()
    local events = {};
    local cameraEffectCrossFade = require("eSkyPlayer/eSkyPlayerCameraEffectCrossFadeEventData");
    local crossFadeEvent1 = cameraEffectCrossFade.createObject({alphaFromRanges0 = 1,alphaFromRanges1 = 0,alphaFromWeight0 = 0,
                            alphaFromWeight1 = 1,alphaToRanges0 = 0,alphaToRanges1 = 1,alphaToWeight0 = 0,
                            alphaToWeight1 = 1,timeLength = 2});
    local crossFadeEvent2 = cameraEffectCrossFade.createObject({alphaFromRanges0 = 1,alphaFromRanges1 = 0,alphaFromWeight0 = 0,
                            alphaFromWeight1 = 1,alphaToRanges0 = 0,alphaToRanges1 = 1,alphaToWeight0 = 0,
                            alphaToWeight1 = 1,timeLength = 2});
    local crossFadeEvent3 = cameraEffectCrossFade.createObject({alphaFromRanges0 = 1,alphaFromRanges1 = 0,alphaFromWeight0 = 0,
                            alphaFromWeight1 = 1,alphaToRanges0 = 0,alphaToRanges1 = 1,alphaToWeight0 = 0,
                            alphaToWeight1 = 1,timeLength = 2});
    local crossFadeEvent4 = cameraEffectCrossFade.createObject({alphaFromRanges0 = 1,alphaFromRanges1 = 0,alphaFromWeight0 = 0,
                            alphaFromWeight1 = 1,alphaToRanges0 = 0,alphaToRanges1 = 1,alphaToWeight0 = 0,
                            alphaToWeight1 = 1,timeLength = 2});
    local crossFadeEvent5 = cameraEffectCrossFade.createObject({alphaFromRanges0 = 1,alphaFromRanges1 = 0,alphaFromWeight0 = 0,
                            alphaFromWeight1 = 1,alphaToRanges0 = 0,alphaToRanges1 = 1,alphaToWeight0 = 0,
                            alphaToWeight1 = 1,timeLength = 2});
    events[#events + 1] = crossFadeEvent1;
    events[#events + 1] = crossFadeEvent2;
    events[#events + 1] = crossFadeEvent3;
    events[#events + 1] = crossFadeEvent4;
    events[#events + 1] = crossFadeEvent5;


    
    local cameraPlayer = self.playerDirector:getPlayerByTrackName("cameraEffectCrossFade_A");
    assert(cameraPlayer,"cameraEffectCrossFade_A not find !");
    local trackType = cameraPlayer.trackObj_:getTrackType();
    local tacticType = self.playerDirector:_getTacticTypeByTrackType(trackType);

    self.playerDirector:changeResourceManagerTactic(events[index], tacticType);

    -- local isAdd = cameraPlayer.trackObj_:addEvent(self.playerDirector.timeLine_, events[index], defination.EVENT_ADDTYPE.NORMAL);

    -- if myMotionTrack ~= nil then
    --     myMotionTrack:addEvent(beginTime, myMotionEvent, defination.EVENT_ADDTYPE.NORMAL);--第一个参数表示开始时间,即event在track中的开始位置,第2个参数是event所需具体信息
    -- end

end

return prototype;