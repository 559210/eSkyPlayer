local prototype = class("eSkyPlayerAvatarPartEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");

function prototype:ctor()
    prototype.super.ctor(self);
    self.eventType_ = definations.EVENT_TYPE.AVATAR_PART;

    self.createParameters = {
        timeLength = "number", 
        manItemCode = "number",
        womanItemCode = "number",
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
    eventFile.timeLength = buff:ReadFloat();
    local manItemCode = buff:ReadString();
    local womanItemCode = buff:ReadString();
    eventFile.manItemCode = tonumber(manItemCode);
    eventFile.womanItemCode = tonumber(womanItemCode);

    if eventFile.manItemCode and eventFile.womanItemCode == nil then  --如果一个itemCode为空，就把另一个itemCode赋值给它；如果两个都为空，则返回false；
        eventFile.womanItemCode = eventFile.manItemCode;
    elseif eventFile.manItemCode == nil and eventFile.womanItemCode then
        eventFile.manItemCode = eventFile.womanItemCode;
    elseif eventFile.manItemCode == nil and eventFile.womanItemCode == nil then
        return false;
    end

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
    if misc.checkParam(self.createParameters,param) == false then return false; end
    local res = {};
    if param.manItemCode ~= -1 then
        local res1 = {};
        res1.path = G.configs.avatar:getAvatarUrl(param.manItemCode);
        res1.count = 1;
        res[#res + 1] = res1;
    end
    if param.womanItemCode ~= -1 then
        local res2 = {};
        res2.path = G.configs.avatar:getAvatarUrl(param.womanItemCode);
        res2.count = 1;
        res[#res + 1] = res2;
    end

    self.eventData_ = {
        timeLength_ = param.timeLength,
        resourcesNeeded_ = res,
        manItemCode_ = param.manItemCode,
        womanItemCode_ = param.womanItemCode,
    };

    return true;
end

return prototype;