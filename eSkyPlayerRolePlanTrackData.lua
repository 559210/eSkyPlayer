local prototype = class("eSkyPlayerRolePlanTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    prototype.super.ctor(self);       --由于多重继承，只能用prototype.super这种写法
    self.trackFileType_ = definations.TRACK_FILE_TYPE.MOTION;
    self.trackType_ = definations.TRACK_TYPE.ROLE_PLAN;
    self.eventsSupportted_ = {definations.EVENT_TYPE.ROLE_PLAN};
end


function prototype:_loadFromBuff(buff, name, nameTable)
    if buff == nil then 
        return false; 
    end

    local slot = buff:ReadByte();
    local title = buff:ReadString();
    self.name_ = self:getTrackName(name, self.trackType_, title, nameTable);
    local eventCount = buff:ReadShort();

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
        buff:ReadByte();--isLoopPlay_ = misc.getBoolByByte(buff:ReadByte());
        buff:ReadByte();--labelID_

        eventObj = newClass("eSkyPlayer/eSkyPlayerRolePlanEventData");
        eventObj:initialize();
        if self:isSupported(eventObj) == false then
            return false;
        end

        if storeType == 1 then
            if eventObj:loadEvent( self.pathHeader_ .. "plans/motion/" .. name, self.name_, nameTable) == false then 
                return false;
            end
        else 
            if eventObj:loadEvent( "mod/plans/motion/" .. name, self.name_, nameTable) == false then 
                return false;
            end
        end
        self:_insertEvent(beginTime, eventObj);
    end
    return true;
end


return prototype;