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
            end
        end

        if self.director_.timeLine_ < beginTime or self.director_.timeLine_ > endTime then
            if self.playingEvent == event then
                self.cameraEffectManager:close(self.effectId);
                self.director_.resourceManager_:releaseResource(event.texturePath);
                self.isEventPlaying_ = false;
                self.playingEvent = nil;
            end
        end
    end
end

function prototype:_creatBloomEffect(event)
    self.effectId = self.cameraEffectManager:createBloomEffect();
    self.cameraEffectManager:start(self.effectId);
    local param = self.cameraEffectManager:getParam(self.effectId);
    param.antiFlicker = misc.getBoolByByte(event.eventData_.antiFlicker)
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

return prototype;