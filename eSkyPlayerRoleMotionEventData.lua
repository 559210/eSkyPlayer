local prototype = class("eSkyPlayerRoleMotionEventData", require("eSkyPlayer/eSkyPlayerEventDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

function prototype:ctor()
    self.base:ctor();
    self.eventType_ = definations.EVENT_TYPE.ROLE_MOTION;
    self.createParameters = {
        motionFilename = "string", --动作资源路径
        beginTime = "number",    -- 相对于实际动作文件的开始时间（用于剪裁）
        endTime = "number",  -- 相对于实际动作文件的结束时间（用于剪裁）  e.g. 如果动作文件有10秒，beginTime为2 endTime为5，则只播放动作文件第2秒到第5秒这3秒时间，相当于从10秒动作中截取3秒播放
        eventLength = "number",  -- event的时长
        motionLength = "number",    -- 实际动作文件的总时长
    };

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
    local param = {
        motionFilename = buff:ReadString(),
        beginTime = buff:ReadFloat(),
        endTime = buff:ReadFloat(),
        eventLength = buff:ReadFloat(),
        motionLength = buff:ReadFloat(),
    };

    if self:_setParam(param) == false then
        return false;
    end

    return true;
end


-- param是一个table
function prototype.createObject(param)      
    local obj = prototype:create()
    if obj:_setParam(param) == false then
        return nil;
    end 
    return obj;
end


function prototype:_setParam(param)
    if misc.checkParam(self.createParameters, param) == false then 
        return false; 
    end;
    local res = {};
    res.path = "motions/clips/" .. param.motionFilename;
    res.count = 1;
    self.eventData_ = {
        resourcesNeeded_ = {res},
        beginTime = param.beginTime,
        endTime = param.endTime,
        timeLength_ = param.eventLength,
        motionLength = param.motionLength
    }
    self.eventDataLength_ = self.eventData_.timeLength_;
    return true;
end

function prototype:clipEvent(newLength)
    self.base:clipEvent(newLength);
    local oldLen = self.eventData_.timeLength_;
    local tLength = self.eventData_.endTime - self.eventData_.beginTime;
    self.eventData_.endTime = (newLength / oldLen) * tLength + self.eventData_.beginTime;
end


return prototype;
