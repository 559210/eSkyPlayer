local prototype = class("eSkyPlayerCameraEffectPlayer",require "eSkyPlayer/eSkyPlayerBase");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor(director)
    prototype.super.ctor(self, director);
    self.mainCamera_ = director.camera_;
    self.playingEvent_ = nil;
    self.cameraEffectManager_ = director.cameraEffectManager_;
    self.param_ = nil;
    self.additionalCamera_ = nil;
    self.isEventPlaying_ = false;
    self.effectId_ = -1;
    self.cameras_ = director:getCameras(); --考虑到fov需要赋值给哪几个camera；
                                           --由于现在camera的event保存数据中的fov_值废弃不用了，由cameraEffect里的fov特效来决定camera的fov，暂定每遇到fov的event就遍历所有camera并赋值；
                                           --TODO:以后恢复cameraMotionEventData中存储的fov的用途，由自身保存的数据来决定camera的fov值，废弃fov的特效
    -- self.xxx = {
    --     definations.CAMERA_EFFECT_TYPE.BLOOM : {
    --         "creator" : prototype._createBlackEffect,
    --         "update" : prototype._updatexxxx,
    --     },
    -- }

    -- self.xxx[eventObj.eventData_.motionType_].creator(self, xksa);
end


function prototype:initialize(trackObj)
    self.effectId_ = -1;
    if prototype.super.initialize(self, trackObj) == true then
        self:_isNeedAdditionalCamera();
        return true;
    else
        return false;
    end
end


function prototype:play()
    if self.trackObj_ == nil  then
        return false; 
    end
    if self.mainCamera_ == nil then
        return false;
    end
    prototype.super.play(self);
    return true;
end


function prototype:stop()
    return true;
end


function prototype:isNeedAdditionalCamera()
    return self.isNeedAdditionalCamera_;
end


function prototype:setAdditionalCamera(camera)
    self.additionalCamera_ = camera;
end


function prototype:_isNeedAdditionalCamera()
    if self.trackObj_:isNeedAdditionalCamera() == true then
        self.isNeedAdditionalCamera_ = true;
    else 
        self.isNeedAdditionalCamera_ = false;
    end
end


function prototype:onEventEntered(eventObj, beginTime)
    local eventType = eventObj.eventType_;

    if eventType == definations.EVENT_TYPE.CAMERA_EFFECT_BLOOM then
        self.param_ = self:_createBloomEffect(eventObj);
    elseif eventType == definations.EVENT_TYPE.CAMERA_EFFECT_CHROMATIC_ABERRATION then
        self.param_ = self:_createChromaticAberrationEffect(eventObj);
    elseif eventType == definations.EVENT_TYPE.CAMERA_EFFECT_DEPTH_OF_FIELD then
        self.param_ = self:_createDepthOfFieldEffect(eventObj);
    elseif eventType == definations.EVENT_TYPE.CAMERA_EFFECT_VIGNETTE then
        self.param_ = self:_createVignetteEffect(eventObj);
    elseif eventType == definations.EVENT_TYPE.CAMERA_EFFECT_BLACK then
        self.param_ = self:_createBlackEffect(eventObj);
    elseif eventType == definations.EVENT_TYPE.CAMERA_EFFECT_CROSS_FADE then
        self.param_ = self:_createCrossFadeEffect(eventObj);
    end
end


function prototype:onEventLeft(eventObj)
    if eventObj.eventData_.motionType_ == definations.CAMERA_EFFECT_TYPE.FIELD_OF_VIEW then
        for i = 1, #self.cameras_ do
            self.cameras_[i].fieldOfView = 60;
        end
    else

        self.cameraEffectManager_:destroy(self.effectId_);
    end
end


function prototype:_update()
    self.base:_update();
    -- assert(#self.playingEvents_ < 2, "error: cameraEffect play failed!"); -- 如果正在播放的event不止一个，则报错(cameraEffect的event不允许重叠);

    for i = 1, #self.playingEvents_ do
        local beginTime = self.playingEvents_[i].beginTime_;
        local eventObj = self.playingEvents_[i].obj_;
        local motionType = eventObj.eventData_.motionType_;

        if motionType == definations.CAMERA_EFFECT_TYPE.BLOOM then
            self:_updateBloomEffect(eventObj, self.param_, beginTime);
        elseif motionType == definations.CAMERA_EFFECT_TYPE.CHROMATIC_ABERRATION then
            self:_updateChromaticAberrationEffect(eventObj, self.param_, beginTime);
        elseif motionType == definations.CAMERA_EFFECT_TYPE.DEPTH_OF_FIELD then
            self:_updateDepthOfFieldEffect(eventObj, self.param_, beginTime);
        elseif motionType == definations.CAMERA_EFFECT_TYPE.VIGNETTE then
            self:_updateVignetteEffect(eventObj, self.param_, beginTime);
        elseif motionType == definations.CAMERA_EFFECT_TYPE.BLACK then
            self:_updateBlackEffect(eventObj, self.param_, beginTime);
        elseif motionType == definations.CAMERA_EFFECT_TYPE.CROSS_FADE then
            self:_updateCrossFadeEffect(eventObj, self.param_, beginTime);
        elseif motionType == definations.CAMERA_EFFECT_TYPE.FIELD_OF_VIEW then
            self:_updateFieldOfViewEffect(eventObj, beginTime);
        end
    end 
end


function prototype:_createBloomEffect(eventObj)
    self.effectId_= self.cameraEffectManager_:createBloomEffect();
    self.cameraEffectManager_:start(self.effectId_);
    local param = self.cameraEffectManager_:getParam(self.effectId_);
    param.antiFlicker = misc.getBoolByByte(eventObj.eventData_.antiFlicker);
    param.lenDirtTexture = self:getResource(eventObj, eventObj.texturePath_);
    return param;
end


function prototype:_updateBloomEffect(eventObj, param, beginTime)
    if eventObj == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / eventObj.eventData_.timeLength_ ;
    local names = {"intensity", "threshold", "softKnee", "radius", "antiFlicker", "intensityBloom", "textureBloom"};
    for _, name in ipairs(names) do
        if name == "intensityBloom" then
            param.lenDirtIntensity = eventObj.eventData_[name].values[1] + deltaTime * (eventObj.eventData_[name].values[2] - eventObj.eventData_[name].values[1]);
        elseif name ~= "antiFlicker" and name ~= "textureBloom" then
            param[name] = eventObj.eventData_[name].values[1] + deltaTime * (eventObj.eventData_[name].values[2] - eventObj.eventData_[name].values[1]);
        end
    end

    self.cameraEffectManager_:setParam(self.effectId_,param);
end


function prototype:_createChromaticAberrationEffect(eventObj)
    self.effectId_ = self.cameraEffectManager_:createChromaticAberrationEffect();
    self.cameraEffectManager_:start(self.effectId_);
    local param = self.cameraEffectManager_:getParam(self.effectId_);
    param.spectralTexture = self:getResource(eventObj, eventObj.texturePath_);
    return param;
end


function prototype:_updateChromaticAberrationEffect(eventObj, param, beginTime)
    if eventObj == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / eventObj.eventData_.timeLength_ ;
    local names = {"intensity", "spectralTexture"};
    param.intensity = eventObj.eventData_.intensity.values[1] + deltaTime * (eventObj.eventData_.intensity.values[2] - eventObj.eventData_.intensity.values[1]);

    self.cameraEffectManager_:setParam(self.effectId_,param);
end


function prototype:_createDepthOfFieldEffect(eventObj)
    self.effectId_ = self.cameraEffectManager_:createDepthOfFieldEffect();
    self.cameraEffectManager_:start(self.effectId_);
    local param = self.cameraEffectManager_:getParam(self.effectId_);

    return param; 
end


function prototype:_updateDepthOfFieldEffect(eventObj, param, beginTime)
    if eventObj == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / eventObj.eventData_.timeLength_ ;
    local names = {"aperture"};
    param.aperture = eventObj.eventData_.aperture.values[1] + deltaTime * (eventObj.eventData_.aperture.values[2] - eventObj.eventData_.aperture.values[1]);

    self.cameraEffectManager_:setParam(self.effectId_,param);
end


function prototype:_createVignetteEffect(eventObj)
    self.effectId_ = self.cameraEffectManager_:createVignetteEffect();
    self.cameraEffectManager_:start(self.effectId_);
    local param = self.cameraEffectManager_:getParam(self.effectId_);
    param.mode = eventObj.eventData_.mode - 1;
    param.rounded = misc.getBoolByByte(eventObj.eventData_.rounded);
    param.mask = self:getResource(eventObj, eventObj.texturePath_);
    return param; 
end


function prototype:_updateVignetteEffect(eventObj, param, beginTime)
    if eventObj == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / eventObj.eventData_.timeLength_ ;
    local names = {"mode", "allColor", "intensity", "smoothness", "roundness", "mask", "opacity", "rounded"};
    for _, name in ipairs(names) do
        if name == "allColor" then
            local allColor = eventObj.eventData_[name].values[1] + deltaTime * (eventObj.eventData_[name].values[2] - eventObj.eventData_[name].values[1]);
            local _color = Color.New();
            _color.r = allColor / 255;
            _color.g = allColor / 255;
            _color.b = allColor / 255;
            param.color = _color;
        elseif name ~= "mode" and name ~= "mask" and name ~= "rounded" then
            param[name] = eventObj.eventData_[name].values[1] + deltaTime * (eventObj.eventData_[name].values[2] - eventObj.eventData_[name].values[1]);
        end
    end

    self.cameraEffectManager_:setParam(self.effectId_,param);
end


function prototype:_updateFieldOfViewEffect(eventObj, beginTime)
    if eventObj == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / eventObj.eventData_.timeLength_ ;
    local names = {"fov"};
    local fov = 60;
    fov = eventObj.eventData_.fov.values[1] + deltaTime * (eventObj.eventData_.fov.values[2] - eventObj.eventData_.fov.values[1]);
    for i = 1, #self.cameras_ do
        self.cameras_[i].fieldOfView = fov;
    end
end


function prototype:_createBlackEffect(eventObj)
    self.effectId_ = self.cameraEffectManager_:createScreenOverlayEffect();
    self.cameraEffectManager_:start(self.effectId_);
    local param = self.cameraEffectManager_:getParam(self.effectId_);
    param.blendMode = eventObj.eventData_.blendMode - 1;
    param.texture = self:getResource(eventObj, eventObj.texturePath_);
    return param; 
end


function prototype:_updateBlackEffect(eventObj, param, beginTime)
    if eventObj == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / eventObj.eventData_.timeLength_ ;
    local names = {"blendMode", "texture", "intensity"};
    param.intensity = eventObj.eventData_.intensity.values[1] + deltaTime * (eventObj.eventData_.intensity.values[2] - eventObj.eventData_.intensity.values[1]);
    self.cameraEffectManager_:setParam(self.effectId_,param);
end


function prototype:_createCrossFadeEffect(eventObj)
    self.effectId_ = self.cameraEffectManager_:createCrossFadeEffect(eventObj.eventData_.timeLength_);
    self.cameraEffectManager_:start(self.effectId_);
    local param = self.cameraEffectManager_:getParam(self.effectId_);

    return param; 
end


function prototype:_updateCrossFadeEffect(eventObj, param, beginTime)
    if eventObj == nil or param == nil then
        return;
    end 
    param.progress = (self.director_.timeLine_ - beginTime) / eventObj.eventData_.timeLength_;
    self.cameraEffectManager_:setParam(self.effectId_,param);
end


return prototype;