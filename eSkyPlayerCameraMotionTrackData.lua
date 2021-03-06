local prototype = class("eSkyPlayerCameraMotionTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

function prototype:ctor()
    self.base:ctor(self);
    self.trackType_ = definations.TRACK_TYPE.CAMERA_MOTION;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.CAMERA;
    self.eventsSupportted_ = {definations.EVENT_TYPE.CAMERA_MOTION};
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
        buff:ReadByte(); --isLoopPlay_ = misc.getBoolByByte(buff:ReadByte());
        buff:ReadByte();--labelID 
        eventObj = newClass("eSkyPlayer/eSkyPlayerCameraMotionEventData");
        eventObj:initialize();
        if self:isSupported(eventObj) == false then
            return false;
        end
        if storeType == 0 then
            if eventObj:loadEvent( "mod/events/camera/" .. name .. ".byte") == false then
                return false;
            end
        else
            if self.pathHeader_ == nil then 
                if eventObj:loadEvent( "mod/plans/camera/" .. self.title_ .. "/camera/" .. name .. ".byte") == false then
                    return false;
                end 
            else 
                if eventObj:loadEvent(self.pathHeader_ .. "camera/" .. name .. ".byte") == false then
                    return false;
                end
            end
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

return prototype;