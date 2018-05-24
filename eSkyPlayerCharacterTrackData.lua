local prototype = class("eSkyPlayerCharacterTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    prototype.super.ctor(self);
    self.trackFileType_ = definations.TRACK_FILE_TYPE.ROLE;
    self.trackType_ = definations.TRACK_TYPE.CHARACTER;
    self.eventsSupportted_ = {definations.EVENT_TYPE.CHARACTER};
    self.createParameters = {
        roleType = "number",
        gender = "number",
    };
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

        eventObj = newClass("eSkyPlayer/eSkyPlayerCharacterEventData");
        eventObj:initialize();

        if self:isSupported(eventObj) == false then
            return false;
        end

        if eventFile.storeType_ == 0 then
            if eventObj:loadEvent( "mod/events/npc/" .. eventFile.name_ .. ".byte") == false then
                return false;
            end
        else
            if self.pathHeader_ == nil then 
                if eventObj:loadEvent( "mod/plans/motion/" .. self.title_ .. "/npc/" .. eventFile.name_ .. ".byte") == false then
                    return false;
                end 
            else 
                if eventObj:loadEvent(self.pathHeader_ .. "npc/" .. eventFile.name_ .. ".byte") == false then --待确定
                    return false;
                end
            end
        end
        self:_insertEvent(eventFile,eventObj);
    end

    local editorResType = buff:ReadShort();
    local info = definations.SKY_EDITOR_RES_TYPE_ROLE_TYPE_RELATION[editorResType];
    local trackFile = {};
    trackFile.roleType = info.roleType;
    trackFile.gender = info.gender;
        
    return self:_setParam(trackFile);
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
    self.roleType_ = param.roleType;
    self.gender_ = param.gender;
    return true;    
end


return prototype;