local prototype = class("eSkyPlayerRoleMorphTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    prototype.super.ctor(self);       --由于多重继承，只能用prototype.super这种写法
    self.trackFileType_ = definations.TRACK_FILE_TYPE.MORPH;
    self.trackType_ = definations.TRACK_TYPE.ROLE_MORPH;
    self.eventsSupportted_ = {definations.EVENT_TYPE.ROLE_MORPH};
    self.createParameters = {};
end


function prototype:_loadFromBuff(buff, name, nameTable)
    if buff == nil then 
        return false; 
    end

    local slot = buff:ReadByte();
    local trackTitle = buff:ReadString();
    self.name_ = self:getTrackName(name, self.trackType_, trackTitle, nameTable);
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

        eventObj = newClass("eSkyPlayer/eSkyPlayerRoleMorphEventData");
        eventObj:initialize();

        if self:isSupported(eventObj) == false then
            return false;
        end

        if eventFile.storeType_ == 0 then
            if eventObj:loadEvent( "mod/events/morph/" .. eventFile.name_ .. ".byte") == false then
                return false;
            end
        else
            if self.pathHeader_ == nil then 
                if eventObj:loadEvent( "mod/plans/motion/" .. self.title_ .. "/morph/" .. eventFile.name_ .. ".byte") == false then
                    return false;
                end 
            else 
                if eventObj:loadEvent(self.pathHeader_ .. "morph/" .. eventFile.name_) ==false then
                    return false;
                end
            end
        end
        self:_insertEvent(eventFile,eventObj);
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