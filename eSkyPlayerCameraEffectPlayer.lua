local prototype = class("eSkyPlayerCameraEffectPlayer",require "eSkyPlayer/eSkyPlayerBase");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor(director)
    self.base:ctor(director);
    self.mainCamera_ = director.camera_;
    self.cameraTrack_ = nil;
    self.isNeedAdditionalCamera_ = false;
    self.playingEvent_ = nil;
    self.cameraEffectManager_ = director.cameraEffectManager_;
    self.param_ = nil;
    self.additionalCamera_ = nil;
    self.resourceManager = require("eSkyPlayer/eSkyPlayerResourceManager");
end

function prototype:initialize(trackObj)
    self.cameraTrack_ = trackObj;
    self.isEventPlaying_ = false;
    self.effectId_ = -1;
    self:_isNeedAdditionalCamera();
    return self.base:initialize(trackObj);
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

function prototype:setAdditionalCamera(camera)
    self.additionalCamera_ = camera;
end

function prototype:_isNeedAdditionalCamera()
    if self.cameraTrack_:isNeedAdditionalCamera() == true then
        self.isNeedAdditionalCamera_ = true;
    else 
        self.isNeedAdditionalCamera_ = false;
    end
end

function prototype:_update()
    if self.director_.timeLine_ >= self.director_.timeLength_ then
        self.base.isPlaying_ = false;
        return;
    end

    for i = 1, self.eventCount_  do
        local beginTime = self.cameraTrack_:getEventBeginTimeAt(i);
        local eventObj = self.cameraTrack_:getEventAt(i);
        local endTime = beginTime + eventObj.eventData_.timeLength_;

        if self.cameraTrack_:isSupported(eventObj) == false then
            return;
        end

        if self.director_.timeLine_ >= beginTime and self.director_.timeLine_ <= endTime then
            if self.playingEvent_ == nil then
                if eventObj.eventData_.motionType == definations.CAMERA_EFFECT_TYPE.BLOOM then
                    if self.isEventPlaying_ == false then
                        self.param_ = self:_creatBloomEffect(eventObj);
                        self:_updateBloomEffect(eventObj, self.param_, beginTime);
                        self.isEventPlaying_ = true;
                        self.playingEvent_ = eventObj;
                    else
                        self:_updateBloomEffect(eventObj, self.param_, beginTime);
                    end
                elseif eventObj.eventData_.motionType == definations.CAMERA_EFFECT_TYPE.CHROMATIC_ABERRATION then
                    if self.isEventPlaying_ == false then
                        self.param_ = self:_creatChromaticAberrationEffect(eventObj);
                        self:_updateChromaticAberrationEffect(eventObj, self.param_, beginTime);
                        self.isEventPlaying_ = true;
                        self.playingEvent_ = eventObj;
                    else
                        self:_updateChromaticAberrationEffect(eventObj, self.param_, beginTime);
                    end
                elseif eventObj.eventData_.motionType == definations.CAMERA_EFFECT_TYPE.DEPTH_OF_FIELD then
                    if self.isEventPlaying_ == false then
                        self.param_ = self:_creatDepthOfFieldEffect(eventObj);
                        self:_updateDepthOfFieldEffect(eventObj, self.param_, beginTime);
                        self.isEventPlaying_ = true;
                        self.playingEvent_ = eventObj;
                    else
                        self:_updateDepthOfFieldEffect(eventObj, self.param_, beginTime);
                    end
                elseif eventObj.eventData_.motionType == definations.CAMERA_EFFECT_TYPE.VIGNETTE then
                    if self.isEventPlaying_ == false then
                        self.param_ = self:_creatVignetteEffect(eventObj);
                        self:_updateVignetteEffect(eventObj, self.param_, beginTime);
                        self.isEventPlaying_ = true;
                        self.playingEvent_ = eventObj;
                    else
                        self:_updateVignetteEffect(eventObj, self.param_, beginTime);
                    end
                elseif eventObj.eventData_.motionType == definations.CAMERA_EFFECT_TYPE.BLACK then
                    if self.isEventPlaying_ == false then
                        self.param_ = self:_creatBlackEffect(eventObj);
                        self:_updateBlackEffect(eventObj, self.param_, beginTime);
                        self.isEventPlaying_ = true;
                        self.playingEvent_ = eventObj;
                    else
                        self:_updateBlackEffect(eventObj, self.param_, beginTime);
                    end
                elseif eventObj.eventData_.motionType == definations.CAMERA_EFFECT_TYPE.CROSS_FADE then
                    if self.isEventPlaying_ == false then
                        if self.additionalCamera_.enabled == true then
                            self.param_ = self:_creatCrossFadeEffect(eventObj);
                            self:_updateCrossFadeEffect(eventObj, self.param_, beginTime);
                            self.isEventPlaying_ = true;
                            self.playingEvent_ = eventObj;
                        end
                    else
                        self:_updateCrossFadeEffect(eventObj, self.param_, beginTime);
                    end
                elseif eventObj.eventData_.motionType == definations.CAMERA_EFFECT_TYPE.FIELD_OF_VIEW then
                    self.playingEvent_ = eventObj;
                    self:_updateFieldOfViewEffect(eventObj, beginTime);
                end
            end
        end
        
        if self.director_.timeLine_ < beginTime or self.director_.timeLine_ > endTime then
            if self.playingEvent_ == eventObj then
                if eventObj.eventData_.motionType == definations.CAMERA_EFFECT_TYPE.FIELD_OF_VIEW then
                    self.mainCamera_.fieldOfView = 60;
                else
                    self.cameraEffectManager_:destroy(self.effectId_);
                    self.resourceManager:releaseResource(eventObj.texturePath);
                end
                self.isEventPlaying_ = false;
                self.playingEvent_ = nil;
                return;
            end
        end
    end
end

function prototype:_creatBloomEffect(eventObj)
    self.effectId_ = self.cameraEffectManager_:createBloomEffect();
    self.cameraEffectManager_:start(self.effectId_);
    local param = self.cameraEffectManager_:getParam(self.effectId_);
    param.antiFlicker = misc.getBoolByByte(eventObj.eventData_.antiFlicker);
    param.lenDirtTexture = self.resourceManager:getResource(eventObj.texturePath);
    return param; 
end

function prototype:_updateBloomEffect(eventObj, param, beginTime)
    if eventObj == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / eventObj.eventData_.timeLength ;
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

function prototype:_creatChromaticAberrationEffect(eventObj)
    self.effectId_ = self.cameraEffectManager_:createChromaticAberrationEffect();
    self.cameraEffectManager_:start(self.effectId_);
    local param = self.cameraEffectManager_:getParam(self.effectId_);

    param.spectralTexture = self.resourceManager:getResource(eventObj.texturePath);
    return param; 
end

function prototype:_updateChromaticAberrationEffect(eventObj, param, beginTime)
    if eventObj == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / eventObj.eventData_.timeLength ;
    local names = {"intensity", "spectralTexture"};
    param.intensity = eventObj.eventData_.intensity.values[1] + deltaTime * (eventObj.eventData_.intensity.values[2] - eventObj.eventData_.intensity.values[1]);

    self.cameraEffectManager_:setParam(self.effectId_,param);
end

function prototype:_creatDepthOfFieldEffect(eventObj)
    self.effectId_ = self.cameraEffectManager_:createDepthOfFieldEffect();
    self.cameraEffectManager_:start(self.effectId_);
    local param = self.cameraEffectManager_:getParam(self.effectId_);

    return param; 
end

function prototype:_updateDepthOfFieldEffect(eventObj, param, beginTime)
    if eventObj == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / eventObj.eventData_.timeLength ;
    local names = {"aperture"};
    param.aperture = eventObj.eventData_.aperture.values[1] + deltaTime * (eventObj.eventData_.aperture.values[2] - eventObj.eventData_.aperture.values[1]);

    self.cameraEffectManager_:setParam(self.effectId_,param);
end

function prototype:_creatVignetteEffect(eventObj)
    self.effectId_ = self.cameraEffectManager_:createVignetteEffect();
    self.cameraEffectManager_:start(self.effectId_);
    local param = self.cameraEffectManager_:getParam(self.effectId_);
    param.mode = eventObj.eventData_.mode - 1;
    param.rounded = misc.getBoolByByte(eventObj.eventData_.rounded);
    param.mask = self.resourceManager:getResource(eventObj.texturePath);
    return param; 
end

function prototype:_updateVignetteEffect(eventObj, param, beginTime)
    if eventObj == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / eventObj.eventData_.timeLength ;
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
    local deltaTime = (self.director_.timeLine_ - beginTime) / eventObj.eventData_.timeLength ;
    local names = {"fov"};
    local fov = 60;
    fov = eventObj.eventData_.fov.values[1] + deltaTime * (eventObj.eventData_.fov.values[2] - eventObj.eventData_.fov.values[1]);
    self.mainCamera_.fieldOfView = fov;
end

function prototype:_creatBlackEffect(eventObj)
    self.effectId_ = self.cameraEffectManager_:createScreenOverlayEffect();
    self.cameraEffectManager_:start(self.effectId_);
    local param = self.cameraEffectManager_:getParam(self.effectId_);
    param.blendMode = eventObj.eventData_.blendMode - 1;
    param.texture = self.resourceManager:getResource(eventObj.texturePath);
    return param; 
end

function prototype:_updateBlackEffect(eventObj, param, beginTime)
    if eventObj == nil or param == nil then
        return;
    end 
    local deltaTime = (self.director_.timeLine_ - beginTime) / eventObj.eventData_.timeLength ;
    local names = {"blendMode", "texture", "intensity"};
    param.intensity = eventObj.eventData_.intensity.values[1] + deltaTime * (eventObj.eventData_.intensity.values[2] - eventObj.eventData_.intensity.values[1]);
    self.cameraEffectManager_:setParam(self.effectId_,param);
end

function prototype:_creatCrossFadeEffect(eventObj)
    self.effectId_ = self.cameraEffectManager_:createCrossFadeEffect(eventObj.eventData_.timeLength);
    self.cameraEffectManager_:start(self.effectId_);
    local param = self.cameraEffectManager_:getParam(self.effectId_);

    return param; 
end

function prototype:_updateCrossFadeEffect(eventObj, param, beginTime)
    if eventObj == nil or param == nil then
        return;
    end 
    param.progress = (self.director_.timeLine_ - beginTime) / eventObj.eventData_.timeLength;
    self.cameraEffectManager_:setParam(self.effectId_,param);
end


return prototype;