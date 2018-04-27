local prototype = class("eSkyPlayerEventDataBase");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    self.eventData_ = nil;
    self.projectData_ = nil;
    self.eventDataLength_ = 0;
    self.eventType_ = definations.EVENT_TYPE.UNKOWN;
    self.resourceManagerTacticType_ = definations.MANAGER_TACTIC_TYPE.NO_NEED;
    -- self.resourcesNeeded_ = {};
end


function prototype:initialize()
    return true;
end


function prototype:loadEvent(filename, name, nameTable)--filename为相对路径；
    if string.sub(filename,-5,-1) ~= ".byte" then
        self.projectData_ = newClass("eSkyPlayer/eSkyPlayerProjectData");
        self.projectData_:initialize();
        return self.projectData_:loadProject(filename, name, nameTable);
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

function prototype:getTimeLength()
    return self.eventData_.timeLength_;
end

function prototype:_loadHeaderFromBuff(buff)
    if buff == nil then 
        return false; 
    end
    self.eventData_.version_ = buff:ReadShort();
    self.eventData_.smallVersion_ = buff:ReadShort();
    self.eventData_.eventType_ = buff:ReadByte();
    self.eventData_.timeLength_ = buff:ReadFloat();

    return true;
end

function prototype.createObject(param)
    return nil;
end


function prototype:scaleEvent(newLength)
    self.eventDataLength_ = newLength;
    self.eventData_.timeLength_ = newLength;
end

--newLength 必须是新插入的开始时间减被插入event的开始时间
function prototype:clipEvent(newLength)
    self.eventData_.timeLength_ = newLength;
end


return prototype;

