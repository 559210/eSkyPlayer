local prototype = class("eSkyPlayerCameraTrackDataBase", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    prototype.super.ctor(self);       --由于多重继承，只能用prototype.super这种写法
end


function prototype:_loadFromBuff(buff)
    if buff == nil then 
        return false; 
    end

    local trackTitle = buff:ReadString();
    local eventCount = buff:ReadShort();

    if eventCount == 0 then
        return true;
    end


    for e = 1, eventCount do
        local eventFile = {};
        local eventObj = nil;

        if self.eventsSupportted_ == nil then
            return false;
        end

        eventFile.beginTime_ = buff:ReadFloat();
        eventFile.name_ = buff:ReadString();
        eventFile.storeType_ = buff:ReadByte();
        eventFile.isLoopPlay_ = misc.getBoolByByte(buff:ReadByte());
        eventFile.labelID_ = buff:ReadByte();

        
        if self.trackType_ == definations.TRACK_TYPE.CAMERA_PLAN then 
            eventObj = newClass("eSkyPlayer/eSkyPlayerCameraPlanEventData");
            eventObj:initialize();
            if self:isSupported(eventObj) == false then
                return false;
            end
            if eventFile.storeType == 1 then
                if eventObj:loadEvent( self.pathHeader_ .. "plans/camera/" .. eventFile.name_) == false then 
                    return false;
                end
            else 
                if eventObj:loadEvent( "mod/plans/camera/" .. eventFile.name_) == false then 
                    return false;
                end
            end
        elseif self.trackType_ == definations.TRACK_TYPE.CAMERA_MOTION then
            eventObj = newClass("eSkyPlayer/eSkyPlayerCameraMotionEventData");
            eventObj:initialize();
            if self:isSupported(eventObj) == false then
                return false;
            end
            if eventFile.storeType_ == 0 then
                if eventObj:loadEvent( "mod/events/camera/" .. eventFile.name_ .. ".byte") == false then
                    return false;
                end
            else
                if self.pathHeader_ == nil then 
                    if eventObj:loadEvent( "mod/plans/camera/" .. self.title_ .. "/camera/" .. eventFile.name_ .. ".byte") == false then
                        return false;
                    end 
                else 
                    if eventObj:loadEvent(self.pathHeader_ .. "camera/" .. eventFile.name_) ==false then
                        return false;
                    end
                end
            end
        elseif self.trackType_ == definations.TRACK_TYPE.CAMERA_EFFECT then
            local path = nil;
            if eventFile.storeType_ == 0 then
                path = Util.AppDataRoot .. "/mod/events/cameraMotion" .. eventFile.name_ .. ".byte";
            else
                if self.pathHeader_ == nil then 
                    path = Util.AppDataRoot .. "/mod/plans/camera/" .. self.title_ .. "/cameraMotion/" .. eventFile.name_ .. ".byte";
                else 
                    path = Util.AppDataRoot .. "/" .. self.pathHeader_ .. "cameraMotion/" .. eventFile.name_ .. ".byte";
                end
            end
            local buff = misc.readAllBytes(path);
            buff:SetReaderPosition(9);
            local temp = buff:ReadByte();
            if temp == definations.CAMERA_EFFECT_TYPE.BLOOM then
                eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectBloomEventData");
            elseif temp == definations.CAMERA_EFFECT_TYPE.CHROMATIC_ABERRATION then
                eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectChromaticAberrationEventData");
            elseif temp == definations.CAMERA_EFFECT_TYPE.DEPTH_OF_FIELD then
                eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectDepthOfFieldEventData");
            elseif temp == definations.CAMERA_EFFECT_TYPE.VIGNETTE then
                eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectVignetteEventData");
            elseif temp == definations.CAMERA_EFFECT_TYPE.FIELD_OF_VIEW then
                eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectFieldOfViewEventData");
            elseif temp == definations.CAMERA_EFFECT_TYPE.BLACK then
                eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectBlackEventData");
            elseif temp == definations.CAMERA_EFFECT_TYPE.CROSS_FADE then
                eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectCrossFadeEventData");
            end
            eventObj:initialize();
            if self:isSupported(eventObj) == false then
                return false;
            end
            eventObj.eventData_ = {};
            local temp = buff:SetReaderPosition(0);
            if eventObj:_loadHeaderFromBuff(buff) == false then
                return false;
            end
            if eventObj:_loadFromBuff(buff) == false then
                return false;
            end
        else
            return true;
        end
        self:_insertEvent(eventFile,eventObj);
    end

    if self.trackType_ == definations.TRACK_TYPE.CAMERA_PLAN or
        self.trackType_ == definations.TRACK_TYPE.MOTION_PLAN or
        self.trackType_ == definations.TRACK_TYPE.MUSIC_PLAN or
        self.trackType_ == definations.TRACK_TYPE.SCENE_PLAN then
        
        local project = self.events_[#self.events_].eventObj_:getProjectData();
        self.trackTimeLength_ = project:getTimeLength();
    else
        self.trackTimeLength_ = self.events_[#self.events_].eventFile_.beginTime_ + self.events_[#self.events_].eventObj_.eventData_.timeLength_;
    end
    return true;
end

return prototype;