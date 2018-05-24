local prototype = class("eSkyPlayer2DObjectEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);
    self.eventType_ = definations.EVENT_TYPE.TWO_D_OBJECT;

    self.createParameters = {
        pkgName = "string", 
        resName = "string",
        boneName = "string",
        dialogContext = "string", 
        posX = "number",
        posY = "number",
        posZ = "number",
        angleX = "number",
        angleY = "number",
        angleZ = "number",
        timeLength = "number",
    };
end


function prototype:initialize()
    prototype.super.initialize(self);
    return true;
end

function prototype:_loadHeaderFromBuff(buff)
    if buff == nil then 
        return false; 
    end
    self.eventData_.version_ = buff:ReadShort();
    self.eventData_.smallVersion_ = buff:ReadShort();
    self.eventData_.eventType_ = buff:ReadByte();

    return true;
end


function prototype:_loadFromBuff(buff)
    local eventFile = {};
    eventFile.pkgName = buff:ReadString();
    eventFile.resName = buff:ReadString();
    eventFile.boneName = buff:ReadString();
    eventFile.dialogContext = buff:ReadString();
    eventFile.posX = buff:ReadFloat();
    eventFile.posY = buff:ReadFloat();
    eventFile.posZ = buff:ReadFloat();
    eventFile.angleX = buff:ReadFloat();
    eventFile.angleY = buff:ReadFloat();
    eventFile.angleZ = buff:ReadFloat();
    eventFile.timeLength = buff:ReadFloat();
    return self:_setParam(eventFile);
end

 -- param是一个table
function prototype.createObject(param)
    if param == nil then
        return nil;
    end
    local obj = prototype:create();
    if obj:_setParam(param) == false then
        return nil
    end
    return obj;
end

function prototype:_setParam(param)
    local res = {};
    res.path = "ui/" .. param.pkgName;
    res.count = 1;
    res.type = definations.RESOURCE_TYPE.UI;
    self.eventData_ = {
        resourcesNeeded_ = {res},
        pkgName_ = param.pkgName,
        resName_ = param.resName,
        boneName_ = param.boneName,
        dialogContext_ = param.dialogContext,
        pos_ = Vector3.New(param.posX, posY, param.posZ),
        angle_ = Vector3.New(param.angleX, angleY, param.angleZ),
        timeLength_ = param.timeLength,
    };

    return true;
end

return prototype;