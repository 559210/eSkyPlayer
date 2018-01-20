local prototype = class("eSkyPlayerCameraEffectPlayer",require "eSkyPlayer/eSkyPlayerBase");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor(director)
    self.base:ctor(director);
    self.mainCamera_ = director.camera_;
    self.cameraTrack_ = nil;
    self.additionalCamera_ = nil;
    self.isNeedAdditionalCamera_ = false;
    self.playingEvent = nil;
    self.cameraEffectManager = eSkyPlayerCameraEffectManager.New();
    self.param = nil;
end

function prototype:initialize(trackObj)
    self.cameraTrack_ = trackObj;
    self.isEventPlaying_ = false;
    self.cameraEffectManager:initialize(self.mainCamera_,nil);
    return self.base:initialize(trackObj);
end

function prototype:uninitialize()
    self.cameraEffectManager:dispose();
    self.cameraEffectManager = nil;
end

function prototype:play()
    if self.cameraTrack_ == nil  then
        return false; 
    end
    if self.mainCamera_ == nil then
        return false;
    end

    self.base:play();
    return true;
end

function prototype:stop()
    return true;
end

function prototype:seek(time)
    return true;
end

function prototype:getResources()
    local resList_ = self.cameraTrack_:getResources();
    return resList_;
end

function prototype:isNeedAdditionalCamera()
    return self.isNeedAdditionalCamera_;
end

function prototype:_update()
    if self.director_.timeLine_ >= self.director_.timeLength_ then
        self.base.isPlaying_ = false;
        return;
    end

     for i = 1, self.eventCount_  do
        local beginTime = self.cameraTrack_:getEventBeginTimeAt(i);
        local event = self.cameraTrack_:getEventAt(i);
        local endTime = beginTime + event.eventData_.timeLength;

        if self.cameraTrack_:isSupported(event) == false then
            return;
        end

        if self.director_.timeLine_ >= beginTime and self.director_.timeLine_ <= endTime then
            if event.eventData_.motionType == definations.CAMERA_MOTION_TYPE.BLOOM then
                if self.isEventPlaying_ == false then
                    self.param = self:_creatBloomEffect(event);
                    self:_updateBloomEffect(event, self.param, beginTime);
                    self.isEventPlaying_ = true;
                    self.playingEvent = event;
                else
                    self:_updateBloomEffect(event, self.param, beginTime);
                end
            elseif event.eventData_.motionType == definations.CAMERA_MOTION_TYPE.CHROMATIC_ABERRATION then
                if self.isEventPlaying_ == false then
                    self.param = self:_creatChromaticAberrationEffect(event);
                    self:_updateChromaticAberrationEffect(event, self.param, beginTime);
                    self.isEventPlaying_ = true;
                    self.playingEvent = event;
                else
                    self:_updateChromaticAberrationEffect(event, self.param, beginTime);
                end
            elseif event.eventData_.motionType == definations.CAMERA_MOTION_TYPE.DEPTH_OF_FIELD then
                if self.isEventPlaying_ == false then
                    self.param = self:_creatDepthOfFieldEffect(event);
                    self:_updateDepthOfFieldEffect(event, self.param, beginTime);
                    self.isEventPlaying_ = true;
                    self.playingEvent = event;
                else
                    self:_updateDepthOfFieldEffect(event, self.param, beginTime);
                end
            elseif event.eventData_.motionType == definations.CAMERA_MOTION_TYPE.VIGNETTE then
                if self.isEventPlaying_ == false then
                    self.param = self:_creatVignetteEffect(event);
                    self:_updateVignetteEffect(event, self.param, beginTime);
                    self.isEventPlaying_ = true;
                    self.playingEvent = event;
                else
                    self:_updateVignetteEffect(event, self.param, beginTime);
                end
            elseif event.eventData_.motionType == definations.CAMERA_MOTION_TYPE.BLACK then
                if self.isEventPlaying_ == false then
                    self.param = self:_creatBlackEffect(event);
                    self:_updateBlackEffect(event, self.param, beginTime);
                    self.isEventPlaying_ = true;
                    self.playingEvent = event;
                else
                    self:_updateBlackEffect(event, self.param, beginTime);
                end
            elseif event.eventData_.motionType == definations.CAMERA_MOTION_TYPE.FIELD_OF_VIEW then
                self.playingEvent = event;
                self:_updateFieldOfViewEffect(event, beginTime)
            end
        end

        if self.director_.timeLine_ < beginTime or self.director_.timeLine_ > endTime then
            if self.playingEvent == event then
                if event.eventData_.motionType == definations.CAMERA_MOTION_TYPE.FIELD_OF_VIEW then
                    self.mainCamera_.fieldOfView = 60;
                else
                    self.cameraEffectManager:close(self.effectId);
                    self.director_.resourceManager_:releaseResource(event.texturePath);
                    self.isEventPlaying_ = false;
                    self.playingEvent = nil;
                end
            end
        end
    end
end

function prototype:_creatBloomEffect(event)
    self.effectId = self.cameraEffectManager:createBloomEffect();
    self.cameraEffectManager:start(self.effectId);
    local param = self.cameraEffectManager:getParam(self.effectId);
    param.antiFlicker = misc.getBoolByByte(event.eventData_.antiFlicker);
    param.lenDirtTexture = self.director_.resourceManager_:getResource(event.texturePath);
    return param; 
end

function prototype:_updateBloomEffect(event, param, beginTime)
    if event == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / event.eventData_.timeLength ;
    local names = {"intensity", "threshold", "softKnee", "radius", "antiFlicker", "intensityBloom", "textureBloom"};
    for _, name in ipairs(names) do
        if name == "intensityBloom" then
            param.lenDirtIntensity = event.eventData_[name].values[1] + deltaTime * (event.eventData_[name].values[2] - event.eventData_[name].values[1]);
        elseif name ~= "antiFlicker" and name ~= "textureBloom" then
            param[name] = event.eventData_[name].values[1] + deltaTime * (event.eventData_[name].values[2] - event.eventData_[name].values[1]);
        end
    end

    self.cameraEffectManager:setParam(self.effectId,param);
end

function prototype:_creatChromaticAberrationEffect(event)
    self.effectId = self.cameraEffectManager:createChromaticAberrationEffect();
    self.cameraEffectManager:start(self.effectId);
    local param = self.cameraEffectManager:getParam(self.effectId);

    param.spectralTexture = self.director_.resourceManager_:getResource(event.texturePath);
    return param; 
end

function prototype:_updateChromaticAberrationEffect(event, param, beginTime)
    if event == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / event.eventData_.timeLength ;
    local names = {"intensity", "spectralTexture"};
    param.intensity = event.eventData_.intensity.values[1] + deltaTime * (event.eventData_.intensity.values[2] - event.eventData_.intensity.values[1]);

    self.cameraEffectManager:setParam(self.effectId,param);
end

function prototype:_creatDepthOfFieldEffect(event)
    self.effectId = self.cameraEffectManager:createDepthOfFieldEffect();
    self.cameraEffectManager:start(self.effectId);
    local param = self.cameraEffectManager:getParam(self.effectId);

    return param; 
end

function prototype:_updateDepthOfFieldEffect(event, param, beginTime)
    if event == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / event.eventData_.timeLength ;
    local names = {"aperture"};
    param.aperture = event.eventData_.aperture.values[1] + deltaTime * (event.eventData_.aperture.values[2] - event.eventData_.aperture.values[1]);

    self.cameraEffectManager:setParam(self.effectId,param);
end

function prototype:_creatVignetteEffect(event)
    self.effectId = self.cameraEffectManager:createVignetteEffect();
    self.cameraEffectManager:start(self.effectId);
    local param = self.cameraEffectManager:getParam(self.effectId);
    param.mode = event.eventData_.mode;
    param.rounded = misc.getBoolByByte(event.eventData_.rounded);
    param.mask = self.director_.resourceManager_:getResource(event.texturePath);
    return param; 
end

function prototype:_updateVignetteEffect(event, param, beginTime)
    if event == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / event.eventData_.timeLength ;
    local names = {"mode", "allColor", "intensity", "smoothness", "roundness", "mask", "opacity", "rounded"};
    for _, name in ipairs(names) do
        if name == "allColor" then
            local allColor = event.eventData_[name].values[1] + deltaTime * (event.eventData_[name].values[2] - event.eventData_[name].values[1]);
            local _color = Color.New();
            _color.r = allColor / 255;
            _color.g = allColor / 255;
            _color.b = allColor / 255;
            param.color = _color;
        elseif name ~= "mode" and name ~= "mask" and name ~= "rounded" then
            param[name] = event.eventData_[name].values[1] + deltaTime * (event.eventData_[name].values[2] - event.eventData_[name].values[1]);
        end
    end

    self.cameraEffectManager:setParam(self.effectId,param);
end

function prototype:_updateFieldOfViewEffect(event, beginTime)
    if event == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / event.eventData_.timeLength ;
    local names = {"fov"};
    local fov = 60;
    fov = event.eventData_.fov.values[1] + deltaTime * (event.eventData_.fov.values[2] - event.eventData_.fov.values[1]);
    self.mainCamera_.fieldOfView = fov;
end

function prototype:_creatBlackEffect(event)
    self.effectId = self.cameraEffectManager:createScreenOverlayEffect();
    self.cameraEffectManager:start(self.effectId);
    local param = self.cameraEffectManager:getParam(self.effectId);
    param.blendMode = event.eventData_.blendMode;
    param.texture = self.director_.resourceManager_:getResource(event.texturePath);
    return param; 
end

function prototype:_updateBlackEffect(event, param, beginTime)
    if event == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / event.eventData_.timeLength ;
    local names = {"blendMode", "texture", "intensity"};
    param.intensity = event.eventData_.intensity.values[1] + deltaTime * (event.eventData_.intensity.values[2] - event.eventData_.intensity.values[1]);

    self.cameraEffectManager:setParam(self.effectId,param);
end

return prototype;