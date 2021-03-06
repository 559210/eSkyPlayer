local prototype = class("eSkyPlayerCameraEffectTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

function prototype:ctor()
    prototype.super.ctor(self);       --由于多重继承，只能用prototype.super这种写法
    self.trackType_ = definations.TRACK_TYPE.CAMERA_EFFECT;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.CAMERA_MOTION;
    self.eventsSupportted_ = {
    definations.EVENT_TYPE.CAMERA_EFFECT_BLOOM,
    definations.EVENT_TYPE.CAMERA_EFFECT_BLACK,
    definations.EVENT_TYPE.CAMERA_EFFECT_DEPTH_OF_FIELD,
    definations.EVENT_TYPE.CAMERA_EFFECT_CROSS_FADE,
    definations.EVENT_TYPE.CAMERA_EFFECT_FIELD_OF_VIEW,
    definations.EVENT_TYPE.CAMERA_EFFECT_CHROMATIC_ABERRATION,
    definations.EVENT_TYPE.CAMERA_EFFECT_VIGNETTE,
    };
    self.createParameters = {};
end


function prototype:_loadFromBuff(buff, name, nameTable)
    if buff == nil then 
        return false; 
    end

    local title = buff:ReadString();
    self.name_ = self:getTrackName(name, self.trackType_, title, nameTable);
    local eventCount = buff:ReadShort();
    self:_setParam({});
    if eventCount == 0 then
        return true;
    end

    for e = 1, eventCount do
        local beginTime = 0;
        local eventObj = nil;

        if self.eventsSupportted_ == nil then
            return false;
        end
        beginTime = buff:ReadFloat();
        local name = buff:ReadString();
        local storeType = buff:ReadByte();
        buff:ReadByte();--misc.getBoolByByte(buff:ReadByte());
        buff:ReadByte();--labelID

        local path = nil;
        if storeType == 0 then
            path = Util.AppDataRoot .. "/mod/events/cameraMotion" .. name .. ".byte";
        else
            if self.pathHeader_ == nil then 
                path = Util.AppDataRoot .. "/mod/plans/camera/" .. self.title_ .. "/cameraMotion/" .. name .. ".byte";
            else 
                path = Util.AppDataRoot .. "/" .. self.pathHeader_ .. "cameraMotion/" .. name .. ".byte";
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
        else
            return false;
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
        if eventObj:_loadFromBuff(buff, self.name_, nameTable) == false then
            return false;
        end

        self:_insertEvent(beginTime, eventObj);
    end
    return true;
end


function prototype.createObject(param)
    local obj = prototype:create();
    if obj:_setParam(param) == false then
        return nil;
    end
    return obj;
end

function prototype:_setParam(param)
    if misc.checkParam(self.createParameters,param) == false then
        return false;
    end
    return true;
end

function prototype:initialize()
    prototype.super.initialize(self);
end


function prototype:isNeedAdditionalCamera()
    for i = 1, #self.events_ do
        if self.events_[i].motionType_ == definations.CAMERA_EFFECT_TYPE.CROSS_FADE then
            return true;
        end
    end
    return false;
end

return prototype;