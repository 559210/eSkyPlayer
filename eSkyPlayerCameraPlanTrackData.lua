local prototype = class("eSkyPlayerCameraPlanTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

function prototype:ctor()
    prototype.super.ctor(self);       --由于多重继承，只能用prototype.super这种写法
    self.trackType_ = definations.TRACK_TYPE.CAMERA_PLAN;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.CAMERA;
    self.eventsSupportted_ = {definations.EVENT_TYPE.CAMERA_PLAN};
end

function prototype:_loadFromBuff(buff, name, nameTable)
    if buff == nil then 
        return false; 
    end
    local title = buff:ReadString();
    local tName = self.trackType_ .."_" ..title;
    local idx = self:getNameId(tName, nameTable);
    self.name_ = name ..tName .."_" ..idx;
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
        buff:ReadByte();--labelID
        eventObj = newClass("eSkyPlayer/eSkyPlayerCameraPlanEventData");
        eventObj:initialize();
        if self:isSupported(eventObj) == false then
            return false;
        end
        if eventFile.storeType == 1 then
            if eventObj:loadEvent( self.pathHeader_ .. "plans/camera/" .. eventFile.name_, self.name_, nameTable) == false then 
                return false;
            end
        else 
            if eventObj:loadEvent( "mod/plans/camera/" .. eventFile.name_, self.name_, nameTable) == false then 
                return false;
            end
        end
        
        self:_insertEvent(eventFile,eventObj);
    end
    return true;
end

return prototype;