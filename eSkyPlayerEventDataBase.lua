local prototype = class("eSkyPlayerEventDataBase");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
--注明：剪裁功能并非真的剪掉event，而是改变event在track上的实际播放开始时间，以及播放长度；
--     剪裁缩放都有时，默认转化为先剪裁后缩放的值来计算（也就是先剪裁self.beginOffsetTime_和self.endOffsetTime_长度，再缩放self.ratio_比例）；
--剪裁相关成员变量含义声明：

--self.beginTime_：经过剪裁缩放等操作后，event最终的开始播放时间；
--self.eventData_.timeLength_：event初始长度，也就是文件中读出来的event长度；
--self.eventData_.motionLength_：有资源文件的event的资源长度(eg:motion,morph)；没有资源的event该成员变量为空(eg:cameraMotion,cameraEffect)
--self.ratio_:缩放比例，=缩放后event长度/缩放前event长度，当前event对于初始event的缩放比例；
--self.initialRatio_：有资源文件的event相对于资源的缩放程度(eg:motion,morph)；没有资源的event该成员变量为空(eg:cameraMotion,cameraEffect)
--self.beginOffsetTime_：剪裁的前偏移时间
--self.endOffsetTime_：剪裁的后偏移时间
--剪裁相关成员函数含义声明：
--getCurrentBeginTime：event实际播放的开始时间；
--getDataBeginTime:event资源文件的开始时间（用于播放时计算差值的开始时间），event没有资源文件时，就是event初始的开始时间
--getEventCurrentLength：event实际播放的长度；
--getDataLength：event资源文件的长度（用于播放时计算差值的长度），event没有资源文件时，就是event初始的长度
function prototype:ctor()
    self.eventData_ = nil;
    self.projectData_ = nil;
    self.beginOffsetTime_ = 0;
    self.endOffsetTime_ = 0;
    self.ratio_ = 1;
    self.beginTime_ = nil;
    self.eventType_ = definations.EVENT_TYPE.UNKOWN;
    self.resourceManagerTacticType_ = definations.MANAGER_TACTIC_TYPE.NO_NEED;
    self.eventCallbacks_ = {
        [definations.EVENT_PLAYER_STATE.EVENT_START] = {},
        [definations.EVENT_PLAYER_STATE.EVENT_UPDATE] = {},
        [definations.EVENT_PLAYER_STATE.EVENT_END] = {},
    };
end


function prototype:initialize()
    self.eventData_ = {};
    return true;
end


function prototype:addEventCallback(eventState, callbackIndex, callback)
    self.eventCallbacks_[eventState][callbackIndex] = callback;
end

function prototype:getEventCallback(callbackState)
    return self.eventCallbacks_[callbackState];
end

function prototype:loadEvent(filename, name, nameTable)--filename为相对路径；
    if string.sub(filename,-5,-1) ~= ".byte" then
        self.projectData_ = newClass("eSkyPlayer/eSkyPlayerProjectData");
        self.projectData_:initialize();
        if self.projectData_:loadProject(filename, name, nameTable) == false then
            return false;
        end
        self.eventData_.timeLength_ = self.projectData_:getTimeLength();
        return true;
    else
        local path = Util.AppDataRoot .. "/" ..filename;
        local buff = misc.readAllBytes(path);
        if self:_loadHeaderFromBuff(buff) == false then
            return false;
        end
        return self:_loadFromBuff(buff);
    end
end


function prototype:isProject()
    if self.projectData_ ~= nil then
        return true;
    end

    return false;
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

function prototype:getProjectData()
    return self.projectData_;
end


function prototype:getEventData()
    return self.eventData_;
end


function prototype:getEventType()
    return self.eventType_;
end


function prototype:getCurrentBeginTime()       --track上event的实际开始时间
    return self.beginTime_;
end

function prototype:getDataBeginTime()   --完整资源等比缩放后的开始时间（不包括剪裁）
    local initialRatio = self.initialRatio_ or 1;
    local beginCut = self.eventData_.beginCut_ or 0;
    return self.beginTime_ - beginCut * initialRatio * self.ratio_ - self.beginOffsetTime_ * self.ratio_;
end

function prototype:getEventCurrentLength()  --实际播放的长度
    return (self.eventData_.timeLength_ - self.beginOffsetTime_ - self.endOffsetTime_) * self.ratio_;
end

function prototype:getDataLength()  --event原始的长度缩放后
    local motionLength = self.eventData_.motionLength_ or self.eventData_.timeLength_;
    return motionLength * self.ratio_;
end


function prototype:setBeginTime(time)
    self.beginTime_ = time + self.beginOffsetTime_;
end

function prototype:getScaleRatio()
    return self.ratio_;
end


function prototype:getInitialRatio()
    return self.initialRatio_ or 1;
end

function prototype:scaleEvent(ratio)   --ratio = 缩放后长度/缩放前长度
    self.ratio_ = ratio;
end


function prototype:clipEvent(cutTime, remainSign) --time为剪裁掉的时间长度；remainSign为保留部分标志，<0表示保留左边；>=0表示保留右边
    if remainSign < 0 then
        self.endOffsetTime_ = self.endOffsetTime_ + cutTime / self.ratio_;
    else
        self.beginOffsetTime_ = self.beginOffsetTime_ + cutTime / self.ratio_;
        if self.beginTime_ ~= nil then
            self.beginTime_ = self.beginTime_ + cutTime;
        end
    end
    return true;
end


function prototype:spawn(beginTime, endTime)
    local event = clone(self);
    if beginTime >= event:getEventCurrentLength() or endTime <= 0 or beginTime >= endTime then
        return nil;
    end
    if endTime < event:getEventCurrentLength() then
        local endCut = event:getEventCurrentLength() - endTime;
        event:clipEvent(endCut, -1)
        if beginTime > 0 then
            local beginCut = beginTime;
            event:clipEvent(beginCut, 1)
        end
    else
        if beginTime > 0 then
            local beginCut = beginTime;
            event:clipEvent(beginCut, 1)
        end
    end
    return event;
end

return prototype;

