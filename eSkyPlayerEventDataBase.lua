local prototype = class("eSkyPlayerEventDataBase");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.eventData_ = nil;
    self.projectData_ = nil;
    self.eventType_ = definations.EVENT_TYPE.UNKOWN;
end


function prototype:initialize()
    self.resList_ = {};
end


function prototype:loadEvent(filename)--filename为相对路径；
    if string.sub(filename,-5,-1) ~= ".byte" then
        self.projectData_ = newClass("eSkyPlayer/eSkyPlayerProjectData");
        self.projectData_:initialize();
        return self.projectData_:loadProject(filename);
    else
        self.eventData_ = {};
        local path = Util.AppDataRoot .. "/" ..filename;
        local buff = misc.readAllBytes(path);
        if self:_loadHeaderFromBuff(buff) == false then
            return false;
        end
        return self:_loadFromBuff(buff);
    end
end


function prototype:isProject()
    if self.projectData_ ~= nil and self.eventData_ == nil then
        return true;
    end

    return false;
end


function prototype:getProjectData()
    return self.projectData_;
end


function prototype:getEventData()
    return self.eventData_;
end


function prototype:getEventType()
    return self.eventType_;
end


function prototype:getResources()
    return nil;
end


function prototype:_loadHeaderFromBuff(buff)
    if buff == nil then 
        return false; 
    end
    self.eventData_.version = buff:ReadShort();
    self.eventData_.smallVersion = buff:ReadShort();
    self.eventData_.eventType = buff:ReadByte();
    self.eventData_.timeLength = buff:ReadFloat();

    return true;
end



return prototype;
