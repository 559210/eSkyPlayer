local prototype = class("eSkyPlayer2DObjectTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    prototype.super.ctor(self);
    self.trackFileType_ = definations.TRACK_FILE_TYPE.TWO_D_OBJECT;
    self.trackType_ = definations.TRACK_TYPE.TWO_D_OBJECT;
    self.eventsSupportted_ = {definations.EVENT_TYPE.TWO_D_OBJECT};
    self.createParameters = {};
end


function prototype:_loadFromBuff(buff, name, nameTable)
    if buff == nil then 
        return false; 
    end

    local slot = buff:ReadByte();
    local trackTitle = buff:ReadString();
    local idx = self:getNameId(self.trackType_ .."_" ..trackTitle, nameTable);
    self.name_ = name .."/" ..self.trackType_ .."_" ..trackTitle .."_" ..idx
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
        buff:ReadByte(); --isLoopPlay_ = misc.getBoolByByte(buff:ReadByte());
        buff:ReadByte();--labelID 

        eventObj = newClass("eSkyPlayer/eSkyPlayer2DObjectEventData");
        eventObj:initialize();

        if self:isSupported(eventObj) == false then
            return false;
        end

        if storeType == 0 then
            if eventObj:loadEvent( "mod/events/2dObject/" .. name .. ".byte") == false then
                return false;
            end
        else
            if self.pathHeader_ == nil then 
                if eventObj:loadEvent( "mod/plans/motion/" .. self.title_ .. "/2dObject/" .. name .. ".byte") == false then
                    return false;
                end 
            else 
                if eventObj:loadEvent(self.pathHeader_ .. "2dObject/" .. name .. ".byte") == false then
                    return false;
                end
            end
        end
        self:_insertEvent(beginTime,eventObj);
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
    if misc.checkParam(self.createParameters, param) == false then
        return false;
    end
    return true;    
end


return prototype;